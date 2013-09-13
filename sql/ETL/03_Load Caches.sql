select
	C.code as cacheid,
	C.cacheid as gsid,
	C.name as cachename,
	C.latitude,
	C.longitude,
# TODO: Fix this in the query or second step in the ETL
#	geography::STGeomFromText('POINT(-77.48055 43.09305)', 4326) as latlong,
	C.Changed as lastupdated,
	C.PlacedDate as Placed,
	C.PlacedBy,
# TODO: Look up CacheType to TypeId
# TODO: Look up Container to sizeId
	C.difficulty,
	C.terrain,
# TODO: Look up country to countryid
# TODO: Look up state to stateid
	M.ShortDescription as shortdesc,
	M.LongDescription as longdesc,
	m.Hints as hints,
# TODO: Translate Status to 1/0
	C.Archived as Archived,
# TODO: Find related web page
	C.IsPremium as premiumonly
from
	caches C
	inner join cachememo M on C.code = M.code