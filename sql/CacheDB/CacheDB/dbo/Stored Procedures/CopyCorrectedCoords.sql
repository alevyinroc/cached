

CREATE procedure [dbo].[CopyCorrectedCoords] (@OnlyDifferent bit = 0, @ReturnChanges bit = 1,@PerformUpdate bit = 0) as
begin
set nocount on;
create table #CorrectedCoords (
	code varchar(8) not null,
	latitude decimal(8,6) not null,
	longitude decimal(9,6) not null
	);
insert into #CorrectedCoords select a.code, a.latitude, a.longitude from (
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
	select c.CacheId,c.Latitude,c.Longitude, c.CorrectedLatitude,c.CorrectedLongitude,cc.latitude,cc.longitude
	from Caches c join #CorrectedCoords cc on c.CacheId = cc.code
where (@OnlyDifferent = 1 and ((cc.latitude <> c.CorrectedLatitude and cc.longitude <> c.CorrectedLongitude) or c.CorrectedLatitude is null or c.CorrectedLongitude is null)) or @OnlyDifferent = 0;
end

if (@PerformUpdate =1) 
begin
update c set c.CorrectedLatitude = cc.latitude, c.CorrectedLongitude = cc.longitude
from  Caches c join #correctedcoords cc on c.CacheId = cc.code
where (@OnlyDifferent = 1 and ((cc.latitude <> c.CorrectedLatitude and cc.longitude <> c.CorrectedLongitude) or c.CorrectedLatitude is null or c.CorrectedLongitude is null)) or @OnlyDifferent = 0;
end

drop table #CorrectedCoords;
end