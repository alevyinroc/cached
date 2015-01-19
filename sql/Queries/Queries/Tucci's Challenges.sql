use cachedb;
SELECT left(c3.cachename,1) as letter
	,l.logdate,
	count(c3.cacheid) as num_found
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
	and left(c3.cachename,1) = 'S'
	group by left(c3.cachename,1),l.logdate
	having count(c3.cacheid) >= 5
	order by 3 desc

/*
H - 5 on 2013-05-27
Z - 5 on 
O - 20 on 
P - 10 on
D - 15 on
A - 15 on
S - 20 on
*/