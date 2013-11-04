#requires -version 2.0
#Set-StrictMode -Version 2.0
[cmdletbinding()]

param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Path -path $_ -PathType Container})]
	[string]$DirWithPQs = 'C:\Users\andy\Documents\Code\cachedb\scratchpad\'
)

function Expand-ZIPFile {
param (
	$file
	$destination
)
<#
Taken from http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
#>
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($file)
	foreach($item in $zip.items()) 	{
		$shell.Namespace($destination).copyhere($item, 12)
	}
}

function Get-GPXFiles {
[cmdletbinding(SupportsShouldProcess=$true)]
param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Path -path $_ -PathType Container})]
	[string]$DirWithPQs = 'C:\Users\andy\Documents\Code\cachedb\scratchpad\'
)
	$GPXPath = Join-Path -Path $Env:TEMP -ChildPath "PQs";
	New-Item -ItemType Directory -Path $GPXPath | Out-Null;
	while (-not (Test-Path -Path $GPXPath -PathType Container)){
		Start-Sleep -Seconds 1;
	}
	Get-ChildItem -Path $DirWithPQs -Filter *.gpx | Copy-Item -Destination $GPXPath;
	$Zipfiles = Get-ChildItem -Path $DirWithPQs -Filter *.zip;
	foreach ($zip in $Zipfiles) {
		Expand-Zipfile -file $zip.FullName -destination $GPXPath;
	}
	$AllGPXFiles = Get-ChildItem -Path $GPXPath -Filter *.gpx;
	$GPXWithDate = @();
	foreach ($gpx in $AllGPXFiles) {
		$FileTime = (select-string -Path $gpx.FullName -pattern "(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))" -list).Matches[0].value;
		$FileData = New-Object -TypeName PSObject;
		$FileData|Add-Member -Name "FilePath" -Value $gpx.FullName -MemberType NoteProperty;
		$FileData|Add-Member -Name "Timestamp" -Value $FileTime -MemberType NoteProperty;
		$GPXWithDate+=$FileData;
	}
	$GPXWithDate|Sort-Object -Property Timestamp;
}