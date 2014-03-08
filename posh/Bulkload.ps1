$GPXFiles = .\Get-GPXFromPQs.ps1 -DirWithPQs c:\users\andy\Downloads;
$GPXFILES = $GPXFiles |sort timestamp;
foreach ($gpx in $GPXFiles|Where-Object {$_.filepath -notlike "*-wpts.gpx"}) {
    write-output $gpx.filepath;
	.\import-gpxtodb.ps1 -sqlinstance win81 -Database CacheDB -FileToImport $gpx.filepath;
}
foreach ($gpx in $GPXFiles|Where-Object {$_.filepath -like "*-wpts.gpx"}) {
    write-output $gpx.filepath;
	.\import-gpxtodb.ps1 -sqlinstance win81 -Database CacheDB -FileToImport $gpx.filepath;
}