use cachedb;
select * from log_types;
select * from cache_sizes;
select * from point_types;
select cacheid,latlong from caches where longitude < -76;
select cacheid,latlong from caches order by cacheid;
select latlong,waypointid from waypoints where latitude <> 0 and longitude < -74;
select count(1) from caches;
select count(1) from waypoints;
select count(1) from logs;
select * from cache_logs;
SELECT * FROM waypoints order by waypointid;
SELECT * from waypoints where waypointid = 'PK20YRA';

select cacheid,count(logid) from cache_logs group by cacheid order by 2 desc;
