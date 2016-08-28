#require -version 3
#require -module sqlserver

   Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({Test-Path -type container -path $_})]
        $GSAKDataDirectory = "C:\Users\andy\Dropbox\GSAK8\data",
        [Parameter(Mandatory=$true,Position=1)]
        $ServerInstance = ".\sql2016"
    )

    Begin
    {
    }
    Process
    {
    Get-OdbcDsn | Where-Object {$_.name -notlike "sqlite*"}|Remove-OdbcDsn;
    Get-ChildItem -Path $GSAKDataDirectory -Recurse -Filter sqlite.db3|Select-Object -ExpandProperty FullName | ForEach-Object {
        $DSNName = $_.split("\")[6];
        Add-OdbcDsn -Name $DSNName -DriverName "SQLite3 ODBC Driver" -Platform 64-bit -DsnType System -SetPropertyValue "Database=$_";
    };
 
    $AllDSNs = Get-OdbcDsn -DriverName "SQLite3 ODBC Driver"|where-object {$_.name -notlike "sqlite*"};
    foreach ($DSN in $AllDSNs) {
        $CreateLinkedServerSP =@"
    EXEC master.dbo.sp_addlinkedserver @server = N'$($DSN.Name)', @srvproduct=N'$($DSN.Name)', @provider=N'MSDASQL', @datasrc=N'$($DSN.Name)';
    EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'$($DSN.Name)',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL;
"@;
        invoke-sqlcmd -query $CreateLinkedServerSP -serverinstance $ServerInstance -database master;
    }
}
End {}