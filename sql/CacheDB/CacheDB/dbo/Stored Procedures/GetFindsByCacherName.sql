
CREATE procedure [dbo].GetFindsByCacherName (@cacher nvarchar(50)) as
begin
set nocount on;

SELECT c3.CacheName
	,c2.CacheId
	,l.LogDate
FROM Logs l
JOIN Cachers c ON c.CacherId = l.CacherId
JOIN LogTypes lt ON l.logtypeid = lt.logtypeid
JOIN CacheLogs c2 ON c2.LogId = l.LogId
JOIN Caches c3 ON c2.CacheId = c3.CacheId
WHERE c.CacherName = @cacher
	AND lt.CountsAsFind = 1
ORDER BY l.LogDate DESC
	,l.LogId DESC;
	end