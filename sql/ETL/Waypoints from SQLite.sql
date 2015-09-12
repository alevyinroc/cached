SELECT w.ccode AS waypointid,
       w.cparent AS parentcache,
       w.clat AS latitude,
       w.clon AS longitude,
       w.ctype AS typeid,
       w.cname AS name,
       wm.ccomment AS description,
       wm.curl AS url,
       w.cdate AS lastupdated
FROM waypoints W
INNER JOIN waymemo WM ON W.ccode = wm.ccode
AND w.cparent = wm.cparent;