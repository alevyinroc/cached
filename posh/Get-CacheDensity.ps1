<#
#>

#requires -version 2.0
clear-host;
$Error.Clear();
Push-Location;
if ((Get-Module|where-object{$_.name -eq "sqlps"}|Measure-Object).count -lt 1){
	Import-Module sqlps;
}
Pop-Location;
$AllCaches = invoke-sqlcmd "select cacheid from caches;" -server hobbes\sqlexpress -database geocaches|Select-Object -ExpandProperty cacheid;
$CacheListing = @();
foreach ($cache in $AllCaches) {
	$Record = New-Object PSObject;
	$Record | Add-Member -Name "CacheId" -MemberType NoteProperty -Value $cache;
	$CacheCount = Invoke-sqlcmd -server hobbes\sqlexpress -database geocaches -query "EXEC CacheDensity '$cache', 2;" | Select-Object -ExpandProperty CacheCount;
	$Record | Add-Member -Name "CountNearby" -MemberType NoteProperty -Value $CacheCount;
	$CacheListing += $Record;
}
$CacheListing |Sort-Object -Property countnearby -Descending |Select-Object -First 5 | Format-Table -AutoSize;
remove-module sqlps;