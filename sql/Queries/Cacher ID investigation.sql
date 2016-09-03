drop table if exists #caches;
go
select * into #caches from (
--SELECT * FROM OPENQUERY([Home200], 'select * from caches') 
--UNION ALL SELECT * FROM OPENQUERY([Far-off puzzles], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([My Finds], 'select * from caches')
--UNION ALL SELECT * FROM OPENQUERY([My Hides], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([New England], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Niagara Falls], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([NJ], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Seattle], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([CanadaEvent], 'select * from caches') UNION ALL
--SELECT * FROM OPENQUERY([Cruise], 'select * from caches')
) A;

/* Populate cachers */
begin transaction;
with CacheOwners (cacherid,cachername) as (select distinct cast(cast(ownerid as varchar) as int) as cacherid,cast(ownername as varchar) as cachername from #caches)
insert into cachers (cacherid,cachername) select distinct O.cacherid,O.cachername from CacheOwners O left outer join cachers C on o.cacherid = C.cacherid where C.cacherid is null;
rollback transaction
select * from cachers

select distinct cast(cast(ownerid as varchar) as int) as cacherid
,cast(ownername as varchar) as cachername
from #caches
where convert(datetimeoffset, convert(varchar(30), lastGPXDate)) = (select max(convert(datetimeoffset, convert(varchar(30), lastGPXDate))) from #caches c2 where cast(c2.code as nvarchar(10)) = cast(#caches.code as nvarchar(10)))
order by cacherid

select a.cacherid,count(*) from (
select distinct cast(cast(ownerid as varchar) as int) as cacherid
,cast(ownername as varchar) as cachername
from #caches ) as A group by a.cacherid having count(*) > 1
