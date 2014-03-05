$GPXFiles = .\Get-GPXFromPQs.ps1 -DirWithPQs c:\users\andy\Downloads;
$GPXFILES = $GPXFiles |sort timestamp;
foreach ($gpx in $GPXFiles) {
    write-output $gpx.filepath;
	.\import-gpxtodb.ps1 -sqlinstance win81 -Database CacheDB -FileToImport $gpx.filepath;
}