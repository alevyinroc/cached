SELECT * FROM caches order by lastupdated desc;
SELECT * FROM cachers;
SELECT * from cache_attributes;
SELECT * from cache_owners;
SELECT * from logs;
SELECT * from log_types;
SELECT * from cache_logs;
SELECT * from tbinventory;
SELECT * from travelbugs;
SELECT * from cache_sizes;

SELECT
	c2.cachename, c2.cacheid,l.latitude,l.longitude, l.latlong,logdate, logtext, c.cachername as finder, lt.logtypedesc as LogType
from
	caches c2
	join cache_logs cl on c2.cacheid = cl.cacheid
	join logs l on l.logid = cl.logid
	JOIN log_types lt on l.logtypeid = lt.logtypeid
	JOIN cachers c on l.cacherid = c.cacherid
where
	c2.cacheid = 'GC38VEC'
ORDER BY
	l.logdate desc;

/*DELETE from tbinventory;
delete from logs;
DELETE from cache_owners;
delete from caches;
DELETE FROM cachers;
delete from cache_attributes;
delete from attributes;

alter database geocaches set single_user;
alter database geocaches set multi_user;*/