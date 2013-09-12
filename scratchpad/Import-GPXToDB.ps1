import-module sqlps;
# Import downloaded GPX
[xml]$cachedata = get-content C:\users\andy\Downloads\GCF7C6.gpx;

# Insert attributes & TBs into respective tables
$attributes = $cachedata.gpx.wpt.cache.attributes|foreach-object{$_.attribute|select id,"#text"};
$tbs = $cachedata.gpx.wpt.cache.travelbugs|foreach-object{$_.travelbug};

$CheckForAttributeQuery = "select count(1) as attrexists from attributes where attributeid = ATTRID;";
$InsertAttributeQuery = "insert into attributes (attributeid,attributename) values (ATTRID, 'ATTRNAME');";
$CheckForTBQuery = "select count(1) as tbexists from travelbugs where tbinternalid = TBID;";
$InsertTBQuery = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (TBID, 'TBTRACKINGID', 'TBNAME');";


$attributes | foreach-object {
# TODO: Use PreparedStatement & ExecuteScalar()
    $AttrExists = invoke-sqlcmd -server 'hobbes\sqlexpress' -database Geocaches -query $CheckForAttributeQuery.Replace("ATTRID", $_.id)|select-object -expandproperty attrexists;
    if (!$AttrExists) {
# TODO: Use PreparedStatement & ExecuteNonQuery()
        invoke-sqlcmd -server 'hobbes\sqlexpress' -database Geocaches -query $InsertAttributeQuery.Replace("ATTRID", $_.id).Replace("ATTRNAME", $($_|select-object -expandproperty "#text"));
    }
}

$tbs | foreach-object {
# TODO: Use PreparedStatement & ExecuteScalar()
    $TBExists = invoke-sqlcmd -server 'hobbes\sqlexpress' -database Geocaches -query $CheckForTBQuery.Replace("TBID", $_.id)|select-object -expandproperty tbexists;
    if (!$TBExists) {
# TODO: Use PreparedStatement & ExecuteNonQuery()
# TODO: Properly escape characters for input. Should go along with the PreparedStatement
        invoke-sqlcmd -server 'hobbes\sqlexpress' -database Geocaches -query $InsertTBQuery.Replace("TBID", $_.id).Replace("TBNAME", $($_.name).replace("'","&APOS;")).Replace("TBTRACKINGID", $_.ref);
    }
}

remove-module sqlps;