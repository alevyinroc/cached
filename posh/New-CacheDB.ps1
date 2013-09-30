#requires -version 2.0
Clear-Host;
Push-Location;
if ((Get-Module|Where-Object{$_.name -eq "sqlps"}|Measure-Object).count -lt 1){
	Import-Module sqlps;
}
#region Globals
$MyServer = "Hobbes\sqlexpress";
#endregion

$FilesToProcess = get-childitem -path "C:\Users\andy\Documents\Code\cachedb\sql\DBSetup" -filter *.sql|sort-object -property BaseName;
foreach ($file in $FilesToProcess) {
	"Processing file $file";
	Invoke-Sqlcmd -InputFile $file.FullName -ServerInstance $MyServer;
}
Remove-Module sqlps;
Pop-Location;