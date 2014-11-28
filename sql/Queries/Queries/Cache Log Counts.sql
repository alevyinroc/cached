SELECT c.cacheid
	,lt.logtypedesc
	,count(l.logid) AS LogCount
	,lt.CountsAsFind
FROM caches c
JOIN cache_logs cl ON c.cacheid = cl.cacheid
JOIN logs l ON l.logid = cl.logid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
GROUP BY c.placed
	,c.cacheid
	,lt.logtypedesc
	,lt.CountsAsFind
ORDER BY c.cacheid
	,lt.CountsAsFind DESC;
	/*
select * from log_types

select cacheid, [0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16] from (
select c.cacheid,lt.logtypedesc,count(l.logid) as LogCount from caches c join cache_logs cl on c.cacheid = cl.cacheid join logs l on l.logid = cl.logid join log_types lt on l.logtypeid = lt.logtypeid group by c.placed,c.cacheid,lt.logtypedesc,lt.CountsAsFind) as LogCounts
pivot(logtypedesc)
for logtypedesc in (logtypedesc)
;
*/
