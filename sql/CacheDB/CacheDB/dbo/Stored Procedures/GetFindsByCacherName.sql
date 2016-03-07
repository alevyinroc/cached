
CREATE procedure [dbo].GetFindsByCacherName (@cacher nvarchar(50)) as
begin
set nocount on;

SELECT c3.cachename
	,c2.cacheid
	,l.logdate
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = @cacher
	AND lt.CountsAsFind = 1
ORDER BY l.logdate DESC
	,l.logid DESC;
	end