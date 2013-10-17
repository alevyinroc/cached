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
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="SingleTBObject")]
	[PSObject[]]$TB,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitTBDetails")]
	[int]$TBId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitTBDetails")]
	[string]$TBPublicId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitTBDetails")]
	[string]$TBName
)
	begin {
		$TBCheckCmd = $SQLConnection.CreateCommand();
		$TBCheckCmd.CommandText = "select count(1) as tbexists from travelbugs where tbinternalid = @tbid";
		$TBCheckCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int) | Out-Null;
		$TBCheckCmd.Prepare();

		$TBCmd = $SQLConnection.CreateCommand();
		$TBCmd.CommandText = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (@tbid, @tbpublicid, @tbname)";
		$TBCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int) | Out-Null;
		$TBCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$TBCmd.Parameters.Add("@tbname", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
	}
	process {
		switch ($PsCmdlet.ParameterSetName) {
			"SingleTBObject" {
				$TBId = $TB | select-object -expandproperty InternalId;
				$TBPublicId= $TB | select-object -expandproperty PublicId;
				$TBName= $TB | select-object -expandproperty TBName;
			}
		}
		$TBCheckCmd.Parameters["@tbid"].Value = $TBId;
		$TBExists = $TBCheckCmd.ExecuteScalar();
		if (!$TBExists) {
			$TBCmd.CommandText = "update travelbugs set tbpublicid = @tbpublicid ,tbname = @tbname where tbinternalid = @tbid;";
		} else {
			$TBCmd.CommandText = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (@tbid, @tbpublicid, @tbname)";
		}
		
		$TBCmd.Parameters["@tbid"].Value = $TBId;
		$TBCmd.Parameters["@tbname"].Value = $TBName;
		$TBCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
		$TBCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$TBCheckCmd.Dispose();
		$TBCmd.Dispose();
	}
}

[xml]$cachedata = get-content $FileToImport;
[system.Xml.XmlNamespaceManager]$namespaces = New-Object -TypeName system.Xml.XmlNamespaceManager $cachedata.NameTable;
$namespaces.AddNamespace("groundspeak", $cachedata.DocumentElement.NamespaceURI);
Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from travelbugs;";

# Old Way
$OldMethodTime = Measure-Command{
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};
 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	if ($_.cache.travelbugs.travelbug.Count -gt 0) {
		$_.cache.travelbugs.travelbug | ForEach-Object {
			New-TravelBug -TBPublicId $_.ref -TBName $_.name -TBId $_.id;
		}
	}
}
}
Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from travelbugs;";

# New Way
$NewMethodTime = Measure-Command{
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};
$AllTBsColl = New-Object -TypeName System.Collections.Generic.List[PSObject];

 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	if ($_.cache.travelbugs.travelbug.Count -gt 0) {
		$_.cache.travelbugs.travelbug | ForEach-Object {
			$TravelBug = New-Object -TypeName PSObject -Property @{
				InternalId = $_.id
				TBName = $_.name
				PublicId = $_.ref
			};
			$AllTBsColl.Add($TravelBug);
		};
	}
}
$AllTBsColl | Sort-Object TBName,PublicId,InternalId -Unique | New-TravelBug;
}


$NewMethod2Time = Measure-Command{
	#$cachedata.gpx.wpt.cache.travelbugs.travelbug|Select-Object -Property id,"#text"|Sort-Object -property id,"#text" -unique| New-Attribute
}

"Old: " + $OldMethodTime.TotalSeconds;
"New: " + $NewMethodTime.TotalSeconds;
"New2: " + $NewMethod2Time.TotalSeconds;

"Total Attributes: " + $AttrCount;
"Unique Attributes:" + $($AllTBsColl | Sort-Object TBName,PublicId,InternalId -Unique).Count;
$SQLConnection.Close();