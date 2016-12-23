drop table if exists #caches;
go
select * into #caches from (
SELECT cast(code as nvarchar) as GCID, convert(datetimeoffset, convert(varchar(30), lastGPXDate)) as LastUpdated
,cast(cast(ownerid as varchar) as int) as cacheownerid
,* FROM OPENQUERY([Home200], 'select * from caches') 
--UNION ALL SELECT * FROM OPENQUERY([Far-off puzzles], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([My Finds], 'select * from caches')
--UNION ALL SELECT * FROM OPENQUERY([My Hides], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([New England], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Niagara Falls], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([NJ], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Seattle], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([CanadaEvent], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Cruise], 'select * from caches')
) A;

select cacheownerid
,cast(ownername as varchar)
from #caches c
where c.LastUpdated =
(select max(LastUpdated)
	from #caches where #caches.cacheownerid = C.cacheownerid);


/* Populate cachers */
begin transaction;
with CacheOwners (cacherid,cachername) as (select distinct cast(cast(ownerid as varchar) as int)
,cast(ownername as varchar)
from #caches c
where c.LastUpdated =
(select LastUpdated
	from #caches where #caches.GCID = C.GCID))
insert into cachers (cacherid,cachername) select distinct O.cacherid,O.cachername from CacheOwners O left outer join cachers C on o.cacherid = C.cacherid where C.cacherid is null;
rollback transaction
select * from cachers

select distinct cast(cast(ownerid as varchar) as int) as cacherid
,cast(ownername as varchar) as cachername
from #caches
where convert(datetimeoffset, convert(varchar(30), lastGPXDate)) = (select max(convert(datetimeoffset, convert(varchar(30), lastGPXDate))) from #caches c2 where cast(c2.code as nvarchar(10)) = cast(#caches.code as nvarchar(10)))
order by cacherid

select a.cacheownerid,count(*) from (

select cacheownerid
,cast(ownername as varchar) as cacheownername
from #caches c
where c.LastUpdated =
(select max(LastUpdated)
	from #caches where #caches.cacheownerid = C.cacheownerid)) as A group by a.cacheownerid having count(*) > 1

select gcid,ownername,ownerid,LastUpdated from #caches where cast(cast(ownerid as varchar) as int) = 14850505

select * from Cachers;

/* Populate cachers */
with CacheOwners (cacherid,cachername) as (select distinct cast(cast(ownerid as varchar) as int) as cacherid,cast(ownername as varchar) as cachername from #caches)
select * from CacheOwners order by cacherid
select count(*) from #caches