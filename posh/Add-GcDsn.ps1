import-module dbatools
function Add-GcDsn {
    Param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( { Test-Path -type container -path $_ })]
        [string]$GSAKDataDirectory = "C:\Users\Andy\OneDrive\GSAK8\data",
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$SqlInstance = "localhost\sql17"
    )

    Begin {
    }
    Process {
        Get-OdbcDsn | Where-Object { $_.Name -notlike "sqlite*" } | Remove-OdbcDsn;
        Get-ChildItem -Path $GSAKDataDirectory -Recurse -Filter sqlite.db3 | Select-Object -ExpandProperty FullName | ForEach-Object {
            $DSNName = $_.split("\")[6];
            Add-OdbcDsn -Name $DSNName -DriverName "SQLite3 ODBC Driver" -Platform 64-bit -DsnType System -SetPropertyValue "Database=$_";
        };

        $AllDSNs = Get-OdbcDsn -DriverName "SQLite3 ODBC Driver" | where-object { $_.name -notlike "sqlite*" };
        foreach ($DSN in $AllDSNs) {
            $CreateLinkedServerSP = @"
            EXEC master.dbo.sp_addlinkedserver @server = N'$($DSN.Name)', @srvproduct=N'$($DSN.Name)', @provider=N'MSDASQL', @datasrc=N'$($DSN.Name)';
            EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'$($DSN.Name)',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL;
"@;
            Invoke-DbaQuery -query $CreateLinkedServerSP -sqlinstance $SqlInstance -database master;
        }
    }
    End {
    }
}