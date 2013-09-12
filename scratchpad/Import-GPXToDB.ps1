# Import downloaded GPX
[xml]$cachedata = get-content C:\users\andy\Downloads\GCF7C6.gpx;

# Insert attributes & TBs into respective tables
$attributes = $cachedata.gpx.wpt.cache.attributes|%{$_.attribute|select id,"#text"};
$tbs = $cachedata.gpx.wpt.cache.travelbugs|%{$_.travelbug};
