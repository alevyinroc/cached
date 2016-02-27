--select * FROM OPENQUERY([Home200], 'select * from logsall limit 1')
--sp_help logs
SELECT
cast(lparent as varchar(10)) as cacheid
, convert(bigINT, convert(varchar(12), llogid)) as logid
,cast(cast(ldate as varchar(10)) + 'T' + cast(ltime as varchar(10)) + '-05:00' as datetimeoffset) as logdate
, cast(ltype as varchar(20)) as logtype
,cast(lownerid as bigint) as cacherid
,cast(ltext as nvarchar(4000)) as logtext
,case when llat = '' then NULL
else convert(decimal(8,6), convert(varchar(20), llat))
end as latitude
,case when llon = '' then NULL
else convert(decimal(9,6), convert(varchar(20), llat))
end as longitude
into #GSAKlogs
 FROM OPENQUERY([Home200], 'select lparent,llogid,ldate,ltime,ltype,lownerid,ltext,llat,llon from logsall');

 select * from #GSAKlogs;

 drop table #GSAKlogs;
