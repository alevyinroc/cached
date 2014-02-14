CREATE TRIGGER [UpdateStaticLatLong]
ON TriggerGeoColumn
after insert, update
AS
BEGIN
	SET NOCOUNT ON   

	declare @newlat float(53),@newlong float(53)
	select @newlat = latitude, @newlong = longitude	 from INSERTED;
	update T set latlong = dbo.GeoPoint(@newlat,@newlong) from TriggerGeoColumn as T WHERE EXISTS (SELECT 1 FROM inserted WHERE ID = t.ID);
END
