SELECT *
	FROM OPENQUERY(GSAKMain, 'select * from caches where latitude <> latoriginal and cachetype = ''U''');

	select cacheid,CorrectedLatitude,CorrectedLongitude,t.typename from caches c join point_types t on c.typeid = t.typeid where t.typename = 'Unknown Cache';