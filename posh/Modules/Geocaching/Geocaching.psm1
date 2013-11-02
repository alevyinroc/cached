function Set-CorrectedCoordinates {
<#
.SYNOPSIS
	Adds/updates corrected coordinates for a cache
.DESCRIPTION
	Adds/updates corrected coordinates for a cache. Confirmation is required to overwrite pre-existing corrected coordinates for the cache.
.PARAMETER CacheId
	Public ID (GC code) of the cache to be updated
.PARAMETER Latitude
	Corrected latitude
.PARAMETER Longitude
	Corrected longitude
.PARAMETER CorrectedDetails
	A PSObject containing the following properties:
		CacheId (string)
		Latitude (float)
		Longitude (float)
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheDetails")]
	[string]$CacheId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheDetails")]
	[alias("Lat")]
	[float]$Latitude,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheDetails")]
	[alias("Long")]
	[float]$Longitude,
	[Parameter(Mandatory=$true,ParameterSetName="UpdateObject",ValueFromPipeline=$true)]
	[PSObject[]]$CorrectedDetails,
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	begin {
		$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
		$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
		$SQLConnection.ConnectionString = $SQLConnectionString;
		$SQLConnection.Open();
		$UpdateCoordsCmd = $SQLConnection.CreateCommand();
		$UpdateCoordsCmd.CommandText = "update caches set CorrectedLatitude = @lat, CorrectedLongitude = @long where CacheId = @cacheid;";
		$UpdateCoordsCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::Char, 8) | Out-Null;
		$UpdateCoordsCmd.Parameters.Add("@lat", [System.Data.SqlDbType]::Float) | Out-Null;
		$UpdateCoordsCmd.Parameters.Add("@long", [System.Data.SqlDbType]::Float) | Out-Null;
		$UpdateCoordsCmd.Prepare();
		$CheckForCorrectedCmd = $SQLConnection.CreateCommand();
		$CheckForCorrectedCmd.CommandText = "select 1 from caches where cacheid = @cacheid and CorrectedLatitude is not null and CorrectedLongitude is not null;";
		$CheckForCorrectedCmd.Parameters.Add("@cacheid",[System.Data.SqlDbType]::Char, 8) | Out-Null;
		$CheckForCorrectedCmd.Prepare();
	}
	process {
		switch ($PsCmdlet.ParameterSetName) {
			"UpdateObject" {$CacheId = $CorrectedDetails.CacheId;$Latitude= $CorrectedDetails.Latitude;$Longitude= $CorrectedDetails.Longitude;}
		}
		$CheckForCorrectedCmd.Parameters["@cacheid"].Value = $CacheId;
		$HasCorrected = $CheckForCorrectedCmd.ExecuteScalar();
		if ($HasCorrected -and $pscmdlet.ShouldProcess()) {
			$UpdateCoordsCmd.Parameters["@cacheid"].Value = $CacheId;
			$UpdateCoordsCmd.Parameters["@lat"].Value = $Latitude;
			$UpdateCoordsCmd.Parameters["@long"].Value = $Longitude;
			$UpdateCoordsCmd.ExecuteNonQuery();
		}
	}		
	end {
		$CheckForCorrectedCmd.Dispose();
		$UpdateCoordsCmd.Dispose();
		$SQLConnection.Close();
		$SQLConnection.Dispose();
	}
}

function New-StateCountryId {
<#
.SYNOPSIS
	Adds a new state or country to the database
.DESCRIPTION
	Adds a new state or country to the database and returns its ID.
.PARAMETER Name
	Name of the new state or country to add
.PARAMETER Type
	Type of location to add
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param(
	[Parameter(Mandatory=$true)]
	[string]$Name,
	[Parameter(Mandatory=$true)]
	[ValidateSet("State","Country")]
	[string]$Type,
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
	$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
	$SQLConnection.ConnectionString = $SQLConnectionString;
	$SQLConnection.Open();
	$NewStateCountryCmd = $SQLConnection.CreateCommand();
	$NewStateCountryCmd.Parameters.Add("@Name", [System.Data.SqlDbType]::NChar, 50) | Out-Null;
	$GetIdCmd = $SQLConnection.CreateCommand();
	$GetIdCmd.Parameters.Add("@Name", [System.Data.SqlDbType]::NChar, 50) | Out-Null;
	switch ($Type) {
		"State" {$NewStateCountryCmd.CommandText = "insert into States (Name) values (@Name);";$GetIdCmd.CommandText = "select StateId from States where Name = @Name;"}
		"Country"{$NewStateCountryCmd.CommandText = "insert into Countries (Name) values (@Name);";$GetIdCmd.CommandText = "select CountryId from Countries where Name = @Name;"}
	}
	$NewStateCountryCmd.Prepare();
	$GetIdCmd.Prepare();
	$NewStateCountryCmd.Parameters["@Name"].Value = $Name;
	$GetIdCmd.Parameters["@Name"].Value = $Name;
	$NewStateCountryCmd.ExecuteNonQuery() | Out-Null;
	$NewId = $GetIdCmd.ExecuteScalar();
	$NewStateCountryCmd.Dispose();
	$GetIdCmd.Dispose();
	$SQLConnection.Close();
	$SQLConnection.Dispose();
	$NewId;
}

function Get-StateLookups {
	$StateLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select StateId, Name from states order by StateId Desc;";
	$StateLookup;
}
function Get-CountryLookups {
	$CountryLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select CountryId, Name from Countries order by CountryId Desc;";
	$CountryLookup;
}

Export-ModuleMember Set-CorrectedCoordinates,New-StateCountryId,Get-StateLookups,Get-CountryLookups