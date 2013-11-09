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
	$file,
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
	if (-not (Test-Path -Path $GPXPath -PathType Container)) {
		New-Item -ItemType Directory -Path $GPXPath | Out-Null;
	}
	while (-not (Test-Path -Path $GPXPath -PathType Container)){
		Start-Sleep -Seconds 1;
	}
	Get-ChildItem -Path $DirWithPQs -Filter *.gpx | Copy-Item -Destination $GPXPath;
	Get-ChildItem -Path $DirWithPQs -Filter *.zip | foreach {Expand-Zipfile -file $_.FullName -destination $GPXPath;};
	$AllGPXFiles = Get-ChildItem -Path $GPXPath -Filter *.gpx;
	$GPXWithDate = @();
	foreach ($gpx in $AllGPXFiles) {
	# Not using DateTimeOffset here because we're not concerned about the exact time, just the relative times.
	# Todo: Find more efficient way to search large files
		$FileTime = (select-string -Path $gpx.FullName -pattern "(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))" -list).Matches[0].value;
		$FileData = New-Object -TypeName PSObject -Property @{
			FilePath = $gpx.FullName
			Timestamp =  $FileTime	
		};
		$GPXWithDate+=$FileData;
	}
	$GPXWithDate|Sort-Object -Property Timestamp;
}

Get-GPXFiles -DirWithPQs $DirWithPQs;