create table #ArchivedGSAK (
	code varchar(8) not null,
	archived int not null
	);
insert into #ArchivedGSAK select a.code, a.archived from (
SELECT cast(code as varchar) as code, archived from OPENQUERY([Far-off puzzles], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Home200], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([My Finds], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([My Hides], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([New England], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Niagara Falls], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([NJ], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Seattle], 'select code, archived from caches') ) A;

--select * from #ArchivedGSAK;

--SELECT c.cacheid
--	,c.cachename
--	,c.lastupdated
--FROM caches c
--JOIN #ArchivedGSAK A on c.cacheid = a.code
--JOIN statuses st ON  c.cachestatus = st.statusid
--where st.statusname <> 'archived'

SELECT c.cacheid
	,c.cachename
	,c.lastupdated,a.archived,a.code
FROM caches c
left outer JOIN #ArchivedGSAK A on c.cacheid = a.code
JOIN statuses st ON  c.cachestatus = st.statusid
where st.statusname <> 'archived' and (a.code is null or a.archived = 1);

drop table #ArchivedGSAK;
