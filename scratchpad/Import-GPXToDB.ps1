﻿$CurDir = $pwd;
import-module sqlps;
# Import downloaded GPX
set-location $CurDir;

#region Globals
$MyServer = 'Hobbes\sqlexpress';
$MyDatabase = 'Geocaches';
$CheckForAttributeQuery = "select count(1) as attrexists from attributes where attributeid = ATTRID;";
$InsertAttributeQuery = "insert into attributes (attributeid,attributename) values (ATTRID, 'ATTRNAME');";
$CheckForTBQuery = "select count(1) as tbexists from travelbugs where tbinternalid = TBID;";
$InsertTBQuery = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (TBID, 'TBTRACKINGID', 'TBNAME');";
#endregion

[xml]$cachedata = get-content C:\users\andy\Downloads\GCF7C6.gpx;
$GCNum = $cachedata.gpx.wpt.name;

# Load cacher table if no record for current cache's owner, or update name
$OwnerId = $cachedata.gpx.wpt.cache.owner.id;
$OwnerName = $cachedata.gpx.wpt.cache.owner|select-object -expandproperty "#text";

$OwnerExists = invoke-sqlcmd -server $MyServer -database $MyDatabase -query "select count(1) as CacherExists from cachers where cacherid = $OwnerId;" | select-object -expandproperty CacherExists;
if ($OwnerExists){
# Update owner name if it's changed
    Invoke-sqlcmd -server $MyServer -Database $MyDatabase -query "update cachers set cachername = '$OwnerName' where cacherid = $OwnerId and cachername <> '$OwnerName';";
} else {
    invoke-sqlcmd -server $myserver -database $mydatabase -query "insert into cachers (cacherid, cachername) values ($OwnerId, '$OwnerName');";
}

# Insert/update cache on caches table. This has to be done before owner checks because of FK constraints

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

remove-module sqlps;