USE CacheDB;

SELECT c.cacheid
	,c.elevation AS my_elevation
	,
	--g.elevation * 0.3048 as gsak_elevation
	g.elevation AS gsak_elevation
FROM caches c
JOIN (
	SELECT cast(code AS VARCHAR) code
		,elevation
	FROM OPENQUERY(GSAKMain, 'select code,elevation from caches')
	) g ON c.cacheid = g.code
JOIN states s ON s.StateId = c.StateId
WHERE c.elevation = 0
	AND s.NAME = 'new york'
ORDER BY gsak_elevation;

UPDATE c
SET
	--c.elevation = g.elevation * 0.3048
	c.elevation = g.elevation
FROM caches c
JOIN (
	SELECT cast(code AS VARCHAR) code
		,elevation
	FROM OPENQUERY(GSAKMain, 'select code,elevation from caches')
	) g ON c.cacheid = g.code
JOIN states s ON s.StateId = c.StateId
WHERE c.elevation = 0
	AND g.elevation IS NOT NULL
	AND s.NAME = 'new york';
