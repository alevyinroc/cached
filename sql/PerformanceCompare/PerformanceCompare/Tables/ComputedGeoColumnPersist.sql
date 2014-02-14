CREATE TABLE [dbo].[ComputedColumnPersist]
(
	[Id] INT NOT NULL PRIMARY KEY,
	    [latitude]    FLOAT (53)      NOT NULL,
    [longitude]   FLOAT (53)      NOT NULL,
	[latlong]     AS              GeoPoint(longitude,latitude) PERSISTED
		check (latitude >= -90 and latitude <= 90)
	check (longitude >= -180 and longitude <= 180)
)
