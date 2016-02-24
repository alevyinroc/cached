IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetFindsByCacherName')
   exec('CREATE PROCEDURE [dbo].[GetFindsByCacherName] AS BEGIN SET NOCOUNT ON; END')
GO

alter procedure [dbo].GetFindsByCacherName (@cacher nvarchar(50)) as
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
	AND lt.countsasfind = 1
ORDER BY l.logdate DESC
	,l.logid DESC;
	end