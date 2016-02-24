use cachedb;
select * into #caches from (SELECT * FROM OPENQUERY([Far-off puzzles], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Home200], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([My Finds], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([My Hides], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([New England], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Niagara Falls], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([NJ], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Seattle], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([CanadaEvent], 'select * from caches') UNION ALL
SELECT * FROM OPENQUERY([Cruise], 'select * from caches') ) A;

/* Stuff that can be sourced from caches */

/* Add any new cache sizes */
insert into cachedb.dbo.cache_sizes (sizename) select distinct cast(container as varchar) as [size] from #caches where cast(container as varchar) not in (select sizename from cachedb.dbo.cache_sizes);

/* add any new countries */
insert into cachedb.dbo.countries (Name) select distinct cast(country as varchar) as [country] from #caches where cast(country as varchar) not in (select Name from cachedb.dbo.countries);

/* Add states */
insert into cachedb.dbo.States (Name) select distinct cast([state] as varchar) as [state] from #caches where cast([state] as varchar) not in (select Name from cachedb.dbo.States);

/* Add Counties */
with allcounties([state],county) as
(
select distinct cast([state] as varchar) as [state], cast(county as varchar) as county
from
	#caches
where cast(county as varchar) <> 'united states' and cast(county as varchar) <> ''
)
insert into cachedb.dbo.counties (countyname,stateid) select s.county,ss.stateid
from
	allcounties S inner join cachedb.dbo.States ss on ss.name = s.[state]
	left outer join cachedb.dbo.counties D on cast(s.county as varchar) = d.countyname and ss.stateid = d.stateid
where
	d.countyid is null;

/* Waypoint Types */
with wpt_types(typename) as (SELECT * FROM OPENQUERY([Far-off puzzles], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([Home200], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([My Finds], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([My Hides], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([New England], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([Niagara Falls], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([NJ], 'select distinct ctype from waypoints') UNION ALL
SELECT * FROM OPENQUERY([Seattle], 'select distinct ctype from waypoints')
UNION ALL
SELECT * FROM OPENQUERY([CanadaEvent], 'select distinct ctype from waypoints')
UNION ALL
SELECT * FROM OPENQUERY([Cruise], 'select distinct ctype from waypoints'))
insert into cachedb.dbo.point_types (typename) select w.typename from cachedb.dbo.point_types CPT right outer join wpt_types W on CPT.typename = W.typename where CPT.typeid is null;

/* Cache Types */

/* Source from logs */
with AllLogTypes(logtypename) as (
select cast(a.ltype as varchar) as logtypename
from
	(SELECT * FROM OPENQUERY([Far-off puzzles], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([Home200], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([My Finds], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([My Hides], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([New England], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([Niagara Falls], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([NJ], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([Seattle], 'select distinct ltype from logs')
	 UNION 
	SELECT * FROM OPENQUERY([Cruise], 'select distinct ltype from logs') UNION 
	SELECT * FROM OPENQUERY([CanadaEvent], 'select distinct ltype from logs')) A)
insert into cachedb.dbo.log_types (logtypedesc,CountsAsFind) select logtypename,0 from AllLogTypes A left join cachedb.dbo.log_types lt on a.logtypename = lt.logtypedesc where lt.logtypeid is null;

/* Populate cachers */
with CacheOwners (cacherid,cachername) as (select distinct cast(cast(ownerid as varchar) as int) as cacherid,cast(ownername as varchar) as cachername from #caches)
insert into cachedb.dbo.cachers (cacherid,cachername) select O.cacherid,O.cachername from CacheOwners O left outer join cachedb.dbo.cachers C on o.cacherid = C.cacherid where C.cacherid is null;

/* Pull the same from logs */
with AllLogWriters(loggername, loggerid) as (
select cast(a.lby as varchar) as loggername, cast(cast(a.lownerid as varchar) as int) as loggerid
from
	(SELECT * FROM OPENQUERY([Far-off puzzles], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([Home200], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([My Finds], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([My Hides], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([New England], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([Niagara Falls], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([NJ], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([Seattle], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([Cruise], 'select distinct lby,lownerid from logs') UNION 
	SELECT * FROM OPENQUERY([CanadaEvent], 'select distinct lby,lownerid from logs')) A)
insert into cachedb.dbo.cachers (cacherid,cachername) select loggerid,loggername from (select O.loggerid,O.loggername, ROW_NUMBER() over (partition by o.loggerid order by o.loggername) as rn from AllLogWriters O left outer join cachedb.dbo.cachers C on o.loggerid = C.cacherid where C.cacherid is null) A where rn = 1;

drop table #caches;