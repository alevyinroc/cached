CREATE TABLE [dbo].[NoGeoColumn]
(
	[Id] INT NOT NULL PRIMARY KEY,
	[latitude]    FLOAT (53)      NOT NULL,
    [longitude]   FLOAT (53)      NOT NULL
	check (latitude >= -90 and latitude <= 90)
	check (longitude >= -180 and longitude <= 180)
)
