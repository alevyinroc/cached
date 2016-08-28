create procedure dbo.CachesNearCache @CenterPoint varchar(8), @SearchRadius int as
begin
	declare @p1 geography;
SELECT
	@p1 = LatLong
FROM Caches
WHERE CacheId = @CenterPoint;

SELECT
	CacheId
FROM Caches
WHERE @p1.STDistance(LatLong) / 1000 < @SearchRadius;
end;
