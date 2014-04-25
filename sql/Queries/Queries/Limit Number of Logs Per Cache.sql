use CacheDB;
--SELECT * FROM caches c join cache_logs cl on c.cacheid = cl.cacheid JOIN logs l on cl.logid = l.logid JOIN cachers c2 on c2.cacherid = l.cacherid where c2.cachername = 'dakboy';

declare @home geography;
SELECT @home = latlong from CenterPoints where locationname='Home';

--SELECT cacheid,latlong from caches where @home.STDistance(latlong)/1000 <= 50;

SELECT * from (
SELECT
	c2.cachename, c2.cacheid,logdate, logtext, c.cachername as finder, lt.logtypedesc as LogType,@home.STDistance(c2.latlong) as DistFromHome
	,ROW_NUMBER() OVER(PARTITION BY c2.cacheid ORDER BY l.logdate DESC) as CacheLogNum
from
	caches c2
	join cache_logs cl on c2.cacheid = cl.cacheid
	join logs l on l.logid = cl.logid
	JOIN log_types lt on l.logtypeid = lt.logtypeid
	JOIN cachers c on l.cacherid = c.cacherid
where
	--c2.cacheid = 'GC38VEC'
	@home.STDistance(c2.latlong)/1000 <= 50
	and c2.cacheid not in (SELECT c2.cacheid
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1)
/*ORDER BY
	@home.STDistance(c2.latlong),
	l.logdate DESC*/
) A where cachelognum <= 5
order by A.DistFromHome,A.logdate
;