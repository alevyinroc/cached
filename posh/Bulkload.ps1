Clear-Host;
Remove-Item -Force -Path C:\Users\andy\AppData\Local\Temp\PQs -Confirm -Recurse
$GPXFiles = .\Get-GPXFromPQs.ps1 -DirWithPQs c:\users\andy\Downloads\PQs;
$GPXFILES = $GPXFiles |sort timestamp;
$filesprocessed = 0;
$cachefiles = $GPXFiles|Where-Object {$_.filepath -notlike "*-wpts.gpx"};
$wptfiles = $GPXFiles|Where-Object {$_.filepath -like "*-wpts.gpx"};

foreach ($gpx in $cachefiles) {
    $filesprocessed++;
    Write-Progress -Activity "Processing cache files" -Status "Filename $($gpx.name)" -Id 1 -PercentComplete $(($filesprocessed/$cachefiles.Count)*100);
    write-output $gpx.filepath;
	.\import-gpxtodb.ps1 -sqlinstance win81 -Database CacheDB -FileToImport $gpx.filepath;
}
$filesprocessed = 0;
foreach ($gpx in $wptfiles) {
    $filesprocessed++;
    Write-Progress -Activity "Processing waypoint files" -Status "Filename $($gpx.name)" -Id 1 -PercentComplete $(($filesprocessed/$wptfiles.Count)*100);
    write-output $gpx.filepath;
	.\import-gpxtodb.ps1 -sqlinstance win81 -Database CacheDB -FileToImport $gpx.filepath;
}