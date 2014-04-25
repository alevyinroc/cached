<#
.SYNOPSIS
	Loads the contents of a geocaching-related GPX file into a database.
.DESCRIPTION
	Using the contents of a GPX file with Groundspeak extensions, loads the data into the specified database. Items that do not previously exist are created, and existing items are updated.
	Copyright Andy Levy andy@levyclan.us 2013
.PARAMETER FileToImport
	GPX file to be loaded into the database
.PARAMETER SQLInstance
	SQL Server instance to connect to for loading data
.PARAMETER Database
	Database on the SQLInstance to store the data in
.EXAMPLE
 .\Import-GPXtoDB.ps1 -sqlinstance hobbes\sqlexpress -Database geocaches -FileToImport C:\Users\andy\Documents\Code\cachedb\scratchpad\100CP.gpx
#>

#requires -version 2.0
#Set-StrictMode -Version 2.0
[cmdletbinding()]

param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Path -path $_ -PathType Leaf})]
	[string]$FileToImport = 'C:\Users\andy\Documents\Code\cachedb\scratchpad\GCF7C6.gpx',
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

$ErrorActionPreference = "Stop";
Clear-Host;
$Error.Clear();
Push-Location;
if ((Get-Module | Where-Object{$_.name -eq "SQLPS"} | Measure-Object).Count -lt 1){
	Import-Module SQLPS -DisableNameChecking;
}
Pop-Location;
if ((Get-Module | Where-Object{$_.name -eq "Geocaching"} | Measure-Object).Count -ge 1){
	Remove-Module geocaching;
}
Import-Module C:\Users\andy\Documents\cachedb\posh\Modules\Geocaching;

#region Globals
$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();
#endregion

#region Functions

#endregion

$cachedata = new-object -type XML;
$cachedata.load($FileToImport);

[DateTimeOffset]$script:GPXDate = get-date $cachedata.gpx.time;
# For each $cachedata.gpx.wpt
# Check for a cache child element
# If one exists, it's a cache
# Otherwise, it's a waypoint
$CachesProcessed = 0;
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};

# New method of loading attributes into database
$Geocaches | Select-Object -expandproperty cache | where-object{$_.attributes.attribute -ne $null} |
	Select-Object -expandproperty attributes|Select-Object -expandproperty attribute |
	Select-Object @{Name="attrname";expression={$_."#text"}},@{Name="attrid";expression={$_.id}} -Unique | New-Attribute -DBConnection $SQLConnection;

# Get all unique states, countries, types, containers, owners & finders.
# Pre-load tables with the values found in the GPX file. This should be faster
# than doing it as they're encountered while loading the actual cache data
$states = $Geocaches|Select-Object -expandproperty cache|Select-Object -ExpandProperty state |Sort-Object -Unique | where-object {$_ -ne ""} | Get-StateId -DBConnection $SQLConnection | Out-Null;
$countries = $Geocaches|Select-Object -expandproperty cache|Select-Object -ExpandProperty country |Sort-Object -Unique | where-object {$_ -ne ""} | Get-CountryId -DBConnection $SQLConnection | Out-Null;
$types = $Geocaches|Select-Object -expandproperty cache|Select-Object -ExpandProperty type |Sort-Object -Unique;
$containers = $Geocaches|Select-Object -expandproperty cache|Select-Object -ExpandProperty container |Sort-Object -Unique;
$cacheowners = $Geocaches|Select-Object -expandproperty cache|Select-Object -ExpandProperty owner | Select-Object id,@{Name="OwnerName";expression={$_."#text"}}|Sort-Object -property id,OwnerName -unique
$cachefinders = $Geocaches|Select-Object -expandproperty cache|Select-Object -expandproperty logs|Select-Object -expandproperty log|Select-Object -expandproperty finder|Select-Object -Property id,@{Name="FinderName";Expression={$_."#text"}}|Sort-Object -Property id,FinderName -Unique;

# TODO: There has to be a better way to do this. foreach $cache in $geocaches maybe?
if ($Geocaches -ne $null) {
	$Geocaches | ForEach-Object {
		$GCNum = $_.name;
		write-verbose $GCNum;
        if ($Geocaches.Count) {
		    Write-Progress -Activity "Loading Geocaches" -Status "Cache ID $GCNum" -Id 1 -PercentComplete $(($CachesProcessed/$Geocaches.Count)*100);
        }
		Update-Geocache -CacheWaypoint $_ -LastUpdated $script:GPXDate -DBConnection $SQLConnection; #Process as geocache
	# Load cacher table if no record for current cache's owner, or update name
		Update-Cacher -CacherId $_.cache.owner.id -CacherName $_.cache.owner.innertext -DBConnection $SQLConnection;
	# Insert attributes & TBs into respective tables
		if ($_.cache.attributes.attribute.Count -gt 0) {
			$AllAttributes = New-Object -TypeName System.Collections.Generic.List[PSObject];
			$_.cache.attributes.attribute | ForEach-Object {
				$CacheAttribute = New-Object -TypeName PSObject -Property @{
					AttrId = $_.id
					AttrInc = $_.inc
					ParentCache = $GCNum
				};
				$AllAttributes.Add($CacheAttribute);
			};
			Remove-Attribute -CacheID $GCNum -DBConnection $SQLConnection;
			$AllAttributes | Register-AttributeToCache -DBConnection $SQLConnection;
		}
#TODO: Make this pipeline aware with $cachedata.gpx.wpt.cache.travelbugs.travelbug | update-travelbugs

		if ($_.cache.travelbugs.travelbug.Count -gt 0) {
			$_.cache.travelbugs.travelbug | ForEach-Object {
				Update-TravelBug -GCNum $GCNum -TBPublicId $_.ref -TBName $_.name -TBInternalId $_.id -DBConnection $SQLConnection;
			}
		}
		$logs = $_.cache.logs | Select-Object -ExpandProperty log;
	# TODO: Make this pipeline aware with $logs.finder | Update-Cacher
		$logs | Select-Object -ExpandProperty finder | ForEach-Object{Update-Cacher -CacherName $_.innertext -CacherId $_.id -DBConnection $SQLConnection}
		$logs | ForEach-Object {
			$UpdateLogVars = @{
				'LogId' = $_.id;
				'CacheId' = $GCNum;
				'LogDate' = $_.date;
				'LogTypeName' = $_.type;
				'Finder' = $_.finder.id;
			};
			if (($_.text | Select-Object -ExpandProperty "#text" -ErrorAction SilentlyContinue) -eq $null) {
				$UpdateLogVars.Add('LogText', '');
			} else {
				$UpdateLogVars.Add('LogText', $($_.text | Select-Object -ExpandProperty "#text"));
			}
			if ($_.log_wpt) {
				$UpdateLogVars.Add('Latitude',$_.log_wpt.lat);
				$UpdateLogVars.Add('Longitude',$_.log_wpt.lon);
			}
			Update-Log @UpdateLogVars -DBConnection $SQLConnection;
		};
		$CachesProcessed++;
	};
}
Write-Progress -Activity "Loading Geocaches" -completed -Id 1
$ChildWaypoints = New-Object -TypeName System.Collections.Generic.List[PSObject];
$cachedata.gpx.wpt | Where-Object{$_.type.split(" | ")[0] -ne "Geocache"} | ForEach-Object{
	$Waypoint = New-Object -TypeName PSObject -Property @{
			Lat = $_.lat
			Long = $_.lon
			DateTime = $_.time
			Id = $_.name
			Name = $_.cmt
			Description = $_.desc
			Url = $_.url
			UrlDesc = $_.urlname
			Symbol = $_.sym
			PointType = $_.type.split(" | ")[1];
		};
		$ChildWaypoints.Add($Waypoint);
};

$ChildWaypoints | Update-Waypoint -DBConnection $SQLConnection -LastUpdated $script:GPXDate;
$SQLConnection.Close();
Remove-Module Geocaching;
Remove-Module SQLPS;
