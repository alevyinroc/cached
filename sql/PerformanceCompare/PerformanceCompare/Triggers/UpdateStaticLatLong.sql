CREATE TRIGGER [UpdateStaticLatLong]
ON TriggerGeoColumn
after insert, update
AS
BEGIN
	SET NOCOUNT ON
	
END
