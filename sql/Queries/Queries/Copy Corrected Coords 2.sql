use cachedb;
create table #CorrectedCoords (
	code varchar(8) not null,
	latitude decimal(8,6) not null,
	longitude decimal(9,6) not null
	);
insert into #CorrectedCoords select a.code, a.latitude, a.longitude from (
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([Far-off puzzles], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([Home200], 'select code, latitude, longitude from caches where hascorrected = 1')
UNION all SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([My Finds], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([My Hides], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([New England], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([Niagara Falls], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all 
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([NJ], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([Seattle], 'select code, latitude, longitude from caches where hascorrected = 1') 
) A;

--select * from #CorrectedCoords order by code;
select c.cacheid,c.latitude,c.longitude, c.CorrectedLatitude,c.CorrectedLongitude,cc.latitude,cc.longitude from caches c join #correctedcoords cc on c.cacheid = cc.code;
begin transaction
update c set c.correctedlatitude = cc.latitude, c.correctedlongitude = cc.longitude
from  caches c join #correctedcoords cc on c.cacheid = cc.code;
commit transaction
drop table #CorrectedCoords;