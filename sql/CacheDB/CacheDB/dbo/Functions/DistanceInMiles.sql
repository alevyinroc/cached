CREATE FUNCTION [dbo].[DistanceInMiles]
(
	@point1 geography,
  @point2 geography
)
RETURNS float
AS
BEGIN
	RETURN (@point1.STDistance(@point2)/1000) * 0.62137
END
