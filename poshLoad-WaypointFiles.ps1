set-location C:\Users\andy\Documents\cachedb\posh;
$wpts = get-childitem $env:temp\pqs -file -filter "*wpts.gpx";
foreach ($wpt in $wpts) {
.\import-gpxtodb.ps1 -sqlinstance SQL2014 -Database CacheDB -FileToImport  $wpt.FullName;
}