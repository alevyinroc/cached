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
[System.GC]::Collect();
# Old Way
$OldMethodTime = Measure-Command{
$MemBeforeOld = (get-process -pid $pid|select -expandproperty vm)/1MB;
$Geocaches = $cachedata.gpx.wpt | where-object{$_.type.split(" | ")[0] -eq "Geocache"};
$AttrCount = 0;
 $Geocaches | ForEach-Object {
	$GCNum = $_.name;
	if ($_.cache.attributes.attribute.Count -gt 0) {
		$AllAttributes = New-Object -TypeName System.Collections.Generic.List[PSObject];
		$_.cache.attributes.attribute | ForEach-Object {
			$AttrCount++;
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
$MemAfterOld = (get-process -pid $pid|select -expandproperty vm)/1MB;
}

Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "delete from attributes;";
[System.GC]::Collect();
Write-Verbose "First pass complete";
# New Way
$NewMethodTime = Measure-Command{
$MemBeforeNew = (get-process -pid $pid|select -expandproperty vm)/1MB;
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
$AllAttribsColl | Sort-Object attrid,attrname -Unique | New-Attribute
$MemAfterNew = (get-process -pid $pid|select -expandproperty vm)/1MB;
}
Write-Verbose "Second pass complete";

#$NewMethod2Time = Measure-Command{
#	$cachedata.gpx.wpt.cache.attributes.attribute|Select-Object -Property id,"#text"|Sort-Object -property id,"#text" -unique| New-Attribute
#}

#$gpx.gpx.wpt|?{$_.type.split(" | ")[0] -eq "Geocache"}|select -expandproperty cache|?{$_.attributes.attribute -ne $null}|select -expandproperty attributes|select -expandproperty attribute |select "#text",id|sort id,"#text" -Unique
[System.GC]::Collect();
$NewMethod2Time = Measure-Command{
$MemBeforeNew2 = (get-process -pid $pid|select -expandproperty vm)/1MB;
	$Geocaches|Select-Object -expandproperty cache|where-object{$_.attributes.attribute -ne $null}|Select-Object -expandproperty attributes|Select-Object -expandproperty attribute |Select-Object @{Name="attrname";expression={$_."#text"}},@{Name="attrid";expression={$_.id}}|Sort-Object attrname,attrid -Unique | New-Attribute;
$MemAfterNew2 = (get-process -pid $pid|select -expandproperty vm)/1MB;
}


"Old: " + $OldMethodTime.TotalSeconds;
"New: " + $NewMethodTime.TotalSeconds;
"New2: " + $NewMethod2Time.TotalSeconds;

"Total Attributes: " + $AttrCount;
"Unique Attributes:" + $($AllAttribsColl|Sort-Object attrid,attrname -Unique).Count;
"Mem difference old: " + ($memAfterOld - $MemBeforeOld);
"Mem difference new: " + ($memAfterNew - $MemBeforeNew);
"Mem difference new2: " + ($memAfterNew2 - $MemBeforeNew2);
$SQLConnection.Close();