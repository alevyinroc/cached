DECLARE @home GEOGRAPHY;

SELECT @home = latlong
FROM CenterPoints
WHERE locationname = 'Home';

--SELECT locationname, @home.STDistance(latlong)/1000 as [Distance from home] from CenterPoints order by [Distance from home];
-- But with Geography data type, we get a Great Circle plot:
--  http://www.gcmap.com/mapui?P=ROC-SEA
-- Shows distance of 2166 miles
SELECT TOP 20 GEOGRAPHY::STGeomFromText('LINESTRING (' + CAST(latlong.Long AS VARCHAR) + ' ' + CAST(latlong.Lat AS VARCHAR) + ', ' + CAST(@home.Long AS VARCHAR) + ' ' + CAST(@home.Lat AS VARCHAR) + ')', latlong.STSrid)
	,@home.STDistance(latlong) / 1000 AS DistFromHomeKM
	,dbo.DistanceInMiles(@home, latlong) AS DistFromHomeMiles
	,cacheid
FROM caches
--where dbo.Bearing(@home,latlong) between 270 and 360 and dbo.Bearing(@home,latlong) between 0 and 90
ORDER BY @home.STDistance(latlong) ASC;

SELECT c2.cachename
	,c2.cacheid
	,c2.latitude
	,c2.longitude
	,c2.latlong
	,logdate
	,logtext
	,c.cachername AS finder
	,lt.logtypedesc AS LogType
	,GEOGRAPHY::STGeomFromText('LINESTRING (' + CAST(c2.latlong.Long AS VARCHAR) + ' ' + CAST(c2.latlong.Lat AS VARCHAR) + ', ' + CAST(@home.Long AS VARCHAR) + ' ' + CAST(@home.Lat AS VARCHAR) + ')', c2.latlong.STSrid) AS LineToCache
FROM caches c2
JOIN cache_logs cl ON c2.cacheid = cl.cacheid
JOIN logs l ON l.logid = cl.logid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cachers c ON l.cacherid = c.cacherid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
ORDER BY l.logdate ASC;

DECLARE @home2 geometry;

SELECT Latitude
	,Longitude
FROM CenterPoints
WHERE locationname = 'Home';

SET @home2 = [geometry]::Point(- 77.306933, 42.885983, 0);

-- TODO: Do distance with geometry instead of geography
SELECT TOP 20 geometry::STGeomFromText('LINESTRING (' + CAST(longitude AS VARCHAR) + ' ' + CAST(latitude AS VARCHAR) + ', ' + CAST(- 77.306933 AS VARCHAR) + ' ' + CAST(42.885983 AS VARCHAR) + ')', 0)
	,cacheid
	--,@home2.STDistance(latlong) AS from_home
FROM caches
ORDER BY cacheid;
