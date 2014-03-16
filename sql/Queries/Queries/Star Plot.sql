declare @home geography;
SELECT @home = latlong from CenterPoints where locationname='Home';
--SELECT locationname, @home.STDistance(latlong)/1000 as [Distance from home] from CenterPoints order by [Distance from home];

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
	  dbo.DistanceInMiles(@home,latlong) as DistFromHomeMiles,
	  cacheid
FROM caches
--where dbo.Bearing(@home,latlong) between 270 and 360 and dbo.Bearing(@home,latlong) between 0 and 90
order by @home.STDistance(latlong) asc
;

SELECT
	c2.cachename, c2.cacheid,c2.latitude,c2.longitude, c2.latlong,logdate, logtext, c.cachername as finder, lt.logtypedesc as LogType,
	geography::STGeomFromText(
	'LINESTRING ('
	  +CAST(c2.latlong.Long AS VARCHAR)
	  +' '
	  +CAST(c2.latlong.Lat AS VARCHAR)
	  +', '
	  +CAST(@home.Long AS VARCHAR)
	  +' '
	  +CAST(@home.Lat AS VARCHAR) 
	  +')'	  
	  ,c2.latlong.STSrid) as LineToCache
from
	caches c2
	join cache_logs cl on c2.cacheid = cl.cacheid
	join logs l on l.logid = cl.logid
	JOIN log_types lt on l.logtypeid = lt.logtypeid
	JOIN cachers c on l.cacherid = c.cacherid
where
	c.cachername = 'dakboy' AND lt.countsasfind = 1
ORDER BY
	l.logdate asc;

declare @home2 geometry;

SELECT Latitude,Longitude from CenterPoints where locationname='Home';
SET @home2 = [geometry]::Point(-77.306933,42.885983,0);
-- TODO: Do distance with geometry instead of geography
SELECT top 20 geometry::STGeomFromText(
	'LINESTRING ('
	  +CAST(longitude AS VARCHAR)
	  +' '
	  +CAST(latitude AS VARCHAR)
	  +', '
	  +CAST(-77.306933 AS VARCHAR)
	  +' '
	  +CAST(42.885983 AS VARCHAR) 
	  +')'	  
	  ,0),
	  cacheid
FROM caches
order by cacheid
;