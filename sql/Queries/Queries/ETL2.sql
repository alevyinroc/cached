use cachedb;
--SELECT * FROM OPENQUERY([Home200], 'select name,status,archived, code,latitude,longitude, latoriginal,lonoriginal,hascorrected from caches where code in (''GC666FG'',''GC5Q54H'')');
SELECT * FROM OPENQUERY([Home200], 'select distinct state,county from caches');
select * from cache_sizes;
select * from point_types;
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
,GETUTCDATE() as lastupdated
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
  --join states S on cast([c.realstate] as nvarchar(100)) = S.Name
  ;

  