CREATE PROCEDURE [dbo].[CacheDensity]
	@CacheId varchar(8), @Distance int
AS
	declare @p1 geography;
SELECT
	@p1 = LatLong
FROM Caches
WHERE CacheId = @CacheId;
SELECT
	COUNT(CacheId) AS CacheCount
FROM Caches
WHERE @p1.STDistance(LatLong) / 1000 <= @Distance AND CacheId <> @CacheId;
