SET STATISTICS IO ON;

SELECT ROW_NUMBER() OVER (
		ORDER BY l.logid
		) AS findnum
	,ROW_NUMBER() OVER (
		PARTITION BY logdate ORDER BY l.logid
		) AS find_of_the_day
	,c2.cacheid
	,c3.cachename
	,l.logdate
	,c3.placed
	,DATEDIFF(d, c3.placed, l.logdate) AS [Days After Placed]
	,AVG(DATEDIFF(d, c3.placed, l.logdate)) OVER (
		ORDER BY l.logdate rows unbounded preceding
		) AS [Moving average age of cache at find]
	,DATEDIFF(d, c3.placed, getdate()) AS [Current Age of Cache]
	,avg(DATEDIFF(d, c3.placed, getdate())) OVER (
		ORDER BY l.logdate rows unbounded preceding
		) AS [Moving average age of cache]
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
--order by [Current Age of Cache]
--order by [Days After Placed]
ORDER BY l.logdate
	,l.logid;

SET STATISTICS IO OFF;
