IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'CacheDensity')
   exec('CREATE PROCEDURE [dbo].[CacheDensity] AS BEGIN SET NOCOUNT ON; END')
GO

alter procedure CacheDensity @cacheid varchar(8), @distance int as
begin
	declare @p1 geography;
	SELECT @p1 = latlong from caches where cacheid = @cacheid;
	SELECT count(cacheid) as CacheCount from caches where @p1.STDistance(latlong)/1000 <= @distance and cacheid <> @cacheid;
end;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'CachesNearCache')
   exec('CREATE PROCEDURE [dbo].[CachesNearCache] AS BEGIN SET NOCOUNT ON; END')
GO

alter procedure CachesNearCache @centerpoint varchar(8), @searchradius int as
begin
	declare @p1 geography;
SELECT
	@p1 = latlong
FROM caches
WHERE cacheid = @centerpoint;

SELECT
	cacheid
FROM caches
WHERE @p1.STDistance(latlong) / 1000 < @searchradius;
end;