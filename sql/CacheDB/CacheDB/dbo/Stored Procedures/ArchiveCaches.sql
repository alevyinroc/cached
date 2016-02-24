


CREATE procedure [dbo].[ArchiveCaches] (@ReturnChanges bit = 1,@PerformArchive bit = 0) as
begin
set nocount on;
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
SELECT cast(code as varchar) as code, archived from OPENQUERY([Seattle], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([CanadaEvent], 'select code, archived from caches') UNION 
SELECT cast(code as varchar) as code, archived from OPENQUERY([Cruise], 'select code, archived from caches')  
) A;

if (@ReturnChanges = 1)
begin 
SELECT c.cacheid
	,c.cachename
	,c.lastupdated,a.archived,a.code,c.latitude,c.longitude
	,c.cachestatus
	,st.statusname, c.latlong
FROM caches c
JOIN statuses st ON  c.cachestatus = st.statusid
JOIN #ArchivedGSAK A on c.cacheid = a.code
where
 st.statusname <> 'archived'  and
  a.archived = 1
order by a.archived desc, c.cacheid;
end

if (@PerformArchive =1) 
begin
UPDATE c
SET c.cachestatus = 2
	,c.lastupdated = getutcdate()
FROM caches c
join #ArchivedGSAK a on c.cacheid = a.code
JOIN states s ON s.StateId = c.StateId
JOIN statuses st ON c.cachestatus = st.statusid
WHERE st.statusname <> 'Archived'
	AND a.archived = 1;
end

drop table #ArchivedGSAK;
end