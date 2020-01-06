/****** Object:  UserDefinedFunction [dbo].[Bearing]    Script Date: 9/8/2013 12:12:04 PM ******/
USE Geocaches;
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Bearing] (
  @point1 geography,
  @point2 geography  )
RETURNS float
AS
BEGIN
  DECLARE @Bearing decimal(18,15)
  DECLARE @Lat1 float = Radians(@point1.Lat)
  DECLARE @Lat2 float = Radians(@point2.Lat)
  DECLARE @dLon float = Radians(@point2.Long - @point1.Long)
  IF (@point1.STEquals(@point2) = 1)
SET @Bearing = NULL
  ELSE
SET @Bearing = ATN2(
SIN(@dLon) * COS(@Lat2),
(COS(@Lat1) * SIN(@Lat2)) - (SIN(@Lat1) * COS(@Lat2) * COS(@dLon))
)
  SET @Bearing = (DEGREES(@Bearing) + 360) % 360
  RETURN @Bearing
END

GO