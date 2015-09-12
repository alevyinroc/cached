dbcc freeproccache;;
dbcc dropcleanbuffers;

SET NOCOUNT OFF;
--SET STATISTICS IO ON;
--SET statistics TIME ON;
----select latitude,longitude from Geocaches.dbo.caches;
--select COUNT(*) from CacheDB.dbo.caches;
SET STATISTICS IO OFF;
SET statistics TIME Off;
insert INTO PerformanceCompare.dbo.Computedcolumn (latitude,longitude) select latitude,longitude from CacheDB.dbo.caches;
insert INTO PerformanceCompare.dbo.ComputedColumnPersist (latitude,longitude) select latitude,longitude from CacheDB.dbo.caches;
insert INTO PerformanceCompare.dbo.NoGeoColumn (latitude,longitude) select latitude,longitude from CacheDB.dbo.caches;
insert INTO PerformanceCompare.dbo.TriggerGeoColumn (latitude,longitude) select latitude,longitude from CacheDB.dbo.caches;
--SET STATISTICS IO OFF;
--SET statistics TIME Off;

SET STATISTICS IO ON;
--SET statistics TIME ON;
print 'computed'
SELECT latlong from PerformanceCompare.dbo.ComputedColumn;
print 'computedpersist';
SELECT latlong from PerformanceCompare.dbo.ComputedColumnPersist;
print 'trigger';
SELECT latlong from PerformanceCompare.dbo.TriggerGeoColumn;
/* Aha! The trigger doesn't work with the bulk-insert I'm doing above! */
print 'nogeo';
SELECT performancecompare.dbo.GeoPoint(latitude,longitude) from PerformanceCompare.dbo.NoGeoColumn;
/*TRUNCATE table PerformanceCompare.dbo.computedcolumn;
TRUNCATE table PerformanceCompare.dbo.computedcolumnpersist;
TRUNCATE table PerformanceCompare.dbo.nogeocolumn;
TRUNCATE table PerformanceCompare.dbo.triggergeocolumn;
*/