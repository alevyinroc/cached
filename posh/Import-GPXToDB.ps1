$CurDir = $pwd;
import-module sqlps;
# Import downloaded GPX
set-location $CurDir;

#region Globals
$MyServer = 'Hobbes\sqlexpress';
$MyDatabase = 'Geocaches';
$SQLConnectionString = "Server=$MyServer;Database=$MyDatabase;Trusted_Connection=True;";
$CheckForAttributeQuery = "select count(1) as attrexists from attributes where attributeid = ATTRID;";
$InsertAttributeQuery = "insert into attributes (attributeid,attributename) values (ATTRID, 'ATTRNAME');";
$CheckForTBQuery = "select count(1) as tbexists from travelbugs where tbinternalid = TBID;";
$InsertTBQuery = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (TBID, 'TBTRACKINGID', 'TBNAME');";

$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();
#endregion

#region functions
function Get-DBTypeFromTrueFalse{
param (
	[string]$XmlValue
)
	switch ($XmlValue.ToLower()) {
		"true" { 1; }
		"false" { 0; }
		default { 0;}
	}
}
#endregion

[xml]$cachedata = get-content C:\Users\andy\Documents\Code\cachedb\scratchpad\GC3PF88.gpx;
$GCNum = $cachedata.gpx.wpt.name;
$CacheLoadCmd = $SQLConnection.CreateCommand();
$CacheExistsCmd = $SQLConnection.CreateCommand();
$CacheExistsCmd.CommandText = "select count(1) from caches where cacheid = @CacheId;";
$CacheExistsCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar,8);
$CacheExistsCmd.Parameters["@CacheId"].Value = $GCNum;
$CacheExists = $CacheExistsCmd.ExecuteScalar();

# Get Type & Size lookup tables
$PointTypeLookup = invoke-sqlcmd -server $MyServer -database $MyDatabase -query "select typeid, typename from point_types;";
$CacheSizeLookup = invoke-sqlcmd -server $MyServer -database $MyDatabase -query "select sizeid, sizename from cache_sizes;";

# Load/Update cache table
# TODO: Use GPX time for Last Updated. $cachedata.gpx.time
if (!$CacheExists){
    $CacheLoadCmd.CommandText = @"
INSERT INTO [dbo].[caches]
           ([cacheid]
           ,[gsid]
           ,[cachename]
           ,[latitude]
           ,[longitude]
           ,[latlong]
           ,[lastupdated]
           ,[placed]
           ,[placedby]
           ,[typeid]
           ,[sizeid]
           ,[difficulty]
           ,[terrain]
           ,[countryid]
           ,[stateid]
           ,[shortdesc]
           ,[longdesc]
           ,[hint]
           ,[available]
           ,[archived]
           ,[premiumonly])
     VALUES
           (@CacheId
           ,@GSID
           ,@CacheName
           ,@Lat
           ,@Long
           ,@LatLong
           ,getdate()
           ,@Placed
           ,@PlacedBy
           ,@TypeId
           ,@SizeId
           ,@Diff
           ,@Terrain
           ,@ShortDesc
           ,@LongDesc
           ,@Hint
           ,@Avail
           ,@Archived
           ,@PremOnly
           );
"@;
} else {
    $CacheLoadCmd.CommandText = @"
UPDATE [dbo].[caches]
   SET [gsid] = @gsid
      ,[cachename] = @CacheName
      ,[latitude] = @Lat
      ,[longitude] = @Long
      ,[latlong] = @LatLong
      ,[lastupdated] = getdate()
      ,[placed] = @Placed
      ,[placedby] = @PlacedBy
      ,[typeid] = @TypeId
      ,[sizeid] = @SizeId
      ,[difficulty] = @Diff
      ,[terrain] = @Terrain
      ,[shortdesc] = @ShortDesc
      ,[longdesc] = @LongDesc
      ,[hint] = @Hint
      ,[available] = @Avail
      ,[archived] = @Archived
      ,[webpage] = @Webpage
      ,[premiumonly] = @PremOnly
 WHERE CacheId = @CacheId;
"@;
}
# Set parameters
$CacheLoadCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar, 8);
$CacheLoadCmd.Parameters.Add("@gsid", [System.Data.SqlDbType]::int);
$CacheLoadCmd.Parameters.Add("@CacheName", [System.Data.SqlDbType]::nvarchar, 50);
$CacheLoadCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::float);
$CacheLoadCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::float);
$CacheLoadCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::float);
$CacheLoadCmd.Parameters.Add("@Placed", [System.Data.SqlDbType]::datetime);
$CacheLoadCmd.Parameters.Add("@PlacedBy", [System.Data.SqlDbType]::nvarchar);
$CacheLoadCmd.Parameters.Add("@TypeId", [System.Data.SqlDbType]::int);
$CacheLoadCmd.Parameters.Add("@SizeId", [System.Data.SqlDbType]::int);
$CacheLoadCmd.Parameters.Add("@Diff", [System.Data.SqlDbType]::float);
$CacheLoadCmd.Parameters.Add("@Terrain", [System.Data.SqlDbType]::float);
$CacheLoadCmd.Parameters.Add("@ShortDesc", [System.Data.SqlDbType]::nvarchar, 5000);
$CacheLoadCmd.Parameters.Add("@LongDesc", [System.Data.SqlDbType]::ntext);
$CacheLoadCmd.Parameters.Add("@Hint", [System.Data.SqlDbType]::nvarchar, 1000);
$CacheLoadCmd.Parameters.Add("@Avail", [System.Data.SqlDbType]::bit);
$CacheLoadCmd.Parameters.Add("@Archived", [System.Data.SqlDbType]::bit);
$CacheLoadCmd.Parameters.Add("@PremOnly", [System.Data.SqlDbType]::bit);
# Handle the "point" parameter specially.
# TODO: Not working quite right. "UdtTypeName property must be set only for UDT parameters."
$GeoParam = new-object System.Data.SqlClient.SqlParameter;
$GeoParam.Direction = [System.Data.SqlClient.SqlParameter.ParameterDirection]::Input;
$GeoParam.ParameterName = "@LatLong";
$GeoParam.SqlDbType = [System.Data.SqlClient.SqlDbType]::Udt;
$GeoParam.UdtTypeName = "GEOGRAPHY";
$GeoParam.SourceVersion = [System.Data.DataRowVersion]::Current;
$GeoParam.Value = "geography::STGeomFromText('POINT($($cachedata.gpx.wpt.lon) $($cachedata.gpx.wpt.lat))', 4326)";
$CacheLoadCmd.Parameters.Add($GeoParam);
$CacheLoadCmd.Parameters["@CacheId"].Value = $CacheId;
$CacheLoadCmd.Parameters["@gsid"].Value = $cachedata.gpx.wpt.cache.id;
$CacheLoadCmd.Parameters["@CacheName"].Value = $cachedata.gpx.wpt.cache.name;
$CacheLoadCmd.Parameters["@Lat"].Value = $cachedata.gpx.wpt.lat;
$CacheLoadCmd.Parameters["@Long"].Value = $cachedata.gpx.wpt.lon;
#TODO: Broken
$CacheLoadCmd.Parameters["@Placed"].Value = get-date $cachedata.gpx.wpt.time;
$CacheLoadCmd.Parameters["@PlacedBy"].Value = $cachedata.gpx.wpt.cache.placed_by;
$CacheLoadCmd.Parameters["@TypeId"].Value = $PointTypeLookup|?{$_.typename -eq $cachedata.gpx.wpt.cache.type}|select -expandproperty typeid;
$CacheLoadCmd.Parameters["@SizeId"].Value = $CacheSizeLookup|?{$_.sizename -eq $cachedata.gpx.wpt.cache.container}|select -expandproperty sizeid;
$CacheLoadCmd.Parameters["@Diff"].Value = $cachedata.gpx.wpt.cache.difficulty;
$CacheLoadCmd.Parameters["@Terrain"].Value = $cachedata.gpx.wpt.cache.terrain;
$CacheLoadCmd.Parameters["@ShortDesc"].Value = $cachedata.gpx.wpt.cache.short_description;
$CacheLoadCmd.Parameters["@LongDesc"].Value = $cachedata.gpx.wpt.cache.long_description
$CacheLoadCmd.Parameters["@Hint"].Value = $cachedata.gpx.wpt.cache.encoded_hints;
$CacheLoadCmd.Parameters["@Avail"].Value = Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.cache.available;
$CacheLoadCmd.Parameters["@Archived"].Value = Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.cache.archived;
# TODO: Figure out where premium only comes from. Doesn't appear to be in the GPX
$CacheLoadCmd.Parameters["@PremOnly"].Value = 0; #Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.

# Execute
$CacheLoadCmd.ExecuteNonQuery();

# Load cacher table if no record for current cache's owner, or update name
$OwnerId = $cachedata.gpx.wpt.cache.owner.id;
$OwnerName = $cachedata.gpx.wpt.cache.owner|select-object -expandproperty "#text";

$OwnerExistsCmd = $SQLConnection.CreateCommand();
$OwnerExistsCmd.CommandText = "select count(1) as CacherExists from cachers where cacherid = @OwnerId;"
$OwnerExistsCmd.Parameters.Add("@OwnerId", [System.Data.SqlDbType]::int);
$OwnerExistsCmd.Parameters["@OwnerId"].Value = $OwnerId;
$OwnerExists = $OwnerExistsCmd.ExecuteScalar();

$CacherTableUpdateCmd = $SQLConnection.CreateCommand();
if ($OwnerExists){
# Update owner name if it's changed
	$CacherTableUpdateCmd.CommandText = "update cachers set cachername = @OwnerName where cacherid = @OwnerId and cachername <> @OwnerName;";
} else {
    $CacherTableUpdateCmd.CommandText = "insert into cachers (cacherid, cachername) values (@OwnerId, @OwnerName);";
}

# TODO: Would AddWithValue be better?
$CacherTableUpdateCmd.Parameters.Add("@OwnerId", [System.Data.SqlDbType]::int).Value = $OwnerId;
$CacherTableUpdateCmd.Parameters.Add("@OwnerName", [System.Data.SqlDbType]::varchar, 50).Value = $OwnerName;;
$CacherTableUpdateCmd.ExecuteNonQuery();

# Check to see if cache is already on the owner table. If owner has changed, update with new value. If cache isn't on the table, add it
$CacheHasOwner = invoke-sqlcmd -server $myserver -database $mydatabase -query "select count(1) as CacheOnOwners from cache_owners where cacheid = '$GCNum';"|select-object -expandproperty CacheOnOwners;
if ($CacheHasOwner) {
    $OwnerMatches = invoke-sqlcmd -server $myserver -database $mydatabase -query "select count(1) as OwnerMatches from cache_owners where cacheid = '$GCNum' and cacherid = $OwnerId;"|select-object -expandproperty OwnerMatches;
    if (!$OwnerMatches) {
        invoke-sqlcmd -server $myserver -database $mydatabase -query "update cache_owners set cacherid = $OwnerId where cacheid = '$GCNum';";
    }
} else {
    invoke-sqlcmd -server $myserver -database $mydatabase -query "insert into cache_owners (cacherid, cacheid) values ($OwnerId, '$GCNum');";
}

# Insert attributes & TBs into respective tables
$attributes = $cachedata.gpx.wpt.cache.attributes|foreach-object{$_.attribute|select id,"#text"};
$tbs = $cachedata.gpx.wpt.cache.travelbugs|foreach-object{$_.travelbug};

$attributes | foreach-object {
# TODO: Use PreparedStatement & ExecuteScalar()
    $AttrExists = invoke-sqlcmd -server $MyServer -database $MyDatabase -query $CheckForAttributeQuery.Replace("ATTRID", $_.id)|select-object -expandproperty attrexists;
    if (!$AttrExists) {
# TODO: Use PreparedStatement & ExecuteNonQuery()
        invoke-sqlcmd -server $MyServer -database $MyDatabase -query $InsertAttributeQuery.Replace("ATTRID", $_.id).Replace("ATTRNAME", $($_|select-object -expandproperty "#text"));
    }
}

$tbs | foreach-object {
# TODO: Use PreparedStatement & ExecuteScalar()
    $TBExists = invoke-sqlcmd -server $MyServer -database $MyDatabase -query $CheckForTBQuery.Replace("TBID", $_.id)|select-object -expandproperty tbexists;
    if (!$TBExists) {
# TODO: Use PreparedStatement & ExecuteNonQuery()
# TODO: Properly escape characters for input. Should go along with the PreparedStatement
        invoke-sqlcmd -server $MyServer -database $MyDatabase -query $InsertTBQuery.Replace("TBID", $_.id).Replace("TBNAME", $($_.name).replace("'","&APOS;")).Replace("TBTRACKINGID", $_.ref);
    }
}

# Link attributes & TBs to caches
$SQLConnection.Close();
remove-module sqlps;