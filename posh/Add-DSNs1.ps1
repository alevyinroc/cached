Get-OdbcDsn -Name GSAKMyFinds;
Get-OdbcDsn -Name GSAKMyFinds | Select-Object -ExpandProperty Attribute |Format-Table -AutoSize;
Get-OdbcDriver -name "SQLite3 ODBC Driver";
Add-OdbcDsn -Name GSAKPuzzles -DriverName "SQLite3 ODBC Driver" -Platform 64-bit -DsnType System -SetPropertyValue "Database=C:\Users\andy\Dropbox\GSAK8\data\Far-off puzzles\sqlite.db3";
Get-OdbcDsn -Name GSAKPuzzles;
Get-OdbcDsn -Name GSAKPuzzles | Select-Object -ExpandProperty Attribute |Format-Table -AutoSize;

Get-OdbcDsn -DriverName "SQLite3 ODBC Driver"|?{$_.name -like "gsak*" -and $_.name -notlike "*main"}|Remove-OdbcDsn;

get-childitem C:\users\andy\Dropbox\gsak8\data -recurse -filter sqlite.db3|select fullname,basename;