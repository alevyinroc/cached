create procedure dbo.CachesNearCache @centerpoint varchar(8), @searchradius int as
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
