SELECT C.code AS cacheid,
       cacheid AS gsid,
       C.name AS cachename,
       C.latoriginal AS latitude,
       C.lonoriginal AS longitude,
       C.lastgpxdate AS lastupdated,
       C.PlacedDate AS placed,
       C.PlacedBy,
       C.CacheType AS TypeId,
       C.Container AS sizeid,
       C.difficulty,
       C.terrain,
       cm.shortdescription AS shortdesc,
       cm.longdescription AS longdesc,
       cm.hints AS hint,
       'available' AS available,
       'archived' AS archived,
       C.ispremium AS premiumonly,
       'cachestatus' AS cachestatus,
       C.created,
       cm.url AS url,
       'urldesc' AS urldesc,
       K.kafterlat AS correctedlatitude,
/* TODO: Pull these via an ISNULL from corrected coords table */
       C.country AS countryid,
       C.state AS stateid
FROM Caches C
INNER JOIN cachememo CM ON C.code = cm.code
LEFT OUTER JOIN corrected K ON k.kcode = c.code;