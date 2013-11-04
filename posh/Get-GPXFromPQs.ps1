#requires -version 2.0
#Set-StrictMode -Version 2.0
[cmdletbinding()]

param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Path -path $_ -PathType Container})]
	[string]$DirWithPQs = 'C:\Users\andy\Documents\Code\cachedb\scratchpad\'
)

function Expand-ZIPFile($file, $destination)
<#
Taken from http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
#>
{
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($file)
	foreach($item in $zip.items()) 	{
		$shell.Namespace($destination).copyhere($item, 12)
	}
}

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
	[xml]$cachedata = Get-Content $gpx.FullName;
	$FileData = New-Object -TypeName PSObject;
	$FileData|Add-Member -Name "FilePath" -Value $gpx.FullName -MemberType NoteProperty;
	$FileData|Add-Member -Name "Timestamp" -Value $cachedata.gpx.time -MemberType NoteProperty;
	$GPXWithDate+=$FileData;
}
$GPXWithDate|Sort-Object -Property Timestamp;