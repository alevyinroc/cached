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
	[ValidateScript({Test-Connection -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

$ErrorActionPreference = "Stop";
Clear-Host;
$Error.Clear();
Push-Location;
if ((Get-Module | Where-Object{$_.name -eq "SQLPS"} | Measure-Object).Count -lt 1){
	Import-Module SQLPS;
}
Pop-Location;

#region Globals
$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();
#endregion

#region Functions
function Get-DBTypeFromTrueFalse{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$XmlValue
)
	switch ($XmlValue.ToLower()) {
		"true" { 1; }
		"false" { 0; }
		default { 0;}
	}
}
function Update-Cacher {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.PARAMETER computername
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacherDetails")]
	[string]$CacherName,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacherDetails")]
	[int]$CacherId,
	[Parameter(Mandatory=$true,ParameterSetName="CacherObject")]
	[object]$Cacher
)
	begin {
		$CacherExistsCmd = $SQLConnection.CreateCommand();
		$CacherExistsCmd.CommandText = "select count(1) from cachers where cacherid = @CacherId;"
		$CacherExistsCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacherExistsCmd.Prepare();
		$CacherTableUpdateCmd = $SQLConnection.CreateCommand();
		$CacherTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacherTableUpdateCmd.Parameters.Add("@CacherName", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
	}
	process{
		switch ($PsCmdlet.ParameterSetName) {
			"CacherObject" {$CacherName = $Cacher.innertext;$CacherId= $Cacher.id;}
		}
		
		$CacherExistsCmd.Parameters["@CacherId"].Value = $CacherId;
		$CacherExists = $CacherExistsCmd.ExecuteScalar();
		if ($CacherExists){
		# Update cacher name if it's changed
			$CacherTableUpdateCmd.CommandText = "update cachers set cachername = @CacherName where cacherid = @CacherId and cachername <> @CacherName;";
		} else {
			$CacherTableUpdateCmd.CommandText = "insert into cachers (cacherid, cachername) values (@CacherId, @CacherName);";
		}
		$CacherTableUpdateCmd.Parameters["@CacherId"].Value = $CacherId;
		$CacherTableUpdateCmd.Parameters["@CacherName"].Value = $CacherName;
		$CacherTableUpdateCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$CacherExistsCmd.Dispose();
		$CacherTableUpdateCmd.Dispose();
	}
}
function Update-CacheOwner {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.PARAMETER computername
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[string]$GCNum,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[int]$OwnerId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[string]$PlacedByName
)
	begin {
		$CacheHasOwnerCmd = $SQLConnection.CreateCommand();
		$CacheHasOwnerCmd.CommandText = "select count(1) as CacheOnOwners from cache_owners where cacheid = @gcnum;";
		$CacheHasOwnerCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$CacheHasOwnerCmd.Prepare();
	
		$CacheOwnerUpdateCmd = $SQLConnection.CreateCommand();
		$CacheOwnerUpdateCmd.Parameters.Add("@ownerid", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheOwnerUpdateCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
	}
	process {
		Update-Cacher -Cachername $PlacedByName -CacherId $OwnerId;
		# Check to see if cache is already on the owner table. If owner has changed, update with new value. If cache isn't on the table, add it
		$CacheHasOwnerCmd.Parameters["@gcnum"].Value = $GCNum;
		$CacheHasOwner = $CacheHasOwnerCmd.ExecuteScalar();
		
		if ($CacheHasOwner) {
			$CacheOwnerUpdateCmd.CommandText = "update cache_owners set cacherid = @ownerid where cacheid = @GCNum and cacherid <> @ownerid;"
		} else {
			$CacheOwnerUpdateCmd.CommandText = "insert into cache_owners (cacherid, cacheid) values (@OwnerId, @GCNum);"
		}
		$CacheOwnerUpdateCmd.Parameters["@ownerid"].Value = $ownerid;
		$CacheOwnerUpdateCmd.Parameters["@gcnum"].Value = $gcnum;
		$CacheOwnerUpdateCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$CacheOwnerUpdateCmd.Dispose();
		$CacheOwnerUpdateCmd.Dispose();
	}
}
function New-TravelBug {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.PARAMETER computername
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[int]$TBId,
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$TBPublicId,
#	[ValidationScript({$_.Length -le 50})]
	[string]$TBName
)
	begin {
		$TBCheckCmd = $SQLConnection.CreateCommand();
		$TBCheckCmd.CommandText = "select count(1) as tbexists from travelbugs where tbinternalid = @tbid";
		$TBCheckCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int) | Out-Null;
		$TBCheckCmd.Prepare();

		$TBInsertCmd = $SQLConnection.CreateCommand();
		$TBInsertCmd.CommandText = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (@tbid, @tbpublicid, @tbname)";
		$TBInsertCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int) | Out-Null;
		$TBInsertCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$TBInsertCmd.Parameters.Add("@tbname", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$TBInsertCmd.Prepare();
	}
	process {
		$TBCheckCmd.Parameters["@tbid"].Value = $TBId;
		$TBExists = $TBCheckCmd.ExecuteScalar();
		if (!$TBExists) {
			$TBInsertCmd.Parameters["@tbid"].Value = $TBId;
			$TBInsertCmd.Parameters["@tbname"].Value = $TBName;
			$TBInsertCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
			$TBInsertCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
		$TBCheckCmd.Dispose();
		$TBInsertCmd.Dispose();
	}
}
function Move-TravelBugToCache {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$TBPublicId
)
	begin {
		$RegisterTBToCacheCmd = $SQLConnection.CreateCommand();
		
		$RegisterTBToCacheCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$RegisterTBToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		
		$TBInOtherCacheCmd = $SQLConnection.CreateCommand();
		$TBInOtherCacheCmd.CommandText = "select count(1) from tbinventory where tbpublicid = @tbpublicid;";
		$TBInOtherCacheCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$TBInOtherCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$TBInOtherCacheCmd.Prepare();
	}
	process {
		$TBInOtherCacheCmd.Parameters["@cacheid"].Value = $GCNum;
		$TBInOtherCacheCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
		$TBWasInOtherCache = $TBInOtherCacheCmd.ExecuteScalar();
		if (!$TBWasInOtherCache) {
			$RegisterTBToCacheCmd.CommandText = "insert into tbinventory (cacheid, tbpublicid) values (@cacheid,@tbpublicid)";
		} else {
			$RegisterTBToCacheCmd.CommandText = "update tbinventory set cacheid = @cacheid where tbpublicid = @tbpublicid";		
		}
		$RegisterTBToCacheCmd.Parameters["@cacheid"].Value = $GCNum;
		$RegisterTBToCacheCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
		$RegisterTBToCacheCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$TBInOtherCacheCmd.Dispose();
		$RegisterTBToCacheCmd.Dispose();
	}
}
# TODO: Make this pipeline-aware & pass in single TBs.
function Update-TravelBug {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.PARAMETER computername
.PARAMETER computername
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
	[string]$TBPublicId,
	[Parameter(Mandatory=$true)]
	[int]$TBInternalId,
	[Parameter(Mandatory=$true)]
	[string]$TBName
)
	begin {
	}
	process{
		New-TravelBug -TBId $TBInternalId -TBPublicId $TBPublicId -TBName $TBName;
		Move-TravelBugToCache -GCNum $GCNum -TBPublicId $TBPublicId;
	}
	end {
	}
}
function Update-Geocache {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER computername
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[System.Xml.XmlElement[]]$CacheWaypoint
)
	begin {
		$CacheLoadCmd = $SQLConnection.CreateCommand();
		$CacheExistsCmd = $SQLConnection.CreateCommand();
		$CacheExistsCmd.CommandText = "select count(1) from caches where cacheid = @CacheId;";
		$CacheExistsCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::VarChar,8) | Out-Null;
		$CacheExistsCmd.Prepare();
		$CacheLoadCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@gsid", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheName", [System.Data.SqlDbType]::nVarChar, 50) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Placed", [System.Data.SqlDbType]::datetime) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@PlacedBy", [System.Data.SqlDbType]::nVarChar) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@TypeId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@SizeId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Diff", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Terrain", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@ShortDesc", [System.Data.SqlDbType]::nVarChar, 5000) | Out-Null;
		#See http://support.microsoft.com/kb/970519 for bug workaround
		$CacheLoadCmd.Parameters["@ShortDesc"].Size = -1;
		$CacheLoadCmd.Parameters.Add("@LongDesc", [System.Data.SqlDbType]::ntext) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Hint", [System.Data.SqlDbType]::nVarChar, 1000) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Avail", [System.Data.SqlDbType]::bit) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Archived", [System.Data.SqlDbType]::bit) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@PremOnly", [System.Data.SqlDbType]::bit) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheStatus",[System.Data.SqlDbType]::Int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheUpdated", [System.Data.SqlDbType]::DateTime) | Out-Null;
		#$CacheLoadCmd.Prepare();
	}
	process {
	# TODO: Can't navigate XML element structure anymore, need to use ugliness like $CacheWaypoint | Select-Object -ExpandProperty cache | Select-Object -ExpandProperty name
		$GCNum = $CacheWaypoint | Select-Object -ExpandProperty name;
		$PlacedDate = get-date ($CacheWaypoint | Select-Object -ExpandProperty time);
		
		$Latitude = $CacheWaypoint | Select-Object -ExpandProperty lat;
		$Longitude = $CacheWaypoint | Select-Object -ExpandProperty lon;
		$CacheExistsCmd.Parameters["@CacheId"].Value = $GCNum;
		$CacheExists = $CacheExistsCmd.ExecuteScalar();
		$CacheWaypoint = $CacheWaypoint | Select-Object -ExpandProperty cache;
		# Load/Update cache table
# TODO: Use GPX time for Last Updated. $cachedata.gpx.time
		if (!$CacheExists){
			$CacheLoadCmd.CommandText = @"
		INSERT INTO [dbo].[caches]
				 ([cacheid]
				 ,[gsid]
				 ,[cachename]
				 ,[latitude]
				 ,[longitude]
				 ,[lastupdated]
				 ,[placed]
				 ,[placedby]
				 ,[typeid]
				 ,[sizeid]
				 ,[difficulty]
				 ,[terrain]
				 ,[shortdesc]
				 ,[longdesc]
				 ,[hint]
				 ,[available]
				 ,[archived]
				 ,[premiumonly]
				 ,[cachestatus]
				 ,[created])
			 VALUES
				 (@CacheId
				 ,@GSID
				 ,@CacheName
				 ,@Lat
				 ,@Long
				 ,getdate()
				 ,@Placed
				 ,@PlacedBy
				 ,@TypeId
				 ,@SizeId
				 ,@Diff
				 ,@Terrain
				 ,@ShortDesc
				 ,@LongDesc
				 ,@Hint
				 ,@Avail
				 ,@Archived
				 ,@PremOnly
				 ,@CacheStatus
				 ,getdate()
				 );
"@;
		} else {
			$CacheLoadCmd.CommandText = @"
		UPDATE [dbo].[caches]
		 SET [gsid] = @gsid
			 ,[cachename] = @CacheName
			 ,[latitude] = @Lat
			 ,[longitude] = @Long
			 ,[lastupdated] = @CacheUpdated
			 ,[placed] = @Placed
			 ,[placedby] = @PlacedBy
			 ,[typeid] = @TypeId
			 ,[sizeid] = @SizeId
			 ,[difficulty] = @Diff
			 ,[terrain] = @Terrain
			 ,[shortdesc] = @ShortDesc
			 ,[longdesc] = @LongDesc
			 ,[hint] = @Hint
			 ,[available] = @Avail
			 ,[archived] = @Archived
			 ,[premiumonly] = @PremOnly
			 ,[cachestatus] = @CacheStatus
		 WHERE CacheId = @CacheId;
"@;
		}
		$CacheLoadCmd.Parameters["@CacheId"].Value = $GCNum;
		$CacheLoadCmd.Parameters["@gsid"].Value = $CacheWaypoint | Select-Object -ExpandProperty id;
		$CacheLoadCmd.Parameters["@CacheName"].Value = $CacheWaypoint | Select-Object -ExpandProperty name;
		$CacheLoadCmd.Parameters["@Lat"].Value = $Latitude;
		$CacheLoadCmd.Parameters["@Long"].Value = $Longitude;
		$CacheLoadCmd.Parameters["@Placed"].Value = $PlacedDate;
		$CacheLoadCmd.Parameters["@PlacedBy"].Value = $CacheWaypoint | Select-Object -ExpandProperty placed_by;
		$CacheLoadCmd.Parameters["@TypeId"].Value = $PointTypeLookup | where-object{$_.typename -eq ($CacheWaypoint | Select-Object -ExpandProperty type)} | Select-Object -ExpandProperty typeid;
		$CacheLoadCmd.Parameters["@SizeId"].Value = $CacheSizeLookup | where-object{$_.sizename -eq ($CacheWaypoint | Select-Object -ExpandProperty container)} | Select-Object -ExpandProperty sizeid;
		$CacheLoadCmd.Parameters["@Diff"].Value = $CacheWaypoint | Select-Object -ExpandProperty difficulty;
		$CacheLoadCmd.Parameters["@Terrain"].Value = $CacheWaypoint | Select-Object -ExpandProperty terrain;
		$CacheLoadCmd.Parameters["@ShortDesc"].Value = $CacheWaypoint | Select-Object -ExpandProperty short_description | Select-Object -ExpandProperty innertext;
		$CacheLoadCmd.Parameters["@LongDesc"].Value = $CacheWaypoint | Select-Object -ExpandProperty long_description | Select-Object -ExpandProperty innertext;
		$CacheLoadCmd.Parameters["@Hint"].Value = $CacheWaypoint | Select-Object -ExpandProperty encoded_hints;
		$CacheLoadCmd.Parameters["@Avail"].Value = Get-DBTypeFromTrueFalse ($CacheWaypoint | Select-Object -ExpandProperty available);
		$CacheLoadCmd.Parameters["@Archived"].Value = Get-DBTypeFromTrueFalse ($CacheWaypoint | Select-Object -ExpandProperty archived);
		$CacheLoadCmd.Parameters["@CacheUpdated"].Value = $GPXDate;
		if (($CacheWaypoint | Select-Object -ExpandProperty archived) -eq "true") {
			$UnifiedStatus = $CacheStatusLookup | Where-Object{$_.statusname -eq "archived"} | Select-Object -ExpandProperty statusid;
		} else{
			if (($CacheWaypoint | Select-Object -ExpandProperty available) -eq "true") {
				$UnifiedStatus = $CacheStatusLookup | Where-Object{$_.statusname -eq "available"} | Select-Object -ExpandProperty statusid;
			} else {
				$UnifiedStatus = $CacheStatusLookup | Where-Object{$_.statusname -eq "disabled"} | Select-Object -ExpandProperty statusid;
			}
		}
		$CacheLoadCmd.Parameters["@CacheStatus"].Value = $UnifiedStatus;
		# TODO: Figure out where premium only comes from. Doesn't appear to be in the GPX
		$CacheLoadCmd.Parameters["@PremOnly"].Value = 0; #Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.
		# Execute
		$CacheLoadCmd.ExecuteNonQuery() | Out-Null;

		Update-CacheOwner -GCNum $GCNum -OwnerId $($CacheWaypoint | Select-Object -ExpandProperty owner | Select-Object -ExpandProperty id) -PlacedByName $($CacheWaypoint | Select-Object -ExpandProperty placed_by);
	}
	end {
		$CacheLoadCmd.Dispose();
		$CacheExistsCmd.Dispose();
	}
}
function Update-Log {
<#
.SYNOPSIS
	Creates or updates a geocache log
.DESCRIPTION
	Creates or updates a geocache log, and links it to its parent cache.
.PARAMETER LogId
	Groundspeak unique ID for the log
.PARAMETER CacheId
	GC code for the cache the log is attached to
.PARAMETER LogDate
	Date of the log entry
.PARAMETER LogTypeName
	Log entry type - found, didn't find, etc.
.PARAMETER Finder
	Groundspeak internal ID of the finder of the 
.PARAMETER LogText
	Full text of the log entry
.PARAMETER Latitude
	Latitude of the waypoint attached to the log by the finder, if any
.PARAMETER Longitude
	Longitude of the waypoint attached to the log by the finder, if any
.PARAMETER CacheLog
	XMLElement from the GPX file which contains the full log details
.EXAMPLE
	Update-Log -LogId 12345 -CacheId GCABCD -LogDate "2013-09-01" -LogTypeName "Found It" -Finder "Bob" -LogText "I found the cache!" -Latitude 40.12345 -Longitude -80.87321
.EXAMPLE
	$CacheData.SelectNodes("//log") | foreach-Object {Update-Log -CacheLog $_}
#>
param (
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[int]$LogId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[string]$CacheId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[System.DateTime]$LogDate,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[string]$LogTypeName,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[int]$Finder,
	[Parameter(Mandatory=$false,ParameterSetName="ExplicitLogDetails")]
	[string]$LogText="",
	[Parameter(Mandatory=$false,ParameterSetName="ExplicitLogDetails")]
	[float]$Latitude,
	[Parameter(Mandatory=$false,ParameterSetName="ExplicitLogDetails")]
	[float]$Longitude,
	[Parameter(Mandatory=$true,ParameterSetName="LogObject")]
	[System.Xml.XmlElement]$CacheLog
)
begin {
		$LogExistsCmd = $SQLConnection.CreateCommand();
		$LogExistsCmd.CommandText = "select count(1) from logs where logid = @LogId;"
		$LogExistsCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogExistsCmd.Prepare();
		$LogTableUpdateCmd = $SQLConnection.CreateCommand();
		$LogTableUpdateCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogDate", [System.Data.SqlDbType]::DateTime) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogType", [System.Data.SqlDbType]::Int) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogText", [System.Data.SqlDbType]::NVarChar, 4000) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::Float) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::Float) | Out-Null;
		$LogTypes = Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "select logtypeid,logtypedesc from log_types";
		$LogLinkToCacheCmd = $SQLConnection.CreateCommand();
		$LogLinkToCacheCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogLinkToCacheCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$LogLinkToCacheCmd.CommandText = "insert into cache_logs (cacheid,logid) values (@CacheId, @LogId)";
		$LogLinkToCacheCmd.Prepare();
		$LogLinkedCmd = $SQLConnection.CreateCommand();
		$LogLinkedCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogLinkedCmd.CommandText = "select count(1) from cache_logs where logid = @LogId";
		$LogLinkedCmd.Prepare();
	}
	process{
		switch ($PsCmdlet.ParameterSetName) {
			"LogObject" {
				$Finder = $CacheLog.finder.id;
				$LogId = $CacheLog.id;
				$LogDate = Get-Date $CacheLog.date;
				$LogType = $LogTypes | Where-Object{$_.logtypedesc -eq $CacheLog.type};
				$LogText = $CacheLog.text;
				$Latitude = $CacheLog.lat;
				$Longitude = $CacheLog.lon;
			}
			"ExplicitLogDetails" {
				$LogType = $LogTypes | Where-Object{$_.logtypedesc -eq $LogTypeName} | Select-Object -ExpandProperty logtypeid;
			}
		}
		
		$LogExistsCmd.Parameters["@LogId"].Value = $LogId;
		$LogExists = $LogExistsCmd.ExecuteScalar();
		if ($LogExists){
			$LogTableUpdateCmd.CommandText = "update logs set logdate=@LogDate, logtypeid=@LogType, cacherid = @CacherId, logtext = @LogText, latitude = @Lat, longitude = @Long where logid = @LogId;";
		} else {
			$LogTableUpdateCmd.CommandText = "insert into logs (logid,logdate, logtypeid, cacherid,logtext,latitude,longitude) values (@LogId,@LogDate,@LogType, @CacherId,@LogText,@Lat,@Long);";
		}
		$LogTableUpdateCmd.Parameters["@CacherId"].Value = $Finder;
		$LogTableUpdateCmd.Parameters["@LogId"].Value = $LogId;
		$LogTableUpdateCmd.Parameters["@LogDate"].Value = $LogDate;
		$LogTableUpdateCmd.Parameters["@LogType"].Value = $LogType;
		$LogTableUpdateCmd.Parameters["@LogText"].Value = $LogText;
		$LogTableUpdateCmd.Parameters["@Lat"].Value = $Latitude;
		$LogTableUpdateCmd.Parameters["@Long"].Value = $Longitude;
		$LogTableUpdateCmd.ExecuteNonQuery() | Out-Null;
		
		$LogLinkedCmd.Parameters["@LogId"].Value = $LogId;
		$LogLinked = $LogLinkedCmd.ExecuteScalar();
		if (!$LogLinked) {
			$LogLinkToCacheCmd.Parameters["@LogId"].Value = $LogId;
			$LogLinkToCacheCmd.Parameters["@CacheId"].Value = $CacheId;
			$LogLinkToCacheCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
		$LogExistsCmd.Dispose();
		$LogTableUpdateCmd.Dispose();
	}
}
function Update-Waypoint {
<#
.SYNOPSIS
	Creates or updates a non-geocache waypoint
.DESCRIPTION
	Creates or updates a non-geocache waypoint. Locates the parent cache & associates the child with it.
.PARAMETER Waypoint
	Custom PSObject containing the data representing a single non-geocache waypoint
.EXAMPLE
	Update-Waypoint -Waypoint $WptData
.EXAMPLE
	$AllWaypoints | Update-Waypoint
#>
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Waypoint
)
	begin {
		$WptExistsCmd = $SQLConnection.CreateCommand();
		$WptExistsCmd.CommandText = "select count(1) from waypoints where waypointid = @wptid and parentcache = @cacheid;";
		$WptExistsCmd.Parameters.Add("@wptid", [System.Data.SqlDbType]::VarChar,10) | Out-Null;
		$WptExistsCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar,8) | Out-Null;
		$WptUpsertCmd = $SQLConnection.CreateCommand();
		$WptExistsCmd.Prepare();
		$WptUpsertCmd.Parameters.Add("@wptid", [System.Data.SqlDbType]::VarChar,10) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar,8) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@lat",[System.Data.SqlDbType]::Float) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@long",[System.Data.SqlDbType]::Float) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@name",[System.Data.SqlDbType]::VarChar,50) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@desc",[System.Data.SqlDbType]::VarChar, 2000) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@url",[System.Data.SqlDbType]::VarChar,2038) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@urldesc",[System.Data.SqlDbType]::nVarChar, 200) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@pointtype", [System.Data.SqlDbType]::int) | Out-Null;
	}
	process {
		$Id = $Waypoint | Select-Object -ExpandProperty Id;
		$Latitude = [float]($Waypoint | Select-Object -ExpandProperty Lat);
		$Longitude = [float]($Waypoint | Select-Object -ExpandProperty Long);
		$WptDate = get-date ($Waypoint | Select-Object -ExpandProperty DateTime);
		$Name = $Waypoint | Select-Object -ExpandProperty Name;
		$Description = $Waypoint | Select-Object -ExpandProperty Description;
		$Url = $Waypoint | Select-Object -ExpandProperty Url;
		$UrlDesc = $Waypoint | Select-Object -ExpandProperty UrlDesc;
		$Symbol = $Waypoint | Select-Object -ExpandProperty Symbol;
		$PointType = $Waypoint | Select-Object -ExpandProperty PointType;
		$PointTypeId = Get-PointTypeId -PointTypeName $PointType;
		
# Check for point type. If it doesn't exist, create it
# Get parent cache id. Same as waypoint ID but first 2 chars are GC
		$ParentCache = "GC" + $Id.Substring(2,$Id.Length - 2);
		$ParentCache = Find-ParentCacheId -CacheId $ParentCache;
		
		$WptExistsCmd.Parameters["@wptid"].Value = $Id;
		$WptExistsCmd.Parameters["@cacheid"].Value = $ParentCache;
		$WaypointExists = $WptExistsCmd.ExecuteScalar();
		if ($WaypointExists) {
			$WptUpsertCmd.CommandText = @"
update waypoints set
	latitude = @lat,
	longitude = @long,
	name = @name,
	description = @desc,
	url = @url,
	urldesc = @urldesc,
	typeid = @pointtype
where
	waypointid = @wptid
	and parentcache = @cacheid;
"@;
		} else {
			$WptUpsertCmd.CommandText = @"
insert into waypoints (waypointid,parentcache,latitude,longitude,name,description,url,urldesc,typeid) values (
@wptid, @cacheid,@lat,@long,@name,@desc,@url,@urldesc,@pointtype);
"@;
		}
		$WptUpsertCmd.Parameters["@wptid"].Value = $Id;
		$WptUpsertCmd.Parameters["@cacheid"].Value = $ParentCache;
		$WptUpsertCmd.Parameters["@lat"].Value = $Latitude;
		$WptUpsertCmd.Parameters["@long"].Value = $Longitude;
		$WptUpsertCmd.Parameters["@name"].Value = $Name;
		$WptUpsertCmd.Parameters["@desc"].Value = $Description;
		$WptUpsertCmd.Parameters["@url"].Value = $Url;
		$WptUpsertCmd.Parameters["@urldesc"].Value = $UrlDesc;
		$WptUpsertCmd.Parameters["@pointtype"].Value = $PointTypeId;
		$WptUpsertCmd.ExecuteNonQuery() | Out-Null;
		$WaypointsProcessed++;
	}
	end {
		$WptExistsCmd.Dispose();
		$WptUpsertCmd.Dispose();
		
	}
}
function Find-ParentCacheId {
<#
.SYNOPSIS
	Finds the GC ID of a waypoint's parent cache
.DESCRIPTION
	Finds the GC ID of a waypoint's parent cache. This is currently tightly coupled to the calling function, Update-Waypoint because it assumes that a GC ID is being passed in. Assumes that the waypoint ID is XXYYYZZ where XX is any two characters, YYY is the GC ID of the parent cache less the preceding "GC", and ZZ is an optional suffix. This function recursively trims off any suffix until it locates the parent cache ID.
.PARAMETER CacheId
	ID of the parent cache to search for
.EXAMPLE
	Find-ParentCacheId -CacheId GC123401
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$CacheId
)
	$CacheFindCmd = $SQLConnection.CreateCommand();
	$CacheFindCmd.CommandText = "select count(1) from caches where cacheid like @cacheid";
	$CacheFindCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 20) | Out-Null;
	$CacheFindCmd.Prepare();
	#$CacheId = "GC" + $WptId.Substring(2,$WptId.Length - 2);
	$CacheFindCmd.Parameters["@cacheid"].Value = $CacheId + "%";
	$FoundCache = $CacheFindCmd.ExecuteScalar();
	$CacheFindCmd.Dispose();
	if ($FoundCache) {
		$CacheId;
	} else {
		Find-ParentCacheId -CacheId $CacheId.Substring(0,$CacheId.Length - 1);
	}
	
}
function Get-PointTypeId {
<#
.SYNOPSIS
	Gets waypoint type ID from the text name.
.DESCRIPTION
	Gets waypoint type ID from the text name. If no type ID exists for the name, a new one will be created on the point_types table.
.PARAMETER PointTypeName
	Name of the point type to look up. If no point type is found, a new one will be created with that name.
.EXAMPLE
	Get-PointTypeId -PointTypeName "Parking Area"
#>
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true)]
	[string]$PointTypeName
)
	begin{
		$PointTypeLookupCmd = $SQLConnection.CreateCommand();
		$PointTypeInsertCmd = $SQLConnection.CreateCommand();
		$PointTypeLookupCmd.Parameters.Add("@typename",[System.Data.SqlDbType]::VarChar, 30) | Out-Null;
		$PointTypeInsertCmd.Parameters.Add("@typename",[System.Data.SqlDbType]::VarChar, 30) | Out-Null;
		$PointTypeLookupCmd.CommandText = "select typeid from point_types where typename = @typename";
		$PointTypeInsertCmd.CommandText = "insert into point_types (typename) values (@typename);";
		$PointTypeLookupCmd.Prepare();
		$PointTypeInsertCmd.Prepare();
	}
	process{
		$PointTypeLookupCmd.Parameters["@typename"].Value = $PointTypeName;
		$PointTypeId = $PointTypeLookupCmd.ExecuteScalar();
		if (-not ($PointTypeId -ge 1)) {
			$PointTypeInsertCmd.Parameters["@typename"].Value = $PointTypeName;
			$PointTypeInsertCmd.ExecuteNonQuery() | Out-Null;
			$PointTypeId = $PointTypeLookupCmd.ExecuteScalar();
		}
		[int]$PointTypeId;
	}
	end{
		$PointTypeInsertCmd.Dispose();
		$PointTypeLookupCmd.Dispose();
	}
}
function New-Attribute {
<#
.SYNOPSIS
	Creates a new cache attribute
.DESCRIPTION
	Creates a new cache attribute with the properties contained in the passed-in object.
.PARAMETER Attribute
	A custom PSObject containing the properties of the attribute to create. This includes (minimally) the Groundspeak attribute ID, and the associated text. If the attribute already exists (when searched by ID), the text will be updated.
.EXAMPLE
	New-Attribute -Attribute $CacheAttribute;
.EXAMPLE
	$AllCacheAttributes | New-Attribute;;
#>
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Attribute
)
	begin {
		$CacheAttributeCheckCmd = $SQLConnection.CreateCommand();
		$CacheAttributeCheckCmd.CommandText = "select count(1) as attrexists from attributes where attributeid = @attrid";
		$CacheAttributeCheckCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$CacheAttributeCheckCmd.Prepare();

		$CacheAttributeInsertCmd = $SQLConnection.CreateCommand();
		$CacheAttributeInsertCmd.CommandText = "insert into attributes (attributeid,attributename) values (@attrid, @attrname)";
		$CacheAttributeInsertCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$CacheAttributeInsertCmd.Parameters.Add("@attrname", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$CacheAttributeInsertCmd.Prepare();
	}
	process {
		$AttrId = [int]($Attribute | Select-Object -ExpandProperty AttrId);
		$AttrName = $Attribute | Select-Object -ExpandProperty AttrName;
		$CacheAttributeCheckCmd.Parameters["@attrid"].Value = $AttrId;
		$AttrExists = $CacheAttributeCheckCmd.ExecuteScalar();
		if (!$AttrExists) {
			$CacheAttributeInsertCmd.Parameters["@attrid"].Value = $AttrId;
			$CacheAttributeInsertCmd.Parameters["@attrname"].Value = $AttrName;
			$CacheAttributeInsertCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
		$CacheAttributeCheckCmd.Dispose();
		$CacheAttributeInsertCmd.Dispose();
	}
}
function Drop-Attributes {
<#
.SYNOPSIS
	Disassociates all attributes from a geocache.
.DESCRIPTION
	Disassociates all attributes from a geocache. Does not delete the attributes themselves
.PARAMETER CacheId
	GC ID of the cache to drop attributes from.
.EXAMPLE
	Drop-Attributes -CacheId GC1234
#>
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ParameterSetName="SingleCache")]
	[string]$CacheId
)
	begin {
		$DropCacheAttributesCmd = $SQLConnection.CreateCommand();
		$DropCacheAttributesCmd.CommandText = "delete from cache_attributes where cacheid = @cacheid;";
		$DropCacheAttributesCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$DropCacheAttributesCmd.Prepare();
	}
	process {
		$DropCacheAttributesCmd.Parameters["@cacheid"].Value = $CacheId;
		$DropCacheAttributesCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$DropCacheAttributesCmd.Dispose();
	}
}
function Register-AttributeToCache {
<#
.SYNOPSIS
	Connects an attribute to a geocache
.DESCRIPTION
	Associates an attribute with a geocache including an indicator that the attribute is included or excluded.
.PARAMETER Attribute
	A custom PSObject containing the properties of the attribute to create.
.EXAMPLE
	Register-AttributeToCache -Attribute $CacheAttr
.EXAMPLE
	$AllCacheAttributes | Register-AttributeToCache
#>
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Attribute
)
	begin {
		$RegisterAttributeToCacheCmd = $SQLConnection.CreateCommand();
		$RegisterAttributeToCacheCmd.CommandText = "insert into cache_attributes (cacheid,attributeid,attribute_applies) values (@cacheid,@attrid,@attrapplies);";
		$RegisterAttributeToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$RegisterAttributeToCacheCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$RegisterAttributeToCacheCmd.Parameters.Add("@attrapplies", [System.Data.SqlDbType]::Bit) | Out-Null;
		$RegisterAttributeToCacheCmd.Prepare();
	}
	process {
		$RegisterAttributeToCacheCmd.Parameters["@cacheid"].Value = $Attribute | Select-Object -ExpandProperty ParentCache;
		$RegisterAttributeToCacheCmd.Parameters["@attrid"].Value = $Attribute | Select-Object -ExpandProperty AttrId;
		$RegisterAttributeToCacheCmd.Parameters["@attrapplies"].Value = [int]($Attribute | Select-Object -ExpandProperty AttrInc);
		$RegisterAttributeToCacheCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$RegisterAttributeToCacheCmd.Dispose();
	}
}
#endregion

# Get Type & Size lookup tables
$PointTypeLookup = invoke-sqlcmd -server $SQLInstance -database $Database -query "select typeid, typename from point_types;";
$CacheSizeLookup = invoke-sqlcmd -server $SQLInstance -database $Database -query "select sizeid, sizename from cache_sizes;";
$CacheStatusLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select statusid, statusname from statuses;";

[xml]$cachedata = get-content $FileToImport;
$GPXDate = get-date $cachedata.gpx.time;
# For each $cachedata.gpx.wpt
# Check for a cache child element
# If one exists, it's a cache
# Otherwise, it's a waypoint
$CachesProcessed = 0;
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};

 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	Write-Progress -Activity "Loading Geocaches" -Status "Cache ID $GCNum" -Id 1 -PercentComplete $(($CachesProcessed/$Geocaches.Count)*100)
	Update-Geocache $_; #Process as geocache
# Load cacher table if no record for current cache's owner, or update name
	Update-Cacher -Cacher $_.cache.owner;
# Insert attributes & TBs into respective tables
	if ($_.cache.attributes.attribute.Count -gt 0) {
		$AllAttributes = New-Object -TypeName System.Collections.Generic.List[PSObject];
		$_.cache.attributes.attribute | ForEach-Object {
			$CacheAttribute = New-Object -TypeName PSObject -Property @{
				AttrId = $_.id
				AttrInc = $_.inc
				AttrName = $_."#text"
				ParentCache = $GCNum
			};
			$AllAttributes.Add($CacheAttribute);
		};
		
		$AllAttributes | New-Attribute;
		Drop-Attributes -CacheID $GCNum;
		$AllAttributes | Register-AttributeToCache;
	}
#TODO: Make this pipeline aware with $cachedata.gpx.wpt.cache.travelbugs.travelbug | update-travelbugs
	
	if ($_.cache.travelbugs.travelbug.Count -gt 0) {
		$_.cache.travelbugs.travelbug | ForEach-Object {
			Update-TravelBug -GCNum $GCNum -TBPublicId $_.ref -TBName $_.name -TBInternalId $_.id;
		}
	}
	$logs = $_.cache.logs | Select-Object -ExpandProperty log;
# TODO: Make this pipeline aware with $logs.finder | Update-Cacher
	$logs | Select-Object -ExpandProperty finder | ForEach-Object{Update-Cacher -Cacher $_}
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
		Update-Log @UpdateLogVars;
	};
	$CachesProcessed++;
};
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

$ChildWaypoints | Update-Waypoint;

$SQLConnection.Close();
Remove-Module SQLPS;
