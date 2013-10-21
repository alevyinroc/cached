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

$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();

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

function Update-Cacher2 {
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
	[Parameter(Mandatory=$true,ParameterSetName="CacherObject",ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
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
			"CacherObject" {$CacherName = $Cacher.cachername;$CacherId= $Cacher.cacherid;}
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

[xml]$cachedata = get-content $FileToImport;
Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from cachers;";
[System.GC]::Collect();
# Old Way
$Finders = 0;
$OldMethodTime = Measure-Command{
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};
 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	$logs = $_.cache.logs | Select-Object -ExpandProperty log;
	$logs | Select-Object -ExpandProperty finder | ForEach-Object{$Finders++;Update-Cacher -Cacher $_};
	}
}
$MemAfterOld = (get-process -pid $pid|select -expandproperty vm)/1MB;

Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from cachers;";
Remove-Variable Geocaches;
[System.GC]::Collect();
Write-Verbose "First pass complete";
# New Way
$NewMethodTime = Measure-Command{
	$MemBeforeNew = (get-process -pid $pid|select -expandproperty vm)/1MB;
	$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};
	$geocaches|select -expandproperty cache |select -expandproperty logs|select -expandproperty log|select -expandproperty finder|select -unique @{name="cacherid";expression={$_.id}},@{name="cachername";expression={$_."#text"}}|update-cacher2;

	$MemAfterNew = (get-process -pid $pid|select -expandproperty vm)/1MB;
}
$UniqueFinders = ($geocaches|select -expandproperty cache |select -expandproperty logs|select -expandproperty log|select -expandproperty finder|select -unique @{name="cacherid";expression={$_.id}},@{name="cachername";expression={$_."#text"}}).Count;
Write-Verbose "Second pass complete";

#$NewMethod2Time = Measure-Command{
#	$cachedata.gpx.wpt.cache.attributes.attribute|Select-Object -Property id,"#text"|Sort-Object -property id,"#text" -unique| New-Attribute
#}

#$gpx.gpx.wpt|?{$_.type.split(" | ")[0] -eq "Geocache"}|select -expandproperty cache|?{$_.attributes.attribute -ne $null}|select -expandproperty attributes|select -expandproperty attribute |select "#text",id|sort id,"#text" -Unique
[System.GC]::Collect();

"Old: " + $OldMethodTime.TotalSeconds;
"New: " + $NewMethodTime.TotalSeconds;

"Total Finders: " + $Finders;
"Unique Finders:" + $UniqueFinders;
"Mem difference old: " + ($memAfterOld - $MemBeforeOld);
"Mem difference new: " + ($memAfterNew - $MemBeforeNew);
$SQLConnection.Close();