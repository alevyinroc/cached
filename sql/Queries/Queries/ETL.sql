use cachedb;
set xact_abort on
begin transaction
select * into #caches from (
SELECT * FROM OPENQUERY([Home200], 'select * from caches where archived <> 1') 
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
insert into cache_sizes(sizename) select distinct cast(container as nvarchar) as [size] from #caches where cast(container as nvarchar) not in (select sizename from cache_sizes);

/* add any new countries */
insert into countries (Name) select distinct cast(country as nvarchar) as [country] from #caches where cast(country as nvarchar) not in (select Name from countries);

/* Add states */
insert into States (Name) select distinct cast([state] as nvarchar) as [state] from #caches where cast([state] as nvarchar) not in (select Name from States);

/* Add Counties */
with allcounties([state],county) as
(
select distinct cast([state] as nvarchar) as [state], cast(county as nvarchar) as county
from
	#caches
where cast(county as nvarchar) <> 'united states' and cast(county as nvarchar) <> ''
)
insert into counties (countyname,stateid) select s.county,ss.stateid
from
	allcounties S inner join States ss on ss.name = s.[state]
	left outer join counties D on cast(s.county as nvarchar) = d.countyname and ss.stateid = d.stateid
where
	d.countyid is null;

/* Waypoint Types */
with wpt_types(typename) as (
SELECT * FROM OPENQUERY([Home200], 'select distinct ctype from waypoints')
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
insert into point_types (TypeName) select w.typename from point_types CPT right outer join wpt_types W on CPT.TypeName = W.typename where CPT.TypeId is null;
print 'Waypoint types done';
/* Cache Types */

/* Source from logs */
with Alllog_types(logtypename) as (
select cast(a.ltype as nvarchar) as logtypename
from
	(
	SELECT * FROM OPENQUERY([Home200], 'select distinct ltype from logs') 
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
--insert into log_types (logtypedesc,CountsAsFind)
 select logtypename,0 from Alllog_types A left join log_types lt on a.logtypename = lt.logtypedesc where lt.logtypeid is null;
print 'Log types done';

/* Populate cachers */
alter table #caches add RealLastGPXDate datetimeoffset;
alter table #caches add RealOwnerId int;
create index IX_Caches_LastGPX on #caches(RealLastGPXDate);
create index ix_caches_ownerid on #caches(realownerid);
update  #caches set RealLastGPXDate = cast(lastgpxdate as nvarchar);
update #caches set realownerid = cast(cast(ownerid as nvarchar) as int);
with CacheOwners (ownerid,ownername) as (select distinct realownerid
,cast(ownername as nvarchar)
from #caches c
where c.RealLastGPXDate =
(select max(RealLastGPXDate)
	from #caches where #caches.realownerid= c.realownerid))
insert into cachers (cacherid,cachername)
select distinct O.ownerid,O.ownername
from CacheOwners O
left outer join cachers C on o.ownerid = C.cacherid
where C.cacherid is null;
print 'Cache Owners done';

/* Pull the same from logs */
/* This isn't working because of issues w/ SQLite I guess?
with AllLogWriters(loggername, loggerid) as (
select cast(a.lby as nvarchar) as loggername, cast(cast(a.lownerid as nvarchar) as int) as loggerid
from
	(
	SELECT lby,lownerid FROM OPENQUERY([Home200], 'select distinct lby,lownerid from logs') 
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
	select loggerid,loggername from AllLogWriters A left outer join cachers C on a.loggerid = c.cacherid where c.cacherid is null
--insert into cachers (cacherid,cachername)
 select loggerid,loggername from (select O.loggerid,O.loggername, ROW_NUMBER() over (partition by o.loggerid order by o.loggername) as rn
 from AllLogWriters O left outer join cachers C on o.loggerid = C.cacherid where C.cacherid is null) A 
 where rn = 1;
 */
drop table #caches;
commit transaction