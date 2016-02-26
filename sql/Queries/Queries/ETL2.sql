use cachedb;
--SELECT * FROM OPENQUERY([Home200], 'select name,status,archived, code,latitude,longitude, latoriginal,lonoriginal,hascorrected from caches where code in (''GC666FG'',''GC5Q54H'')');
--SELECT * FROM OPENQUERY([Home200], 'select distinct state,county from caches');
--select * from cache_sizes;
--select * from point_types;
--SELECT * FROM OPENQUERY([Home200], 'select * from cachememo');
--SELECT * FROM OPENQUERY([Home200], 'select * from corrected');
--SELECT * FROM OPENQUERY([Cruise], 'select * from caches where code = ''GC6A1EC''');
--select top 1 * from caches where cacheid = 'GC6A1EC' order by placed desc;
-- Use lookup on Status for Available, Archived, TempDisabled & cachestatus?
-- Need lookup on corrected to update corrected coords

SELECT c.code as cacheid
, c.cacheid as gsid
, c.name as cachename
, coalesce(c.kbeforelat,c.latoriginal, c.latitude) as latitude
, coalesce(c.kbeforelon,c.lonoriginal, longitude) as longitude
,c.lastGPXDate as lastupdated
, c.placeddate as placed
, c.placedby as placedby
,PT.typeid
,cs.sizeid
, c.difficulty as difficulty
, c.terrain as terrain
, c.ShortDescription as shortDesc
, c.LongDescription as longdesc
, c.Hints as hint
, IsPremium as premiumonly
, case
	when cast(c.status as char(1)) = 'A' then (select statusid from statuses where statusname = 'Available')
	when cast(c.status as char(1)) = 'T' then (select statusid from statuses where statusname = 'Disabled')
	when cast(c.status as char(1)) = 'X' then (select statusid from statuses where statusname = 'Archived')
	else NULL
end
 as cachestatus
,created as Created
, [URL] as url
, NULL as urldesc_NEEDS_LOOKUP
, c2.Countryid
, c.elevation as elevation
, S.StateId as StateId
,CT.CountyId as CountyId
, c.kafterlat as CorrectedLatitude
, c.kafterlon as CorrectedLongitude
  FROM OPENQUERY([Home200], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL
  ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty
  ,kbeforelat,kbeforelon
   from caches C join cachememo CM on C.code = CM.code
  left outer join corrected cc on c.code = cc.kcode
where c.hascorrected = 1 and c.code = ''GC6BVA0''
limit 1
 
  ' ) as C
  join Countries C2 on cast(c.country as nvarchar(100)) = C2.Name
  join point_types PT on PT.GSAK_Lookup = cast(C.cachetype as char(1))
  join cache_sizes CS on CS.sizename = cast(c.Container as varchar(16))
  join States S on s.name = cast(c.realstate as varchar(100))
  left join counties CT on CT.CountyName = cast(c.realcounty as varchar(100)) and CT.StateId = S.StateId
  ;

  -- Get all cache IDs in GSAK but not my database
select * into #GSAKcaches from (
--SELECT * FROM OPENQUERY([Far-off puzzles], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
SELECT * FROM OPENQUERY([Home200], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
--SELECT * FROM OPENQUERY([My Finds], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
--SELECT * FROM OPENQUERY([My Hides], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
SELECT * FROM OPENQUERY([New England], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
SELECT * FROM OPENQUERY([Niagara Falls], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode where c.country=''Canada''') UNION ALL
SELECT * FROM OPENQUERY([NJ], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
SELECT * FROM OPENQUERY([Seattle], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
SELECT * FROM OPENQUERY([CanadaEvent], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode') UNION ALL
SELECT * FROM OPENQUERY([Cruise], 'select C.*, cm.ShortDescription, cm.LongDescription, CM.Hints, CM.URL ,cc.kafterlat, cc.kafterlon, coalesce(cc.kafterstate,c.state) as realstate, coalesce(cc.kaftercounty,c.county) as realcounty,kbeforelat,kbeforelon from caches C join cachememo CM on C.code = CM.code left outer join corrected cc on c.code = cc.kcode')
) A;
delete G from #GSAKCaches G where exists (select 1 from caches c where c.cacheid = cast(g.code as varchar(10)));
/* TODO: Go through #GSAKCaches and delete duplicates. Use windowing function and LastUpdated date to find most recent record for each */

insert into caches(cacheid, gsid, cachename, latitude, longitude, lastupdated, placed, placedby, typeid
, sizeid,difficulty,terrain, shortdesc,longdesc,hint, premiumonly,cachestatus,created, url,
CountryId,Elevation,StateId,CountyId, CorrectedLatitude,CorrectedLongitude,NeedsExternalUpdate) 
SELECT cast(c.code as varchar(10)) as cacheid
, convert(INT, convert(varchar(12), c.cacheid)) as gsid
, cast(c.name as nvarchar(50)) as cachename
, convert(decimal(8,6), convert(varchar(20), coalesce(c.kbeforelat,c.latoriginal, c.latitude))) as latitude
, convert(decimal(9,6), convert(varchar(20), coalesce(c.kbeforelon,c.lonoriginal, c.longitude))) as longitude
,convert(datetimeoffset, convert(varchar(30), c.lastGPXDate)) as lastupdated
,convert(date, convert(varchar(30), c.placeddate)) as placed
, c.placedby as placedby
,PT.typeid
,cs.sizeid
, c.difficulty as difficulty
, c.terrain as terrain
, c.ShortDescription as shortDesc
, c.LongDescription as longdesc
, c.Hints as hint
, IsPremium as premiumonly
, case
	when cast(c.status as char(1)) = 'A' then (select statusid from statuses where statusname = 'Available')
	when cast(c.status as char(1)) = 'T' then (select statusid from statuses where statusname = 'Disabled')
	when cast(c.status as char(1)) = 'X' then (select statusid from statuses where statusname = 'Archived')
	else NULL
end
 as cachestatus
,convert(datetimeoffset, convert(varchar(30), created)) as Created
, [URL] as url
--, NULL as urldesc_NEEDS_LOOKUP
, c2.Countryid
, c.elevation as elevation
, S.StateId as StateId
,CT.CountyId as CountyId
, c.kafterlat as CorrectedLatitude
, c.kafterlon as CorrectedLongitude
,0 as NeedsExternalUpdate
  FROM #GSAKcaches as C
  join Countries C2 on cast(c.country as nvarchar(100)) = C2.Name
  join point_types PT on PT.GSAK_Lookup = cast(C.cachetype as char(1))
  join cache_sizes CS on CS.sizename = cast(c.Container as varchar(16))
  join States S on s.name = cast(c.realstate as varchar(100))
  left join counties CT on CT.CountyName = cast(c.realcounty as varchar(100)) and CT.StateId = S.StateId
  ;
drop table #GSAKCaches;