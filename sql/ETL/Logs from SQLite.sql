select L.llogid as logid,
L.ldate + L.ltime as logdate,
L.ltype as logtypeid,
L.lownerid as cacherid,
LM.ltext as logtext,
llat as latitude,
llong as longitude
from logs L inner join logmemo LM on l.llogid = lm.llogid