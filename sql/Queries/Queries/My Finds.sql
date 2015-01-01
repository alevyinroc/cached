SET STATISTICS IO ON;

SELECT c3.cachename
	,c2.cacheid
	,l.logdate
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
ORDER BY l.logdate DESC
	,l.logid DESC;

SET STATISTICS IO OFF;

SELECT row_number() over (order by l.logdate asc,l.logid asc) as FindNum,c3.cachename,c2.cacheid
	,l.logdate,lt.CountsAsFind,l.logtypeid,lt.logtypedesc,c3.CountryId,c4.Name as CountryName
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
join countries c4 on c3.CountryId = c4.CountryId
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
ORDER BY FindNum;

-- For GC47NEJ

SELECT c3.cachename
	,c2.cacheid
into #foundmultis
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
join point_types p on c3.typeid = p.typeid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
	and p.typename = 'Multi-Cache';

select top 1 1,* from #foundmultis where cachename like 'm%' 
union
select top 1 2,* from #foundmultis where cachename like 'u%' 
union
select top 1 3,* from #foundmultis where cachename like 'l%' 
union
select top 1  4,* from #foundmultis where cachename like 't%' and cachename not like 'the %' 
union
select top 1  5,* from #foundmultis where cachename like 'i%' 
union
select top 1 6,* from #foundmultis where cachename like 'c%' 
union
select top 1 7,* from #foundmultis where cachename like 'a%' and cachename not like 'a %' and cachename <> 'a' 
union
select top 1 8,* from #foundmultis where cachename like 'c%' 
union
select top 1 9,* from #foundmultis where cachename like 'h%' 
union
select top 1 10,* from #foundmultis where cachename like 'e%' 
;
drop table #foundmultis;