push-location;
import-module sqlps;
pop-location;
$sourcepoints = invoke-sqlcmd -server 'hobbes\sqlexpress' -database 'cachedb' -query 'select latitude,longitude from caches';
$computed = measure-command {
# Test computed column
foreach ($point in $sourcepoints) {
    $importquery = "insert into ComputedColumn (latitude,longitude) values (" + $point.latitude + "," + $point.longitude + ")";
    invoke-sqlcmd -server 'hobbes\sqlexpress' -database 'PerformanceCompare' -query $importquery;
}
}
$computedpersist = measure-command {
# Test computed column persist
foreach ($point in $sourcepoints) {
    $importquery = "insert into ComputedColumnPersist (latitude,longitude) values (" + $point.latitude + "," + $point.longitude + ")";
    invoke-sqlcmd -server 'hobbes\sqlexpress' -database 'PerformanceCompare' -query $importquery;
}
}
$nocolumn = measure-command {
# Test no column
foreach ($point in $sourcepoints) {
    $importquery = "insert into nogeocolumn (latitude,longitude) values (" + $point.latitude + "," + $point.longitude + ")";
    invoke-sqlcmd -server 'hobbes\sqlexpress' -database 'PerformanceCompare' -query $importquery;
}
}
$triggercolumn = measure-command {
# Test triggercolumn
foreach ($point in $sourcepoints) {
    $importquery = "insert into triggergeocolumn (latitude,longitude) values (" + $point.latitude + "," + $point.longitude + ")";
    invoke-sqlcmd -server 'hobbes\sqlexpress' -database 'PerformanceCompare' -query $importquery;
}}
"Computed column: " + $computed.totalseconds;
"Computed column persisted: " + $computedpersist.totalseconds;
"No geo column: " + $nocolumn.totalseconds;
"Trigger column: " + $triggercolumn.totalseconds;
remove-module sqlps;