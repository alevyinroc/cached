create procedure dbo.CachesNearCache @CenterPoint varchar(8), @SearchRadius int as
begin
	declare @p1 geography;
SELECT
	@p1 = latlong
FROM caches
WHERE cacheid = @CenterPoint;

SELECT
	CacheId
FROM Caches
WHERE @p1.STDistance(latlong) / 1000 < @SearchRadius;
end;
