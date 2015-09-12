CREATE TABLE [dbo].[ComputedColumnPersist]
(
	[Id] INT identity(1,1) NOT NULL PRIMARY KEY,
	    [latitude]    FLOAT (53)      NOT NULL,
    [longitude]   FLOAT (53)      NOT NULL,
	[latlong]     AS              ([geography]::Point([latitude],[longitude],(4326))) PERSISTED
		check (latitude >= -90 and latitude <= 90)
	check (longitude >= -180 and longitude <= 180)
)
