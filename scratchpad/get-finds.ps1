$query = @"
SELECT ROW_NUMBER() over (order by l.logid) as findnum, c2.cacheid,c3.cachename
	,l.logdate
	,c3.placed
	,DATEDIFF(d, c3.placed, l.logdate) AS [Days After Placed]
	,AVG(DATEDIFF(d, c3.placed, l.logdate)) OVER (
		ORDER BY l.logdate rows unbounded preceding
		) AS [Moving average age of cache at find]
	,DATEDIFF(d, c3.placed, getdate()) AS [Current Age of Cache]
	,avg(DATEDIFF(d, c3.placed, getdate())) OVER (
		ORDER BY l.logdate rows unbounded preceding
		) AS [Moving average age of cache]
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	and lt.countsasfind = 1
--order by [Current Age of Cache]
--order by [Days After Placed]
ORDER BY l.logdate
	,l.logid;
"@
$finds = Invoke-Sqlcmd -database cachedb -serverinstance win81 -query $query | select findnum,"Days after placed", "moving average age of cache at find";
$finds|export-csv -NoTypeInformation -Path "$env:tmp\finds.csv";