CREATE TABLE #myfinds (
	findnum INT PRIMARY KEY
	,latitude DECIMAL(8, 6)
	,longitude DECIMAL(9, 6)
	);

INSERT INTO #myfinds
SELECT row_number() OVER (
		ORDER BY l.logdate ASC
		) AS FindNum
	,c3.latitude
	,c3.longitude
FROM logs l
JOIN cachers c ON c.cacherid = l.cacherid
JOIN log_types lt ON l.logtypeid = lt.logtypeid
JOIN cache_logs c2 ON c2.logid = l.logid
JOIN caches c3 ON c2.cacheid = c3.cacheid
WHERE c.cachername = 'dakboy'
	AND lt.countsasfind = 1
ORDER BY l.logdate ASC;

/*Parameters for WGS84 ellipsoid
@ecc is eccentricity squared*/
DECLARE @axis INT = 6378137;
DECLARE @ecc FLOAT = 0.00669438038;
/*
x = longitude
y = latitude
z = altitude?
*/
DECLARE @x FLOAT = 0;
DECLARE @y FLOAT = 0;
DECLARE @z FLOAT = 0;

-- x
SELECT @x = AVG((@axis / (SQRT(1 - (@ecc * SIN(RADIANS(Latitude + 0))) * SIN(RADIANS(Latitude + 0))))) * (COS(RADIANS(latitude + 0)) * SIN(RADIANS(longitude + 0))))
FROM #myfinds;

-- y
SELECT @y = AVG((@axis / (SQRT(1 - (@ecc * SIN(RADIANS(Latitude + 0))) * SIN(RADIANS(Latitude + 0))))) * (- 1 * COS(RADIANS(latitude + 0)) * COS(RADIANS(longitude + 0))))
FROM #myfinds;

SELECT @z = AVG((@axis / (SQRT(1 - (@ecc * SIN(RADIANS(Latitude + 0))) * SIN(RADIANS(Latitude + 0))))) * (1 - @ecc) * SIN(RADIANS(latitude + 0)))
FROM #myfinds;

SELECT @x
	,@y
	,@z;

-- Project the average point back up to the surface of the WGS84 Ellipsoid
-- Note this requires iteration
-- Longitude = ATN2(x, -y)
SELECT @y = - @y;

DECLARE @longitudeN FLOAT = atn2(@x, @y);

-- Latitude = ATN2(z, sqrt(x*x + y*y))
SELECT @y = Sqrt(SQUARE(@x) + SQUARE(@y));

DECLARE @latitudeN FLOAT = atn2(@z, (@y * (1 - @ecc)));
DECLARE @v FLOAT;

SELECT @v = @axis / (Sqrt(1 - (@ecc * Sin(@LatitudeN) * Sin(@LatitudeN))))

DECLARE @errvalue FLOAT = 1;
DECLARE @tmpN FLOAT = 0;
DECLARE @tmpM FLOAT = 0;

WHILE @errvalue > 0.000001
	AND @tmpM < 5
BEGIN
	SELECT @tmpM = @tmpM + 1;

	SELECT @x = (@ecc * @v * Sin(@LatitudeN));

	SELECT @tmpN = ATN2(@z + @x, @y);

	SELECT @errvalue = Abs(@tmpN - @LatitudeN);

	SELECT @LatitudeN = @tmpN;
END

-- Convert from radians to degrees and format as decimal minutes
SELECT @LatitudeN = 180 * @LatitudeN / PI();

SELECT @longitudeN = 180 * @longitudeN / PI();

SELECT @latitudeN
	,@longitudeN;

DROP TABLE #myfinds;
