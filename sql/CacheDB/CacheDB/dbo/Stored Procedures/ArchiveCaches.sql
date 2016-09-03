


CREATE procedure [dbo].[ArchiveCaches] (@ReturnChanges bit = 1,@PerformArchive bit = 0) as
begin
set nocount on;
create table #ArchivedGSAK (
	code varchar(8) not null,
	archived int not null
	);
insert into #ArchivedGSAK select a.code, a.archived from (
SELECT cast(code as varchar) as code, archived from OPENQUERY([Home200], 'select code, archived from caches')
--UNION
--SELECT cast(code as varchar) as code, archived from OPENQUERY([Far-off puzzles], 'select code, archived from caches') UNION 
--UNION SELECT cast(code as varchar) as code, archived from OPENQUERY([My Finds], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([My Hides], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([New England], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([Niagara Falls], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([NJ], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([Seattle], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([CanadaEvent], 'select code, archived from caches') UNION 
--SELECT cast(code as varchar) as code, archived from OPENQUERY([Cruise], 'select code, archived from caches')  
) A;

if (@ReturnChanges = 1)
begin 
SELECT c.CacheId
	,c.CacheName
	,c.LastUpdated,a.archived,a.code,c.Latitude,c.Longitude
	,c.CacheStatus
	,st.StatusName, c.LatLong
FROM Caches c
JOIN Statuses st ON  c.CacheStatus = st.StatusId
JOIN #ArchivedGSAK A on c.CacheId = a.code
where
 st.StatusName <> 'archived'  and
  a.archived = 1
order by a.archived desc, c.CacheId;
end

if (@PerformArchive =1) 
begin
UPDATE c
SET c.CacheStatus = 2
	,c.LastUpdated = getutcdate()
FROM Caches c
join #ArchivedGSAK a on c.CacheId = a.code
JOIN States s ON s.StateId = c.StateId
JOIN Statuses st ON c.CacheStatus = st.StatusId
WHERE st.StatusName <> 'Archived'
	AND a.archived = 1;
end

drop table #ArchivedGSAK;
end