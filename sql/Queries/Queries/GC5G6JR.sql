/* Get my finds that qualify */
select c.* from cachedb.dbo.caches c join utility.dbo.dimdate d on c.placed = d.calendardate 
join cachedb.dbo.cache_logs c2 on c.cacheid =  c2.cacheid
join cachedb.dbo.logs l on c2.logid = l.logid
JOIN cachedb.dbo.cachers c3 ON c3.cacherid = l.cacherid
JOIN cachedb.dbo.log_types lt ON l.logtypeid = lt.logtypeid
WHERE c3.cachername = 'dakboy'
	AND lt.countsasfind = 1 and (
	(d.month_of_year = d.day_of_month + 1 and cast(right(d.year_name_short,2) as int) = d.day_of_month + 2)
	or (d.day_of_month = d.month_of_year + 1 and cast(right(year_name_short,2) as int)  = d.month_of_year + 2)
	);

/* Get candidate caches */
select c.* from cachedb.dbo.caches c join utility.dbo.dimdate d on c.placed = d.calendardate join cachedb.dbo.statuses s on c.cachestatus = s.statusid
WHERE (
c.longitude > -80 and s.statusname <> 'archived' and 
	(d.month_of_year = d.day_of_month + 1 and cast(right(d.year_name_short,2) as int) = d.day_of_month + 2)
	or (d.day_of_month = d.month_of_year + 1 and cast(right(year_name_short,2) as int)  = d.month_of_year + 2)
	);