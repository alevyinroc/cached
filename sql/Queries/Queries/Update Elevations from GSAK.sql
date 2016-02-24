USE CacheDB;

select code,elevation into #caches from (SELECT * FROM OPENQUERY([Far-off puzzles], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([Home200], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([My Finds], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([My Hides], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([New England], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([Niagara Falls], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([NJ], 'select code,elevation from caches') UNION ALL
SELECT * FROM OPENQUERY([Seattle], 'select code,elevation from caches') ) A;


SELECT c.cacheid
	,c.elevation AS my_elevation
	,
	--g.elevation * 0.3048 as gsak_elevation
	g.elevation AS gsak_elevation
FROM caches c
JOIN (
	SELECT cast(code AS VARCHAR) code
		,elevation
	FROM #caches
	) g ON c.cacheid = g.code
JOIN states s ON s.StateId = c.StateId
WHERE c.elevation = 0
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
