SET STATISTICS IO ON;

SELECT c3.cachename
	,c2.cacheid
	,l.logdate
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
ORDER BY l.logdate DESC
	,l.logid DESC;

SET STATISTICS IO OFF;

SELECT row_number() over (order by l.logdate asc) as FindNum,c3.cachename,c2.cacheid
	,l.logdate,lt.CountsAsFind,l.logtypeid,lt.logtypedesc,c3.CountryId,c4.Name
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
join countries c4 on c3.CountryId = c4.CountryId
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
ORDER BY l.logdate asc;