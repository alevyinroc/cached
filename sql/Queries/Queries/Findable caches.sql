DECLARE @home GEOGRAPHY;

SELECT @home = latlong
FROM CenterPoints
WHERE locationname = 'Home';

SELECT pt.typename
	,c2.cachename
	,c2.cacheid
	,@home.STDistance(c2.latlong) AS DistFromHome
	,c2.latlong
FROM caches c2
JOIN point_types pt ON c2.typeid = pt.typeid
WHERE @home.STDistance(c2.latlong) / 1000 <= 50
	AND c2.cacheid NOT IN (
		SELECT c2.cacheid
		FROM logs l
		JOIN cachers c ON c.cacherid = l.cacherid
		JOIN log_types lt ON l.logtypeid = lt.logtypeid
		JOIN cache_logs c2 ON c2.logid = l.logid
		JOIN caches c3 ON c2.cacheid = c3.cacheid
		WHERE c.cachername = 'dakboy'
			AND lt.countsasfind = 1
		)
ORDER BY DistFromHome;
