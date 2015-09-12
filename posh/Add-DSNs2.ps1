﻿Get-ChildItem -Path C:\users\andy.levynetscus\Dropbox\gsak8\data -Recurse -Filter sqlite.db3|Select-Object -ExpandProperty FullName | ForEach-Object {
	$DSNName = $_.split("\")[6];
	Add-OdbcDsn -Name $DSNName -DriverName "SQLite3 ODBC Driver" -Platform 64-bit -DsnType System -SetPropertyValue "Database=$_";
};
Get-OdbcDsn -DriverName "SQLite3 ODBC Driver" | Format-Table -AutoSize;
Get-OdbcDsn -DriverName "SQLite3 ODBC Driver" | Format-Table -AutoSize | Out-File -FilePath C:\Users\andy\Documents\cachedb\createdDSNs.txt;