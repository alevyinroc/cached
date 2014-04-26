--INSERT into CenterPoints (Locationname,Latitude,Longitude) VALUES ('Rick', 43.136700,-77.796233);
select * from CenterPoints where Longitude > -80 and Latitude > 41;
SELECT top 1000 cacheid,latlong from caches order by gsid;

/*50km*/

declare @home geography;
DECLARE @rick geography;
SELECT @home = latlong from CenterPoints where locationname='Home';
SELECT @rick = latlong from CenterPoints where locationname='rick';
SELECT cacheid, latlong,@home.STDistance(latlong)/1000 as [Distance from home], @rick.STDistance(latlong)/1000 as [Distance from Rick] from caches where @home.STDistance(latlong)/1000 <= 50 AND @rick.STDistance(latlong)/1000 <= 50 order by [Distance from home], [Distance from Rick];

SELECT cacheid,latlong from caches where @rick.STDistance(latlong)/1000 <= 50;
SELECT cacheid,latlong from caches where @home.STDistance(latlong)/1000 <= 50;
SELECT cacheid,latlong from caches where @home.STDistance(latlong)/1000 <= 50 AND @rick.STDistance(latlong)/1000 <= 50;


SELECT locationname, @p1.STDistance(locationgeo)/1000 as [Distance from home] from CenterPoints order by [Distance from home];
