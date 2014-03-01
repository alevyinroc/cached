#$GPXFiles = .\Get-GPXFromPQs.ps1 -DirWithPQs C:\Users\andy\Documents\Code\cachedb\scratchpad\zip;
$GPXFILES = $GPXFiles |sort timestamp;
foreach ($gpx in $GPXFiles) {
#	.\import-gpxtodb.ps1 -sqlinstance hobbes\sqlexpress -Database CacheDB -FileToImport $gpx.filepath;
}

$gpxfiles = get-childitem -path C:\Users\andy\AppData\Local\Temp\PQs;
$GPXFILES = $GPXFiles |sort lastwritetime;
foreach ($gpx in $GPXFiles) {
	.\import-gpxtodb.ps1 -sqlinstance hobbes\sqlexpress -Database CacheDB -FileToImport $gpx.fullname;
}