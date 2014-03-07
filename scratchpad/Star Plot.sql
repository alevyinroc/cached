declare @home geography;
SELECT @home = latlong from CenterPoints where locationname='Home';
--SELECT locationname, @home.STDistance(latlong)/1000 as [Distance from home] from CenterPoints order by [Distance from home];
-- TODO: Do distance with geometry instead of geography
SELECT top 20 geometry::STGeomFromText(
	'LINESTRING ('
	  +CAST(latlong.Long AS VARCHAR)
	  +' '
	  +CAST(latlong.Lat AS VARCHAR)
	  +', '
	  +CAST(@home.Long AS VARCHAR)
	  +' '
	  +CAST(@home.Lat AS VARCHAR) 
	  +')'	  
	  ,latlong.STSrid),
	  @home.STDistance(latlong)/1000 as DistFromHomeKM,
	  ((@home.STDistance(latlong)/1000) * 0.62137) as DistFromHomeMiles,
	  cacheid
FROM caches
order by @home.STDistance(latlong) desc
;

-- But with Geography data type, we get a Great Circle plot:
--  http://www.gcmap.com/mapui?P=ROC-SEA
-- Shows distance of 2166 miles

SELECT top 20 geography::STGeomFromText(
	'LINESTRING ('
	  +CAST(latlong.Long AS VARCHAR)
	  +' '
	  +CAST(latlong.Lat AS VARCHAR)
	  +', '
	  +CAST(@home.Long AS VARCHAR)
	  +' '
	  +CAST(@home.Lat AS VARCHAR) 
	  +')'	  
	  ,latlong.STSrid),
	  @home.STDistance(latlong)/1000 as DistFromHomeKM,
	  ((@home.STDistance(latlong)/1000) * 0.62137) as DistFromHomeMiles,
	  cacheid
FROM caches
order by @home.STDistance(latlong) desc
;