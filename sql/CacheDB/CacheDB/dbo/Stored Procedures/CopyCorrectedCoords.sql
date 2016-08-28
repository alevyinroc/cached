

CREATE procedure [dbo].[CopyCorrectedCoords] (@OnlyDifferent bit = 0, @ReturnChanges bit = 1,@PerformUpdate bit = 0) as
begin
set nocount on;
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
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([Seattle], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([CanadaEvent], 'select code, latitude, longitude from caches where hascorrected = 1') UNION all
SELECT cast(code as varchar) as code, cast(cast(latitude as varchar(12)) as decimal(8,6)) as latitude, cast(cast(longitude as varchar(12)) as decimal(9,6)) as longitude from OPENQUERY([Cruise], 'select code, latitude, longitude from caches where hascorrected = 1')
) A;
if (@ReturnChanges = 1)
begin 
	select c.CacheId,c.Latitude,c.Longitude, c.CorrectedLatitude,c.CorrectedLongitude,cc.latitude,cc.longitude
	from Caches c join #correctedcoords cc on c.CacheId = cc.code
where (@OnlyDifferent = 1 and ((cc.latitude <> c.CorrectedLatitude and cc.longitude <> c.CorrectedLongitude) or c.CorrectedLatitude is null or c.CorrectedLongitude is null)) or @OnlyDifferent = 0;
end

if (@performupdate =1) 
begin
update c set c.CorrectedLatitude = cc.latitude, c.CorrectedLongitude = cc.longitude
from  Caches c join #correctedcoords cc on c.CacheId = cc.code
where (@OnlyDifferent = 1 and ((cc.latitude <> c.CorrectedLatitude and cc.longitude <> c.CorrectedLongitude) or c.CorrectedLatitude is null or c.CorrectedLongitude is null)) or @OnlyDifferent = 0;
end

drop table #CorrectedCoords;
end