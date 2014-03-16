$Coords = Invoke-Sqlcmd -ServerInstance win81 -Database cachedb -query "select latitude,longitude from caches union select latitude,longitude from waypoints";
$ComputedGeoColumnInserts = @("use performancecompare;","set statistics io on;");
$ComputedGeoColumnPersistInserts = @("use performancecompare;","set statistics io on;");
$NoGeoColumnInserts = @("use performancecompare;","set statistics io on;");
$TriggerGeoColumnInserts = @("use performancecompare;","set statistics io on;");
foreach ($CoordSet in $Coords) {
    $ComputedGeoColumnInserts += "insert into ComputedColumn (Latitude, Longitude) values ($($CoordSet.Latitude),$($CoordSet.Longitude));";
    $ComputedGeoColumnPersistInserts += "insert into ComputedColumnPersist (Latitude, Longitude) values ($($CoordSet.Latitude),$($CoordSet.Longitude));";
    $NoGeoColumnInserts += "insert into NoGeoColumn (Latitude, Longitude) values ($($CoordSet.Latitude),$($CoordSet.Longitude));";
    $TriggerGeoColumnInserts += "insert into TriggerGeoColumn (Latitude, Longitude) values ($($CoordSet.Latitude),$($CoordSet.Longitude));";
}

$ComputedGeoColumnInserts | Out-File -FilePath C:\Users\andy\Documents\cachedb\sql\ComputedColumnInserts.sql -Force -Encoding utf8;
$ComputedGeoColumnPersistInserts | Out-File -FilePath C:\Users\andy\Documents\cachedb\sql\ComputedColumnPersistInserts.sql -Force -Encoding utf8;
$NoGeoColumnInserts | Out-File -FilePath C:\Users\andy\Documents\cachedb\sql\NoGeoColumnInserts.sql -Force -Encoding utf8;
$TriggerGeoColumnInserts | Out-File -FilePath C:\Users\andy\Documents\cachedb\sql\TriggerColumnInserts.sql -Force -Encoding utf8;