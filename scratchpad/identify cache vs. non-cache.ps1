[xml]$c = get-content scratchpad\gc3pf88.gpx
$c.gpx.wpt|?{$_.type.split("|") -eq "Geocache"}