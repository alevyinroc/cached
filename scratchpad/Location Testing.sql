create table Locations  (
	Locationname varchar(20) not null unique,
	LocationGeo geography not null
	);

/*insert into locations values (
'Home', geography::STGeomFromText('POINT()',4326) /* WGS84 is reference system 4326 http://www.mssqltips.com/sqlservertip/1965/sql-server-geography-data-type/ */
);
*/

/* Point takes longitude, then latitude. Out of bounds locations throw an error */
insert into locations values (
	'Home Old',
	geography::STGeomFromText('POINT(-77.23315 43.06525)',4326)
);
insert into locations values (
	'Home',
	geography::STGeomFromText('POINT(-77.306933 42.885983)',4326)
);
insert into locations values (
	'Mom&Dad',
	geography::STGeomFromText('POINT(-73.809733 42.853833)',4326)
);
insert into locations values (
	'Geneva',
	geography::STGeomFromText('POINT(-76.993056 42.878889)',4326)
);
insert into locations values (
	'DML',
	geography::STGeomFromText('POINT(-79.1105 42.5074)',4326)
);
insert into locations values (
	'Watkins Glen',
	geography::STGeomFromText('POINT(-76.8853 42.3386)',4326)
);
insert into locations values (
	'Syracuse',
	geography::STGeomFromText('POINT(-76.144167 43.046944)',4326)
);
insert into locations values (
	'Auburn',
	geography::STGeomFromText('POINT(-76.56477 42.93166)',4326)
);
insert into locations values (
	'Niagara Falls',
	geography::STGeomFromText('POINT(-79.017222 43.094167)',4326)
);
insert into locations values (
	'Silver Creek',
	geography::STGeomFromText('POINT(-79.167222 42.544167)',4326)
);
insert into locations values (
	'Mendon Ponds',
	geography::STGeomFromText('POINT(-77.564267 43.0293)',4326)
);
insert into locations values (
	'Saratoga',
	geography::STGeomFromText('POINT(-73.7825 43.075278)',4326)
);
insert into locations values (
	'Sea Isle',
	geography::STGeomFromText('POINT(-74.691917 39.147633)',4326)
);
insert into locations values (
	'zSpun Around Center',
	geography::STGeomFromText('POINT(-77.48055 43.09305)',4326)
);
insert into locations values (
	'Dansville',
	geography::STGeomFromText('POINT(-77.697433 42.560417)',4326)
);
insert into locations values (
	'Lockport',
	geography::STGeomFromText('POINT(-78.689767 43.17485)',4326)
);
insert into locations values (
	'Seattle',
	geography::STGeomFromText('POINT(-122.33365 47.612033)',4326)
);

select * from locations;
select locationname, locationgeo.Lat as Latitude, locationgeo.Long as Longitude from locations;

declare @p1 geography
SELECT @p1 = Locationgeo from locations where locationname='Home';
SELECT locationname, @p1.STDistance(locationgeo)/1000 as [Distance from home] from Locations order by [Distance from home];
SELECT locationname, @p1.STDistance(locationgeo)/1000 as [Distance from home], dbo.Bearing(@p1,LocationGeo) as Bearing from Locations order by [Distance from home];