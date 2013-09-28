create procedure CacheDensity @cacheid varchar(8), @distance int as
begin
	declare @p1 geography;
	SELECT @p1 = latlong from caches where cacheid = @cacheid;
	SELECT count(cacheid) as CacheCount from caches where @p1.STDistance(latlong)/1000 <= @distance and cacheid <> @cacheid;
end;

--exec cachedensity 'GC317NN', 5;