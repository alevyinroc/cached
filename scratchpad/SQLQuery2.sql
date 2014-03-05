use cachedb;
select * from log_types;
select * from cache_sizes;
select * from point_types;
select cacheid,latlong from caches where longitude < -76;
select cacheid,latlong from caches order by cacheid;
select latlong,waypointid from waypoints where latitude <> 0 and longitude < -74;
select count(1) from caches;