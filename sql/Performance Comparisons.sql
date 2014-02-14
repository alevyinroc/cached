SET NOCOUNT OFF;
SET STATISTICS IO ON;
SET statistics TIME ON;
--select latitude,longitude from Geocaches.dbo.caches;

insert INTO PerformanceCompare.dbo.Computedcolumn (latitude,longitude) select latitude,longitude from Geocaches.dbo.caches;
insert INTO PerformanceCompare.dbo.ComputedColumnPersist (latitude,longitude) select latitude,longitude from Geocaches.dbo.caches;
insert INTO PerformanceCompare.dbo.NoGeoColumn (latitude,longitude) select latitude,longitude from Geocaches.dbo.caches;
insert INTO PerformanceCompare.dbo.TriggerGeoColumn (latitude,longitude) select latitude,longitude from Geocaches.dbo.caches;
SET STATISTICS IO OFF;
SET statistics TIME Off;

SELECT * from PerformanceCompare.dbo.ComputedColumn;
SELECT * from PerformanceCompare.dbo.ComputedColumnPersist;
/*TRUNCATE table PerformanceCompare.dbo.computedcolumn;
TRUNCATE table PerformanceCompare.dbo.computedcolumnpersist;
TRUNCATE table PerformanceCompare.dbo.nogeocolumn;
TRUNCATE table PerformanceCompare.dbo.triggergeocolumn;
*/