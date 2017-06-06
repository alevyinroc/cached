USE cachedb;
SET NOCOUNT OFF;
SET XACT_ABORT ON;
BEGIN TRANSACTION;
SELECT *
INTO #caches
FROM
(
    SELECT *
    FROM OPENQUERY([Home200], 'select * from caches where archived <> 1') 
--UNION ALL SELECT * FROM OPENQUERY([Far-off puzzles], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([My Finds], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([My Hides], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([New England], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Niagara Falls], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([NJ], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Seattle], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([CanadaEvent], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Cruise], 'select * from caches')
) A;

/* Stuff that can be sourced from caches */

/* Add any new cache sizes */

INSERT INTO cache_sizes(sizename)
       SELECT DISTINCT
              CAST(container AS NVARCHAR) AS [size]
       FROM #caches
       WHERE CAST(container AS NVARCHAR) NOT IN
       (
           SELECT sizename
           FROM cache_sizes
       );

/* add any new countries */

INSERT INTO countries(Name)
       SELECT DISTINCT
              CAST(country AS NVARCHAR) AS [country]
       FROM #caches
       WHERE CAST(country AS NVARCHAR) NOT IN
       (
           SELECT Name
           FROM countries
       );

/* Add states */

INSERT INTO States(Name)
       SELECT DISTINCT
              CAST([state] AS NVARCHAR) AS [state]
       FROM #caches
       WHERE CAST([state] AS NVARCHAR) NOT IN
       (
           SELECT Name
           FROM States
       );

/* Add Counties */

WITH allcounties([state],
                 county)
     AS (SELECT DISTINCT
                CAST([state] AS NVARCHAR) AS [state],
                CAST(county AS NVARCHAR) AS county
         FROM #caches
         WHERE CAST(county AS NVARCHAR) <> 'united states'
               AND CAST(county AS NVARCHAR) <> '')
     INSERT INTO counties
     (countyname,
      stateid
     )
            SELECT s.county,
                   ss.stateid
            FROM allcounties S
                 INNER JOIN States ss ON ss.name = s.[state]
                 LEFT OUTER JOIN counties D ON CAST(s.county AS NVARCHAR) = d.countyname
                                               AND ss.stateid = d.stateid
            WHERE d.countyid IS NULL;

/* Waypoint Types */

WITH wpt_types(typename)
     AS (SELECT *
         FROM OPENQUERY([Home200], 'select distinct ctype from waypoints')
     --UNION ALL SELECT * FROM OPENQUERY([Far-off puzzles], 'select distinct ctype from waypoints')
     --UNION ALL SELECT * FROM OPENQUERY([My Finds], 'select distinct ctype from waypoints') UNION ALL
     --SELECT * FROM OPENQUERY([My Hides], 'select distinct ctype from waypoints') UNION ALL
     --SELECT * FROM OPENQUERY([New England], 'select distinct ctype from waypoints') UNION ALL
     --SELECT * FROM OPENQUERY([Niagara Falls], 'select distinct ctype from waypoints') UNION ALL
     --SELECT * FROM OPENQUERY([NJ], 'select distinct ctype from waypoints') UNION ALL
     --SELECT * FROM OPENQUERY([Seattle], 'select distinct ctype from waypoints')
     --UNION ALL
     --SELECT * FROM OPENQUERY([CanadaEvent], 'select distinct ctype from waypoints')
     --UNION ALL
     --SELECT * FROM OPENQUERY([Cruise], 'select distinct ctype from waypoints')
     )
     INSERT INTO point_types(TypeName)
            SELECT w.typename
            FROM point_types CPT
                 RIGHT OUTER JOIN wpt_types W ON CPT.TypeName = W.typename
            WHERE CPT.TypeId IS NULL;
PRINT 'Waypoint types done';

/* Cache Types */

/* Source from logs */

WITH Alllog_types(logtypename)
     AS (SELECT CAST(a.ltype AS NVARCHAR) AS logtypename
         FROM
         (
             SELECT *
             FROM OPENQUERY([Home200], 'select distinct ltype from logs') 
         -- UNION SELECT * FROM OPENQUERY([Far-off puzzles], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([My Finds], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([My Hides], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([New England], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([Niagara Falls], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([NJ], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([Seattle], 'select distinct ltype from logs')
         -- UNION 
         --SELECT * FROM OPENQUERY([Cruise], 'select distinct ltype from logs') UNION 
         --SELECT * FROM OPENQUERY([CanadaEvent], 'select distinct ltype from logs')
         ) A)
     INSERT INTO log_types
     (logtypedesc,
      CountsAsFind
     )
            SELECT logtypename,
                   0
            FROM Alllog_types A
                 LEFT JOIN log_types lt ON a.logtypename = lt.logtypedesc
            WHERE lt.logtypeid IS NULL;
PRINT 'Log types done';

/* Populate cachers */

ALTER TABLE #caches
ADD RealLastGPXDate DATETIMEOFFSET;
ALTER TABLE #caches
ADD RealOwnerId INT;
CREATE INDEX IX_Caches_LastGPX ON #caches(RealLastGPXDate);
CREATE INDEX ix_caches_ownerid ON #caches(realownerid);
UPDATE #caches
  SET
      RealLastGPXDate = CAST(lastgpxdate AS NVARCHAR);
UPDATE #caches
  SET
      realownerid = CAST(CAST(ownerid AS NVARCHAR) AS INT);
WITH CacheOwners(ownerid,
                 ownername)
     AS (SELECT DISTINCT
                realownerid,
                CAST(ownername AS NVARCHAR)
         FROM #caches c
         WHERE c.RealLastGPXDate =
         (
             SELECT MAX(RealLastGPXDate)
             FROM #caches
             WHERE #caches.realownerid = c.realownerid
         ))
     INSERT INTO cachers
     (cacherid,
      cachername
     )
            SELECT DISTINCT
                   O.ownerid,
                   O.ownername
            FROM CacheOwners O
                 LEFT OUTER JOIN cachers C ON o.ownerid = C.cacherid
            WHERE C.cacherid IS NULL;
PRINT 'Cache Owners done';

/* Pull the same from logs */

/* Seems to be a limit between 80K and 85K for pulling records back from sqlite */

WITH AllLogWriters(loggername,
                   loggerid)
     AS (SELECT CAST(a.lby AS NVARCHAR) AS loggername,
                CAST(CAST(a.lownerid AS NVARCHAR) AS INT) AS loggerid
         FROM
         (
             SELECT lby,
                    lownerid
             FROM OPENQUERY([Home200], 'select lby,lownerid from (select distinct lby,lownerid from logs join caches on logs.lparent = caches.code where caches.archived=0) A') 
         --UNION SELECT * FROM OPENQUERY([Far-off puzzles], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([My Finds], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([My Hides], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([New England], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([Niagara Falls], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([NJ], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([Seattle], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([Cruise], 'select distinct lby,lownerid from logs') UNION 
         --SELECT * FROM OPENQUERY([CanadaEvent], 'select distinct lby,lownerid from logs')
         ) A)
     --select loggerid,loggername from AllLogWriters A left outer join cachers C on a.loggerid = c.cacherid where c.cacherid is null
     INSERT INTO cachers
     (cacherid,
      cachername
     )
            SELECT loggerid,
                   loggername
            FROM
            (
                SELECT O.loggerid,
                       O.loggername,
                       ROW_NUMBER() OVER(PARTITION BY o.loggerid ORDER BY o.loggername) AS rn
                FROM AllLogWriters O
                     LEFT OUTER JOIN cachers C ON o.loggerid = C.cacherid
                WHERE C.cacherid IS NULL
            ) A
            WHERE rn = 1;
PRINT 'Log writers done';
DROP TABLE #caches;
COMMIT TRANSACTION;