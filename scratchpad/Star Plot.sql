declare @home geography;
SELECT @home = latlong from CenterPoints where locationname='Home';
--SELECT locationname, @home.STDistance(latlong)/1000 as [Distance from home] from CenterPoints order by [Distance from home];

SELECT top 150 Geography::STGeomFromText(
	'LINESTRING ('
	  +CAST(latlong.Long AS VARCHAR)
	  +' '
	  +CAST(latlong.Lat AS VARCHAR)
	  +', '
	  +CAST(@home.Long AS VARCHAR)
	  +' '
	  +CAST(@home.Lat AS VARCHAR) 
	  +')'	  
	  ,latlong.STSrid)
FROM caches
order by @home.STDistance(latlong)