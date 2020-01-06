use Geocaches;
go
create or alter procedure CacheDensity
	@cacheid varchar(8),
	@distance int
as
begin
	declare @p1 geography;
	SELECT @p1 = latlong
	from caches
	where cacheid = @cacheid;
	SELECT count(cacheid) as CacheCount
	from caches
	where @p1.STDistance(latlong)/1000 <= @distance and cacheid <> @cacheid;
end;
go

create or alter procedure CachesNearCache
	@centerpoint varchar(8),
	@searchradius int
as
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
go