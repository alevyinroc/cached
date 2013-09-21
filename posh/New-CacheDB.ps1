#requires -version 2.0

#region Globals
$MyServer = 'Hobbes\sqlexpress';
$SQLConnectionString = "Server=$MyServer;Trusted_Connection=True;";
$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();
#endregion

$FilesToProcess = get-childitem -path "..\sql\DBSetup" -filter *.sql|sort-object -property BaseName;
$DBSetupCmd = $SQLConnection.CreateCommand();
$DBSetupCmd.Parameters.Add("@DBID", [System.Data.SqlDbType]::varchar, 20).Value = "Geocaches"|out-null;
foreach ($file in $FilesToProcess) {
	$DBSetupCmd.CommandText = Get-Content $file.FullName;
	$DBSetupCmd.ExecuteNonQuery();	
}
$SQLConnection.Close();
