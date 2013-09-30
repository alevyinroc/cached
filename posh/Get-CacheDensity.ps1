<#
#>
#requires -version 2.0
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[int]$DensityRadius,
	[Parameter(Mandatory=$false,ParameterSetName="CenteredSearch")]
	[int]$SearchRadius,
	[Parameter(Mandatory=$false,ParameterSetName="CenteredSearch")]
	[string]$SearchCenter,
	[Parameter(Mandatory=$false)]
	[ValidateScript({Test-Connection -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$false)]
	[string]$Database = 'Geocaches'
)
Clear-Host;
$Error.Clear();
Push-Location;
if ((Get-Module|Where-Object{$_.name -eq "sqlps"}|Measure-Object).count -lt 1){
	Import-Module sqlps;
}
Pop-Location;
switch ($PsCmdlet.ParameterSetName) {
	"CenteredSearch" {
		$AllCaches = Invoke-sqlcmd "exec CachesNearCache '$SearchCenter', $SearchRadius" -ServerInstance $SQLInstance -Database $Database | Select-Object -ExpandProperty cacheid;
	}
}
$AllCaches = Invoke-sqlcmd "select cacheid from caches;" -ServerInstance $SQLInstance -Database $Database | Select-Object -ExpandProperty cacheid;
$CacheListing = @();
foreach ($cache in $AllCaches) {
	$Record = New-Object PSObject;
	$Record | Add-Member -Name "CacheId" -MemberType NoteProperty -Value $cache;
	$CacheCount = Invoke-sqlcmd -server hobbes\sqlexpress -database geocaches -query "EXEC CacheDensity '$cache', $DensityRadius;" | Select-Object -ExpandProperty CacheCount;
	$Record | Add-Member -Name "CountNearby" -MemberType NoteProperty -Value $CacheCount;
	$CacheListing += $Record;
}
[System.GC]::Collect();
$CacheListing | Sort-Object -Property CountNearby -Descending |Select-Object -First 5 | Format-Table -AutoSize;
Remove-Module sqlps;