SELECT L.llogid AS logid,
       L.ldate + L.ltime AS logdate,
       L.ltype AS logtypeid,
       L.lownerid AS cacherid,
       LM.ltext AS logtext,
       llat AS latitude,
       llon AS longitude
  FROM logs L
       INNER JOIN logmemo LM
               ON l.llogid = lm.llogid;

