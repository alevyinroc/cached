SELECT cacheid,logdate
	,GEOGRAPHY::STGeomFromText('LINESTRING (' + CAST(prevlatlong.Long AS VARCHAR) + ' ' + CAST(prevlatlong.Lat AS VARCHAR) + ', ' + CAST(latlong.Long AS VARCHAR) + ' ' + CAST(latlong.Lat AS VARCHAR) + ')', latlong.STSrid) AS travel
FROM (
	SELECT cacheid
		,latlong
		,(
			SELECT p.latlong
			FROM caches p
			JOIN cache_logs cl ON p.cacheid = cl.cacheid
			JOIN logs l ON l.logid = cl.logid
			JOIN cachers c ON c.cacherid = l.cacherid
			JOIN log_types lt ON l.logtypeid = lt.logtypeid
			WHERE l.logid = f.prevlogid
				AND c.cachername = 'dakboy'
				AND lt.countsasfind = 1
			) AS PrevLatLong
		,logdate
		,logid
	FROM (
		SELECT c3.latlong
			,c3.cachename
			,c2.cacheid
			,l.logdate
			,lt.logtypedesc
			,l.logid
			,lag(l.logid, 1, 0) OVER (
				ORDER BY l.logid
				) AS prevlogid
		FROM logs l
		JOIN cachers c ON c.cacherid = l.cacherid
		JOIN log_types lt ON l.logtypeid = lt.logtypeid
		JOIN cache_logs c2 ON c2.logid = l.logid
		JOIN caches c3 ON c2.cacheid = c3.cacheid
		WHERE c.cachername = 'dakboy'
			AND lt.countsasfind = 1
		) F
	) FP
ORDER BY fp.logdate ASC
	,fp.logid ASC;
