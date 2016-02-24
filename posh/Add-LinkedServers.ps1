#require -version 3.0
#requires -module sqlps
set-strictmode -Version latest;
set-location c:;

$AllDSNs = Get-OdbcDsn -DriverName "SQLite3 ODBC Driver";
foreach ($DSN in $AllDSNs) {
    $CreateLinkedServerSP =@"
EXEC master.dbo.sp_addlinkedserver @server = N'$($DSN.Name)', @srvproduct=N'$($DSN.Name)', @provider=N'MSDASQL', @datasrc=N'$($DSN.Name)';
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'$($DSN.Name)',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL;
"@;
    invoke-sqlcmd -query $CreateLinkedServerSP -serverinstance andrewle-a2981\sql2016ctp33 -database master;
}

$AllDSNs = Get-OdbcDsn -DriverName "SQLite3 ODBC Driver";
$AllDatabasesUnion = "";
foreach ($DSN in $AllDSNs) {
    $AllDatabasesUnion += "SELECT * FROM OPENQUERY([$($DSN.Name)], 'select * from caches') UNION ALL`n";
}
$AllDatabasesUnion = $AllDatabasesUnion.Substring(0,$AllDatabasesUnion.Length - 10);
Write-Output $AllDatabasesUnion;
$AllDatabasesUnion | out-file "f:\azure acct 1\cachedb\sql\Queries\UnionAllDBs-2016.sql"