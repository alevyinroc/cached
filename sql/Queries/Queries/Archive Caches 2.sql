use cachedb;
create table #ArchivedGSAK (
	code varchar(8) not null,
	archived int not null
	);
insert into #ArchivedGSAK select a.code, a.archived from (
SELECT cast(code as varchar) as code, archived from OPENQUERY([Far-off puzzles], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Home200], 'select code, archived from caches')
UNION SELECT cast(code as varchar) as code, archived from OPENQUERY([My Finds], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([My Hides], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([New England], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Niagara Falls], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([NJ], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Seattle], 'select code, archived from caches') 
) A;

--select * from #ArchivedGSAK where archived = 1 order by code;
--select c.cachestatus,c.* from caches c join #ArchivedGSAK a on c.cacheid = a.code where a.archived = 1 order by c.cachename;


SELECT c.cacheid
	,c.cachename
	,c.lastupdated,a.archived,a.code,c.longitude
	,c.cachestatus
	,st.statusname
FROM caches c
JOIN statuses st ON  c.cachestatus = st.statusid
JOIN #ArchivedGSAK A on c.cacheid = a.code
where
 st.statusname <> 'archived'  and
  a.archived = 1
order by a.archived desc, c.cacheid;

begin transaction
UPDATE c
SET c.cachestatus = 2
	,c.lastupdated = getutcdate()
FROM caches c
join #ArchivedGSAK a on c.cacheid = a.code
JOIN states s ON s.StateId = c.StateId
JOIN statuses st ON c.cachestatus = st.statusid
WHERE st.statusname <> 'Archived'
	AND a.archived = 1;
commit transaction
	
drop table #ArchivedGSAK;
