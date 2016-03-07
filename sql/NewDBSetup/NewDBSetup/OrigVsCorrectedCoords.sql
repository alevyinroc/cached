CREATE VIEW [dbo].[OrigVsCorrectedCoords]
	AS SELECT LatLong,CorrectedLatLong, CorrectedLatLong::STDistance(LatLong)/1000 as [Distance from Original] FROM [Caches]
