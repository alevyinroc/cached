select * from (select ROW_NUMBER() over (partition by cl.cacheid order by l.logdate desc) as rn,c.cacheid, cs2.cachername as ownername, l.logdate,l.logtext, cs.cachername as Logger
from caches c
join cache_logs cl on c.cacheid = cl.cacheid
join logs l on cl.logid = l.logid
join log_types lt on l.logtypeid = lt.logtypeid
join cachers cs on cs.cacherid = l.cacherid
join cache_owners co on co.cacheid = c.cacheid
join cachers cs2 on cs2.cacherid = co.cacherid
where lt.CountsAsFind = 1) A where a.rn = 1
--and a.Logger = 'dakboy'
order by a.logdate desc;

--alter database cachedb set query_store = on;