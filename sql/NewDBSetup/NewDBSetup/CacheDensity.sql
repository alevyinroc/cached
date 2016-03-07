CREATE PROCEDURE [dbo].[CacheDensity]
	@cacheid varchar(8), @distance int
AS
	declare @p1 geography;
SELECT
	@p1 = latlong
FROM caches
WHERE cacheid = @cacheid;
SELECT
	COUNT(cacheid) AS CacheCount
FROM caches
WHERE @p1.STDistance(latlong) / 1000 <= @distance AND cacheid <> @cacheid;
