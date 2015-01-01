use cachedb;
-- Locate caches which aren't in the GSAK database
SELECT c.cacheid
	,c.cachename
	,s.NAME
	,c.lastupdated
FROM caches c
LEFT OUTER JOIN (
	SELECT cast(code AS VARCHAR(12)) code
		,STATE
		,Archived
	FROM OPENQUERY([Home200], 'select code,state,archived from caches')
	) g ON c.cacheid = g.code
JOIN states s ON s.StateId = c.StateId
JOIN statuses st ON c.cachestatus = st.statusid
WHERE st.statusname <> 'Archived'
	AND (
		g.code IS NULL
--		OR g.archived <> 0
		)
	AND s.NAME = 'new york'
ORDER BY c.lastupdated;

-- Archive all caches not found in GSAK
UPDATE c
SET c.cachestatus = 2
	,c.lastupdated = getutcdate()
FROM caches c
LEFT OUTER JOIN (
	SELECT cast(code AS VARCHAR(12)) code
		,STATE
		,Archived
	FROM OPENQUERY(GSAKMain, 'select code,state,Archived from caches')
	) g ON c.cacheid = g.code
JOIN states s ON s.StateId = c.StateId
JOIN statuses st ON c.cachestatus = st.statusid
WHERE st.statusname <> 'Archived'
	AND (
		g.code IS NULL
		OR g.archived <> 0
		)
	AND s.NAME = 'new york';
