CREATE FUNCTION [dbo].[GeoPoint]
(
	@lat float(53),
	@long float(53)
)
RETURNS geography
AS
BEGIN
	RETURN geography::STGeomFromText('Point(' + cast(@long as varchar(20)) + ' ' + cast(@lat as varchar(20)) + ')',4326);
END
