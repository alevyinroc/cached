#requires -version 2.0
Push-Location;
if ((Get-Module|where-object{$_.name -eq "sqlps"}|Measure-Object).count -lt 1){
	Import-Module sqlps;
}
#region Globals
$MyServer = "Hobbes\sqlexpress";
#endregion

$FilesToProcess = get-childitem -path "C:\Users\andy\Documents\Code\cachedb\sql\DBSetup" -filter *.sql|sort-object -property BaseName;
foreach ($file in $FilesToProcess) {
	Invoke-Sqlcmd -InputFile $file.FullName -ServerInstance $MyServer;
}
Remove-Module sqlps;
Pop-Location;