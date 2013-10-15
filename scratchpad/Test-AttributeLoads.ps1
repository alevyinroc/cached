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

[xml]$cachedata = get-content $FileToImport;
[system.Xml.XmlNamespaceManager]$namespaces = New-Object -TypeName system.Xml.XmlNamespaceManager $cachedata.NameTable;
$namespaces.AddNamespace("groundspeak", $cachedata.DocumentElement.NamespaceURI);
Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from attributes;";

# Old Way
$OldMethodTime = Measure-Command{
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};

 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	if ($_.cache.attributes.attribute.Count -gt 0) {
		$AllAttributes = New-Object -TypeName System.Collections.Generic.List[PSObject];
		$_.cache.attributes.attribute | ForEach-Object {
			$CacheAttribute = New-Object -TypeName PSObject -Property @{
				AttrId = $_.id
				AttrName = $_."#text"
				ParentCache = $GCNum
			};
			$AllAttributes.Add($CacheAttribute);
		};
		
		$AllAttributes | New-Attribute;
	}
}
}
Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from attributes;";

# New Way
$NewMethodTime = Measure-Command{
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};
$AllAttribsColl = New-Object -TypeName System.Collections.Generic.List[PSObject];
 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	if ($_.cache.attributes.attribute.Count -gt 0) {
		$AllAttributes = New-Object -TypeName System.Collections.Generic.List[PSObject];
		$_.cache.attributes.attribute | ForEach-Object {
			$CacheAttribute = New-Object -TypeName PSObject -Property @{
				AttrId = $_.id
				AttrName = $_."#text"
				ParentCache = $GCNum
			};
			$AllAttribsColl.Add($CacheAttribute);
		};
	}
}
$AllAttribsColl|Sort-Object -Unique | New-Attribute;
}

"Old: " + $OldMethodTime.TotalSeconds;
"New: " + $NewMethodTime.TotalSeconds;

"Total Attributes: " + $($AllAttributes|sort -unique).Count;
"Unique Attributes:" + $AllAttribsColl.Count;
$SQLConnection.Close();