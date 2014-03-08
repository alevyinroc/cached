SELECT * FROM caches order by lastupdated desc;
SELECT * from caches where cacheid = 'GC4FM6X';
SELECT * FROM cachers;
SELECT * from cache_attributes where cacheid = 'GC49CX9';
SELECT * from cache_owners;
SELECT * from logs;
SELECT * from log_types;
SELECT * from cache_logs;
SELECT * from tbinventory;
SELECT * from travelbugs;
SELECT * from cache_sizes;
SELECT * from point_types;
SELECT * FROM waypoints;
select * from attributes;

select * from travelbugs tb JOIN tbinventory tbi on tb.tbpublicid = tbi.tbpublicid WHERE tbi.cacheid= 'GC103Q1';
--SELECT * from attributes a JOIN cache_attributes ca ON a.attributeid = ca.attributeid where ca.cacheid = 'GC103Q1';
select * from travelbugs;
SELECT cacheid, count(tbpublicid) from tbinventory group BY cacheid ORDER by COUNT(tbpublicid) desc;

exec sp_updatestats;

SELECT
	c2.cachename, c2.cacheid,c2.latitude,c2.longitude, c2.latlong,logdate, logtext, c.cachername as finder, lt.logtypedesc as LogType
from
	caches c2
	join cache_logs cl on c2.cacheid = cl.cacheid
	join logs l on l.logid = cl.logid
	JOIN log_types lt on l.logtypeid = lt.logtypeid
	JOIN cachers c on l.cacherid = c.cacherid
where
	c.cachername = 'dakboy' AND lt.logtypedesc = 'Found it'
ORDER BY
	l.logdate asc;