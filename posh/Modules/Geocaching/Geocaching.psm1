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
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
    [Alias("Database")]
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
# TODO: Properly support confirmation/whatif
	begin {
		switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
            $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
            $DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
		}
	}
		$UpdateCoordsCmd = $DBConnection.CreateCommand();
		$UpdateCoordsCmd.CommandText = "update caches set CorrectedLatitude = @lat, CorrectedLongitude = @long where CacheId = @cacheid;";
		$UpdateCoordsCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::Char, 8) | Out-Null;
		$UpdateCoordsCmd.Parameters.Add("@lat", [System.Data.SqlDbType]::Float) | Out-Null;
		$UpdateCoordsCmd.Parameters.Add("@long", [System.Data.SqlDbType]::Float) | Out-Null;
		$UpdateCoordsCmd.Prepare();
		$CheckForCorrectedCmd = $DBConnection.CreateCommand();
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
#If there are already corrected coordinates, check for confirmation before changing them
		if ((-not $HasCorrected) -or ($HasCorrected -and $pscmdlet.ShouldProcess($CacheId))) {
			$UpdateCoordsCmd.Parameters["@cacheid"].Value = $CacheId;
			$UpdateCoordsCmd.Parameters["@lat"].Value = $Latitude;
			$UpdateCoordsCmd.Parameters["@long"].Value = $Longitude;
			$UpdateCoordsCmd.ExecuteNonQuery();
		}
	}
	end {
		$CheckForCorrectedCmd.Dispose();
		$UpdateCoordsCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Get-StateLookup {
<#
.SYNOPSIS
	Gets all states from the database
.DESCRIPTION
	Gets all states from the database
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param (
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	$StateLookup = Get-DataFromQuery -DBConnection $DBConnection -query "select StateId, rtrim(ltrim(Name)) as Name from states order by StateId Desc;";
	$StateLookup;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-CountryLookup {
<#
.SYNOPSIS
	Gets all countries from the database
.DESCRIPTION
	Gets all countries from the database
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param (
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	$CountryLookup = Get-DataFromQuery -DBConnection $DBConnection -query "select CountryId, rtrim(ltrim(Name)) as Name from Countries order by CountryId Desc;";
	$CountryLookup;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-PointTypeLookups {
<#
.SYNOPSIS
	Gets all point types from the database
.DESCRIPTION
	Gets all point types from the database
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param (
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	$PointTypeLookup = Get-DataFromQuery -DBConnection $DBConnection -query "select typeid, typename from point_types;";
	$PointTypeLookup;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-CacheSizeLookup {
<#
.SYNOPSIS
	Gets all cache sizes from the database
.DESCRIPTION
	Gets all cache sizes from the database
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param (
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	$CacheSizeLookup = Get-DataFromQuery -DBConnection $DBConnection -query "select sizeid, sizename from cache_sizes;";
	$CacheSizeLookup;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-CacheStatusLookup {
<#
.SYNOPSIS
	Gets all cache statuses from the database
.DESCRIPTION
	Gets all cache statuses from the database
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param (
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	$CacheStatusLookup = Get-DataFromQuery -DBConnection $DBConnection -query "select statusid, statusname from statuses;";
	$CacheStatusLookup;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-PointTypeId {
<#
.SYNOPSIS
	Looks up a point type by name and gets its ID
.DESCRIPTION
	Looks up a point type by name and gets its ID. If the type name doesn't exist, a new one is created.
.PARAMETER TypeName
	Name of the point type to look up
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$PointTypeName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
# TODO: Make Pipeline-aware
# TODO: Pass in database connection or connection string (like Update-Geocache)
	if ($script:PointTypeLookup -eq $null) {
		$script:PointTypeLookup = Get-PointTypeLookups -DBConnection $DBConnection;
	}

    $PointTypeId = $script:PointTypeLookup | where-object{$_.typename -eq $PointTypeName} | Select-Object -ExpandProperty typeid;
	if ($PointTypeId -eq $null) {
		$PointTypeId = New-LookupEntry -LookupName $PointTypeName -DBConnection $DBConnection -LookupType Point;
		$script:PointTypeLookup = Get-PointTypeLookups -DBConnection $DBConnection;
	}
	$PointTypeId;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-CacheSizeId {
<#
.SYNOPSIS
	Looks up a cache size by name and gets its ID
.DESCRIPTION
	Looks up a cache size by name and gets its ID. If the size name doesn't exist, a new one is created.
.PARAMETER SizeName
	Name of the cache size to look up
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$SizeName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
# TODO: Make Pipeline-aware
# TODO: Pass in database connection or connection string (like Update-Geocache)
	if ($script:CacheSizeLookup -eq $null) {
		$script:CacheSizeLookup = Get-CacheSizeLookup -DBConnection $DBConnection;
	}

	$CacheSizeId = $script:CacheSizeLookup | where-object{$_.sizename -eq $SizeName} | Select-Object -ExpandProperty sizeid;
	if ($CacheSizeId -eq $null) {
		$CacheSizeId = New-LookupEntry -LookupName $SizeName -DBConnection $DBConnection -LookupType Size;
		$script:CacheSizeLookup = Get-CacheSizeLookup -DBConnection $DBConnection;
	}
	$CacheSizeId;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-CacheStatusId {
<#
.SYNOPSIS
	Looks up a cache status by name and gets its ID
.DESCRIPTION
	Looks up a cache status by name and gets its ID. If the status name doesn't exist, a new one is created.
.PARAMETER StatusName
	Name of the cache status to look up
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$StatusName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}	if ($script:CacheStatusLookup -eq $null) {
		$script:CacheStatusLookup = Get-CacheStatusLookup -DBConnection $DBConnection;
	}

	$CacheStatusId = $script:CacheStatusLookup | where-object{$_.statusname -eq $StatusName} | Select-Object -ExpandProperty statusid;

	if ($CacheStatusId -eq $null) {
		$CacheStatusId = New-CacheStatus -LookupName $StatusName -DBConnection $DBConnection -LookupType Status;
		$script:CacheStatusLookup = Get-CacheStatusLookup -DBConnection $DBConnection;
	}
	$CacheStatusId;
	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
}
function Get-StateId {
<#
.SYNOPSIS
	Looks up a state by name and gets its ID
.DESCRIPTION
	Looks up a state by name and gets its ID. If the status name doesn't exist, a new one is created.
.PARAMETER StateName
	Name of the state to look up
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
	[string]$StateName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	}
	process {
		if ($script:StateLookup -eq $null) {
			$script:StateLookup = Get-StateLookup -DBConnection $DBConnection;
		}

		$StateId = $script:StateLookup | where-object{$_.Name -eq $StateName} | Select-Object -ExpandProperty StateId;
		if ($StateId -eq $null) {
			$StateId = New-LookupEntry -LookupName $StateName -DBConnection $DBConnection -LookupType State;
			$script:StateLookup = Get-StateLookup -DBConnection $DBConnection;
		}
		$StateId;
	}
	end {
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Get-CountryId {
<#
.SYNOPSIS
	Looks up a country by name and gets its ID
.DESCRIPTION
	Looks up a country by name and gets its ID. If the status name doesn't exist, a new one is created.
.PARAMETER CountryName
	Name of the country to look up
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
	[string]$CountryName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	}
	process {
		if ($script:CountryLookup -eq $null) {
			$script:CountryLookup = Get-CountryLookup -DBConnection $DBConnection;
		}

		$CountryId = $script:CountryLookup | where-object{$_.Name -eq $CountryName} | Select-Object -ExpandProperty CountryId;
		if ($CountryId -eq $null) {
			$CountryId = New-LookupEntry -LookupName $CountryName -DBConnection $DBConnection -LookupType Country;
			$script:CountryLookup = Get-CountryLookup -DBConnection $DBConnection;
		}
		$CountryId;
	}
	end {
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}

}
function New-LookupEntry {
<#
.SYNOPSIS
	Adds a value to a database lookup table
.DESCRIPTION
	Adds a value to a database lookup table and returns its ID.
.PARAMETER LookupName
	Name of the lookup item to add
.PARAMETER LookupType
	Type of lookup item to add
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param(
	[Parameter(Mandatory=$true)]
	[string]$LookupName,
	[Parameter(Mandatory=$true)]
	[ValidateSet("State","Country","Status","Point","Size")]
	[string]$LookupType,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
		$NewLookupItemCmd = $DBConnection.CreateCommand();
		$GetIdCmd = $DBConnection.CreateCommand();
	}
	process {


		switch ($LookupType) {
			"State" {
				$NewLookupItemCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null;
				$GetIdCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null;
				$NewLookupItemCmd.CommandText = "insert into States (Name) values (@LookupTextValue);";
				$GetIdCmd.CommandText = "select StateId from States where Name = @LookupTextValue;"
			}
			"Country" {
				$NewLookupItemCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null;
				$GetIdCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null;
				$NewLookupItemCmd.CommandText = "insert into Countries (Name) values (@LookupTextValue);";
				$GetIdCmd.CommandText = "select CountryId from Countries where Name = @LookupTextValue;"
			}
			"Status" {
				$NewLookupItemCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 12) | Out-Null;
				$GetIdCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 12) | Out-Null;
				$NewLookupItemCmd.CommandText = "insert into statuses (statusname) values (@LookupTextValue);";
				$GetIdCmd.CommandText = "select statusid from statuses where statusname = @LookupTextValue;"
			}
			"Point"{
				$NewLookupItemCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 30) | Out-Null;
				$GetIdCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 30) | Out-Null;
				$NewLookupItemCmd.CommandText = "insert into point_types (typename) values (@LookupTextValue);";
				$GetIdCmd.CommandText = "select typeid from point_types where typeName = @LookupTextValue;"
			}
			"Size" {
				$NewLookupItemCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 16) | Out-Null;
				$GetIdCmd.Parameters.Add("@LookupTextValue", [System.Data.SqlDbType]::NVarChar, 16) | Out-Null;
				$NewLookupItemCmd.CommandText = "insert into cache_sizes (sizename) values (@LookupTextValue);";
				$GetIdCmd.CommandText = "select sizeid from cache_sizes where sizename = @LookupTextValue;"
			}
		}
		$NewLookupItemCmd.Prepare();
		$GetIdCmd.Prepare();
		$NewLookupItemCmd.Parameters["@LookupTextValue"].Value = $LookupName;
		$GetIdCmd.Parameters["@LookupTextValue"].Value = $LookupName;
		$NewLookupItemCmd.ExecuteNonQuery() | Out-Null;
		$NewId = $GetIdCmd.ExecuteScalar();
		$NewLookupItemCmd.Dispose();
		$GetIdCmd.Dispose();
		$NewId;
	}
	end {
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Update-Waypoint {
<#
.SYNOPSIS
	Creates or updates a non-geocache waypoint
.DESCRIPTION
	Creates or updates a non-geocache waypoint. Locates the parent cache & associates the child with it.
.PARAMETER Waypoint
	Custom PSObject containing the data representing a single non-geocache waypoint
.EXAMPLE
	Update-Waypoint -Waypoint $WptData
.EXAMPLE
	$AllWaypoints | Update-Waypoint
#>
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Waypoint,
    [Parameter(Mandatory=$true)]
    [DateTimeOffset]$LastUpdated,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
        switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			    $DBConnection.ConnectionString = $DBConnectionString;
			    $DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
        }
		$WptLastUpdatedCmd = $DBConnection.CreateCommand();
		$WptLastUpdatedCmd.CommandText = "select LastUpdated from waypoints where waypointid = @wptid and parentcache = @cacheid;";
		$WptLastUpdatedCmd.Parameters.Add("@wptid", [System.Data.SqlDbType]::VarChar,10) | Out-Null;
		$WptLastUpdatedCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar,8) | Out-Null;
		$WptUpsertCmd = $DBConnection.CreateCommand();
		$WptLastUpdatedCmd.Prepare();
		$WptUpsertCmd.Parameters.Add("@wptid", [System.Data.SqlDbType]::VarChar,10) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar,8) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@lat",[System.Data.SqlDbType]::Float) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@long",[System.Data.SqlDbType]::Float) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@name",[System.Data.SqlDbType]::VarChar,50) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@desc",[System.Data.SqlDbType]::VarChar, 2000) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@url",[System.Data.SqlDbType]::VarChar,2038) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@urldesc",[System.Data.SqlDbType]::nVarChar, 200) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@pointtype", [System.Data.SqlDbType]::int) | Out-Null;
		$WptUpsertCmd.Parameters.Add("@LastUpdated", [System.Data.SqlDbType]::DateTimeOffset) | Out-Null;
	}
	process {
		$Id = $Waypoint | Select-Object -ExpandProperty Id;

	# Get parent cache id. Same as waypoint ID but first 2 chars are GC
		$ParentCache = "GC" + $Id.Substring(2,$Id.Length - 2);
		$ParentCache = Find-ParentCacheId -CacheId $ParentCache -DBConnection $DBConnection;

		$WptLastUpdatedCmd.Parameters["@wptid"].Value = $Id;
		$WptLastUpdatedCmd.Parameters["@cacheid"].Value = $ParentCache;
		$WaypointExists = $WptLastUpdatedCmd.ExecuteScalar();
		if (($WaypointExists -ne $null) -and ($WaypointExists -ge $LastUpdated)) {
			return;
		}

		$Latitude = [float]($Waypoint | Select-Object -ExpandProperty Lat);
		$Longitude = [float]($Waypoint | Select-Object -ExpandProperty Long);
		$WptDate = get-date ($Waypoint | Select-Object -ExpandProperty DateTime);
		$Name = $Waypoint | Select-Object -ExpandProperty Name;
		$Description = $Waypoint | Select-Object -ExpandProperty Description;
		$Url = $Waypoint | Select-Object -ExpandProperty Url;
		$UrlDesc = $Waypoint | Select-Object -ExpandProperty UrlDesc;
		$Symbol = $Waypoint | Select-Object -ExpandProperty Symbol;
		$PointType = $Waypoint | Select-Object -ExpandProperty PointType;
		$PointTypeId = Get-PointTypeId -PointTypeName $PointType -DBConnection $DBConnection;

# Check for point type. If it doesn't exist, create it
		if ($WaypointExists) {
			$WptUpsertCmd.CommandText = @"
update waypoints set
	latitude = @lat,
	longitude = @long,
	name = @name,
	description = @desc,
	url = @url,
	urldesc = @urldesc,
	typeid = @pointtype,
	LastUpdated = @LastUpdated
where
	waypointid = @wptid
	and parentcache = @cacheid;
"@;
		} else {

		
			$WptUpsertCmd.CommandText = @"
insert into waypoints (waypointid,parentcache,latitude,longitude,name,description,url,urldesc,typeid,LastUpdated,Created) values (
@wptid, @cacheid,@lat,@long,@name,@desc,@url,@urldesc,@pointtype,@LastUpdated,@Created);
"@;
$WptUpsertCmd.Parameters.Add("@Created", [System.Data.SqlDbType]::DateTimeOffset) | Out-Null;
$WptUpsertCmd.Parameters["@Created"].Value = $LastUpdated;
		}
		$WptUpsertCmd.Parameters["@wptid"].Value = $Id;
		$WptUpsertCmd.Parameters["@cacheid"].Value = $ParentCache;
		$WptUpsertCmd.Parameters["@lat"].Value = $Latitude;
		$WptUpsertCmd.Parameters["@long"].Value = $Longitude;
		$WptUpsertCmd.Parameters["@name"].Value = $Name;
		$WptUpsertCmd.Parameters["@desc"].Value = $Description;
		$WptUpsertCmd.Parameters["@url"].Value = $Url;
		$WptUpsertCmd.Parameters["@urldesc"].Value = $UrlDesc;
		$WptUpsertCmd.Parameters["@pointtype"].Value = $PointTypeId;
		$WptUpsertCmd.Parameters["@LastUpdated"].Value = $LastUpdated;
		$WptUpsertCmd.ExecuteNonQuery() | Out-Null;
		$WaypointsProcessed++;
	}
	end {
		$WptLastUpdatedCmd.Dispose();
		$WptUpsertCmd.Dispose();
        switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Find-ParentCacheId {
<#
.SYNOPSIS
	Finds the GC ID of a waypoint's parent cache
.DESCRIPTION
	Finds the GC ID of a waypoint's parent cache. This is currently tightly coupled to the calling function, Update-Waypoint because it assumes that a GC ID is being passed in. Assumes that the waypoint ID is XXYYYZZ where XX is any two characters, YYY is the GC ID of the parent cache less the preceding "GC", and ZZ is an optional suffix. This function recursively trims off any suffix until it locates the parent cache ID.
.PARAMETER CacheId
	ID of the parent cache to search for
.EXAMPLE
	Find-ParentCacheId -CacheId GC123401
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$CacheId,
    [Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
           	$DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
           	$DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	$CacheFindCmd = $DBConnection.CreateCommand();
	$CacheFindCmd.CommandText = "select count(1) from caches where cacheid like @cacheid";
	$CacheFindCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 20) | Out-Null;
	$CacheFindCmd.Prepare();
	#$CacheId = "GC" + $WptId.Substring(2,$WptId.Length - 2);
	$CacheFindCmd.Parameters["@cacheid"].Value = $CacheId + "%";
	$FoundCache = $CacheFindCmd.ExecuteScalar();
	$CacheFindCmd.Dispose();
	if ($FoundCache) {
		$CacheId;
	} else {
		Find-ParentCacheId -CacheId $CacheId.Substring(0,$CacheId.Length - 1) -DBConnection $DBConnection;
	}
	switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
}
function New-Attribute {
<#
.SYNOPSIS
	Creates a new cache attribute
.DESCRIPTION
	Creates a new cache attribute with the properties contained in the passed-in object.
.PARAMETER Attribute
	A custom PSObject containing the properties of the attribute to create. This includes (minimally) the Groundspeak attribute ID, and the associated text. If the attribute already exists (when searched by ID), the text will be updated.
.EXAMPLE
	New-Attribute -Attribute $CacheAttribute;
.EXAMPLE
	$AllCacheAttributes | New-Attribute;;
#>
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Attribute,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
		$CacheAttributeCheckCmd = $DBConnection.CreateCommand();
		$CacheAttributeCheckCmd.CommandText = "select count(1) as attrexists from attributes where attributeid = @attrid";
		$CacheAttributeCheckCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$CacheAttributeCheckCmd.Prepare();

		$CacheAttributeInsertCmd = $DBConnection.CreateCommand();
		$CacheAttributeInsertCmd.CommandText = "insert into attributes (attributeid,attributename) values (@attrid, @attrname)";
		$CacheAttributeInsertCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$CacheAttributeInsertCmd.Parameters.Add("@attrname", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$CacheAttributeInsertCmd.Prepare();
	}
	process {
		$AttrId = [int]($Attribute | Select-Object -ExpandProperty AttrId);
		$AttrName = $Attribute | Select-Object -ExpandProperty AttrName;
		$CacheAttributeCheckCmd.Parameters["@attrid"].Value = $AttrId;
		$AttrExists = $CacheAttributeCheckCmd.ExecuteScalar();
		if (!$AttrExists) {
			$CacheAttributeInsertCmd.Parameters["@attrid"].Value = $AttrId;
			$CacheAttributeInsertCmd.Parameters["@attrname"].Value = $AttrName;
			$CacheAttributeInsertCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
			$CacheAttributeCheckCmd.Dispose();
		$CacheAttributeInsertCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Remove-Attribute {
<#
.SYNOPSIS
	Disassociates all attributes from a geocache.
.DESCRIPTION
	Disassociates all attributes from a geocache. Does not delete the attributes themselves
.PARAMETER CacheId
	GC ID of the cache to drop attributes from.
.EXAMPLE
	Remove-Attribute -CacheId GC1234
#>
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true)]
	[string]$CacheId,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
		$DropCacheAttributesCmd = $DBConnection.CreateCommand();
		$DropCacheAttributesCmd.CommandText = "delete from cache_attributes where cacheid = @cacheid;";
		$DropCacheAttributesCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$DropCacheAttributesCmd.Prepare();
	}
	process {
		$DropCacheAttributesCmd.Parameters["@cacheid"].Value = $CacheId;
		$DropCacheAttributesCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$DropCacheAttributesCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Register-AttributeToCache {
<#
.SYNOPSIS
	Connects an attribute to a geocache
.DESCRIPTION
	Associates an attribute with a geocache including an indicator that the attribute is included or excluded.
.PARAMETER Attribute
	A custom PSObject containing the properties of the attribute to create.
.EXAMPLE
	Register-AttributeToCache -Attribute $CacheAttr
.EXAMPLE
	$AllCacheAttributes | Register-AttributeToCache
#>
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Attribute,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
		$RegisterAttributeToCacheCmd = $DBConnection.CreateCommand();
		$RegisterAttributeToCacheCmd.CommandText = "insert into cache_attributes (cacheid,attributeid,attribute_applies) values (@cacheid,@attrid,@attrapplies);";
		$RegisterAttributeToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$RegisterAttributeToCacheCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$RegisterAttributeToCacheCmd.Parameters.Add("@attrapplies", [System.Data.SqlDbType]::Bit) | Out-Null;
		$RegisterAttributeToCacheCmd.Prepare();
	}
	process {
		$RegisterAttributeToCacheCmd.Parameters["@cacheid"].Value = $Attribute | Select-Object -ExpandProperty ParentCache;
		$RegisterAttributeToCacheCmd.Parameters["@attrid"].Value = $Attribute | Select-Object -ExpandProperty AttrId;
		$RegisterAttributeToCacheCmd.Parameters["@attrapplies"].Value = [int]($Attribute | Select-Object -ExpandProperty AttrInc);
		$RegisterAttributeToCacheCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$RegisterAttributeToCacheCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Get-DBTypeFromTrueFalse{
<#
.SYNOPSIS
	Translates XML true and false
.DESCRIPTION
	Translates XML true and false into integers suitable for SQL Server bit fields. Case-insensitive
.PARAMETER XmlValue
	Value from XML to translate
.EXAMPLE
	PS> Get-DBTypeFromTrueFalse -XmlValue true
	1
.EXAMPLE
	PS> Get-DBTypeFromTrueFalse -XmlValue FALSE
	0
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$XmlValue
)
	switch ($XmlValue.ToLower()) {
		"true" { 1; }
		"false" { 0; }
		default { 0;}
	}
}
function Update-Cacher {
<#
.SYNOPSIS
	Updates cacher name
.DESCRIPTION
	Updates the name associated with a geocacher's account. Each account has a unique numerical ID which is used to track activity, and an arbitrary (but unique) text name. The name may be changed at any time without changing the ID.
.PARAMETER CacherName
	Displayed name for the cacher. This can change for any given account, but is unique across the site.
.PARAMETER CacherId
	Unique numerical ID for the cacher. This is unique to each cacher and cannot change without creating a new account.
.PARAMETER Cacher
	Object of some sort containing both the cacher's name and ID. Probably a cache owner XML node
.EXAMPLE
	PS> Update-Cacher -CacherName "SteveDave" -CacherId 8675309
.EXAMPLE
	PS> Update-Cacher -Cacher SOMETHING
#>
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true)]
	[string]$CacherName,
	[Parameter(Mandatory=$true)]
	[int]$CacherId,
#	[Parameter(Mandatory=$true,ParameterSetName="CacherObject")]
#	[object]$Cacher,
    [Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
# TODO: Make Pipeline-aware
# TODO: Pass in database connection or connection string (like Update-Geocache)
	begin {
        switch ($PsCmdlet.ParameterSetName) {
		    "DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
		    	$DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
		    }
		    "DBConnectionString" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			    $DBConnection.ConnectionString = $DBConnectionString;
			    $DBConnection.Open();
		    }
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
    	}
		$CacherExistsCmd = $DBConnection.CreateCommand();
		$CacherExistsCmd.CommandText = "select count(1) from cachers where cacherid = @CacherId;"
		$CacherExistsCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacherExistsCmd.Prepare();
		$CacherTableUpdateCmd = $DBConnection.CreateCommand();
		$CacherTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacherTableUpdateCmd.Parameters.Add("@CacherName", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
	}
	process{
		switch ($PsCmdlet.ParameterSetName) {
			"CacherObject" {$CacherName = $Cacher.innertext;$CacherId= $Cacher.id;}
		}

		$CacherExistsCmd.Parameters["@CacherId"].Value = $CacherId;
		$CacherExists = $CacherExistsCmd.ExecuteScalar();
		if ($CacherExists){
		# Update cacher name if it's changed
			$CacherTableUpdateCmd.CommandText = "update cachers set cachername = @CacherName where cacherid = @CacherId and cachername <> @CacherName;";
		} else {
			$CacherTableUpdateCmd.CommandText = "insert into cachers (cacherid, cachername) values (@CacherId, @CacherName);";
		}
		$CacherTableUpdateCmd.Parameters["@CacherId"].Value = $CacherId;
		$CacherTableUpdateCmd.Parameters["@CacherName"].Value = $CacherName;
		$CacherTableUpdateCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$CacherExistsCmd.Dispose();
		$CacherTableUpdateCmd.Dispose();
        if ($PsCmdlet.ParameterSetName -ne "DBConnection") {
            $DBConnection.Close();
        }
	}
}
function Update-CacheOwner {
<#
.SYNOPSIS
	Updates the registered owner and displayed "placed by" name of a cache
.DESCRIPTION
	Updates the registered owner and displayed "placed by" name of a cache. The "placed by" name is not unique and may be set to any arbitrary value by the cache owner. It is only used in displaying the cache listing, but some owners may use it to leave hints or slightly obscure their name.
.PARAMETER GCNum
	ID of the cache to be updated
.PARAMETER OwnerId
	Account ID of the cache owner. This can only be changed by putting the cache through the official adoption process on geocaching.com
.PARAMETER PlacedByName
	Name to display as the placer of the cache.
.EXAMPLE
	PS> Update-CacheOwner -GCNum GC001 -OwnerId 8675309 -PlacedByName TommyTutone
#>
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true)]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
	[int]$OwnerId,
	[Parameter(Mandatory=$true)]
	[string]$PlacedByName,
    [Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
        switch ($PsCmdlet.ParameterSetName) {
		    "DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
		    	$DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
		    }
		    "DBConnectionString" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			    $DBConnection.ConnectionString = $DBConnectionString;
			    $DBConnection.Open();
		    }
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
    	}
		$CacheHasOwnerCmd = $DBConnection.CreateCommand();
		$CacheHasOwnerCmd.CommandText = "select count(1) as CacheOnOwners from cache_owners where cacheid = @gcnum;";
		$CacheHasOwnerCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$CacheHasOwnerCmd.Prepare();

		$CacheOwnerUpdateCmd = $DBConnection.CreateCommand();
		$CacheOwnerUpdateCmd.Parameters.Add("@ownerid", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheOwnerUpdateCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
	}
	process {
		Update-Cacher -Cachername $PlacedByName -CacherId $OwnerId -DBConnection $DBConnection;
		# Check to see if cache is already on the owner table. If owner has changed, update with new value. If cache isn't on the table, add it
		$CacheHasOwnerCmd.Parameters["@gcnum"].Value = $GCNum;
		$CacheHasOwner = $CacheHasOwnerCmd.ExecuteScalar();

		if ($CacheHasOwner) {
			$CacheOwnerUpdateCmd.CommandText = "update cache_owners set cacherid = @ownerid where cacheid = @GCNum and cacherid <> @ownerid;"
		} else {
			$CacheOwnerUpdateCmd.CommandText = "insert into cache_owners (cacherid, cacheid) values (@OwnerId, @GCNum);"
		}
		$CacheOwnerUpdateCmd.Parameters["@ownerid"].Value = $ownerid;
		$CacheOwnerUpdateCmd.Parameters["@gcnum"].Value = $gcnum;
		$CacheOwnerUpdateCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$CacheOwnerUpdateCmd.Dispose();
		$CacheOwnerUpdateCmd.Dispose();
        if ($PsCmdlet.ParameterSetName -ne "DBConnection") {
            $DBConnection.Close();
        }
	}
}
function New-TravelBug {
<#
.SYNOPSIS
	Creates a new travel bug record
.DESCRIPTION
	Creates a new travel bug record to be attached to geocaches through their travels
.PARAMETER TBId
	Internal ID of the travel bug
.PARAMETER TBPublicId
	Public ID of the travel bug. This is used on geocaching.com to refer to the travel bug
.PARAMETER TBName
	Name given to the travel bug by the owner.
.EXAMPLE
	PS> New-TravelBug -TBId 8675309 -TBPublicId TB001 -TBName "My First Travel Bug"
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[int]$TBId,
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$TBPublicId,
#	[ValidationScript({$_.Length -le 50})]
	[string]$TBName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
		$TBCheckCmd = $DBConnection.CreateCommand();
		$TBCheckCmd.CommandText = "select count(1) as tbexists from travelbugs where tbinternalid = @tbid";
		$TBCheckCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int) | Out-Null;
		$TBCheckCmd.Prepare();

		$TBInsertCmd = $DBConnection.CreateCommand();
		$TBInsertCmd.CommandText = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (@tbid, @tbpublicid, @tbname)";
		$TBInsertCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int) | Out-Null;
		$TBInsertCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$TBInsertCmd.Parameters.Add("@tbname", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$TBInsertCmd.Prepare();
	}
	process {
		$TBCheckCmd.Parameters["@tbid"].Value = $TBId;
		$TBExists = $TBCheckCmd.ExecuteScalar();
		if (!$TBExists) {
			$TBInsertCmd.Parameters["@tbid"].Value = $TBId;
			$TBInsertCmd.Parameters["@tbname"].Value = $TBName;
			$TBInsertCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
			$TBInsertCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
		$TBCheckCmd.Dispose();
		$TBInsertCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Move-TravelBugToCache {
<#
.SYNOPSIS
	Logs a travel bug into a cache
.DESCRIPTION
	Logs a travel bug into a cache. If the bug is already in another cache, it's removed from the previous cache
.PARAMETER GCNum
	ID of the new cache the travel bug appears in
.PARAMETER TBPublicId
	Public ID of the bug to be placed in the cache
.EXAMPLE
	PS> Move-TravelBugToCache -GCNum GC001 -TBId TB001
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$TBPublicId,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
		$RegisterTBToCacheCmd = $DBConnection.CreateCommand();

		$RegisterTBToCacheCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$RegisterTBToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;

		$TBInOtherCacheCmd = $DBConnection.CreateCommand();
		$TBInOtherCacheCmd.CommandText = "select count(1) from tbinventory where tbpublicid = @tbpublicid;";
		$TBInOtherCacheCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$TBInOtherCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$TBInOtherCacheCmd.Prepare();
	}
	process {
		$TBInOtherCacheCmd.Parameters["@cacheid"].Value = $GCNum;
		$TBInOtherCacheCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
		$TBWasInOtherCache = $TBInOtherCacheCmd.ExecuteScalar();
		if (!$TBWasInOtherCache) {
			$RegisterTBToCacheCmd.CommandText = "insert into tbinventory (cacheid, tbpublicid) values (@cacheid,@tbpublicid)";
		} else {
			$RegisterTBToCacheCmd.CommandText = "update tbinventory set cacheid = @cacheid where tbpublicid = @tbpublicid";
		}
		$RegisterTBToCacheCmd.Parameters["@cacheid"].Value = $GCNum;
		$RegisterTBToCacheCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
		$RegisterTBToCacheCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$TBInOtherCacheCmd.Dispose();
		$RegisterTBToCacheCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
# TODO: Make this pipeline-aware & pass in single TBs.
function Update-TravelBug {
<#
.SYNOPSIS
	Wrapper function to create or update a travel bug & log it into a cache
.DESCRIPTION
	Wrapper function to createor update a travel bug & log it into a cache.
.PARAMETER GCNum
	ID of the new cache the travel bug appears in
.PARAMETER TBId
	Internal ID of the travel bug
.PARAMETER TBPublicId
	Public ID of the travel bug. This is used on geocaching.com to refer to the travel bug
.PARAMETER TBName
	Name given to the travel bug by the owner.

.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
	[string]$TBPublicId,
	[Parameter(Mandatory=$true)]
	[int]$TBInternalId,
	[Parameter(Mandatory=$true)]
	[string]$TBName,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
		switch ($PsCmdlet.ParameterSetName) {
			"DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
			}
			"DBConnectionString" {
				$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
				$DBConnection.ConnectionString = $DBConnectionString;
				$DBConnection.Open();
			}
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
		}
	}
	process{
		New-TravelBug -TBId $TBInternalId -TBPublicId $TBPublicId -TBName $TBName -DBConnection $DBConnection;
		Move-TravelBugToCache -GCNum $GCNum -TBPublicId $TBPublicId -DBConnection $DBConnection;
	}
	end {
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
function Update-Geocache {
<#
.SYNOPSIS
	Enters a new geocache into the database or updates an existing one
.DESCRIPTION
	Enters a new geocache into the database or updates an existing one.
.PARAMETER CacheWaypoint
	A geocache XML node from a Groundspeak GPX file
.EXAMPLE
#>
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[System.Xml.XmlElement[]]$CacheWaypoint,
	[Parameter(Mandatory=$true)]
	[DateTimeOffset]$LastUpdated,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	begin {
	    switch ($PsCmdlet.ParameterSetName) {
		    "DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
		    }
		    "DBConnectionString" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			    $DBConnection.ConnectionString = $DBConnectionString;
			    $DBConnection.Open();
		    }
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
	    }
		$CacheLoadCmd = $DBConnection.CreateCommand();
		$CacheLastUpdatedCmd = $DBConnection.CreateCommand();
		$CacheLastUpdatedCmd.CommandText = "select LastUpdated from caches where cacheid = @CacheId;";
		$CacheLastUpdatedCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::VarChar,8) | Out-Null;
		$CacheLastUpdatedCmd.Prepare();

		$CacheLoadCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@gsid", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheName", [System.Data.SqlDbType]::nVarChar, 50) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Placed", [System.Data.SqlDbType]::datetimeoffset) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@PlacedBy", [System.Data.SqlDbType]::nVarChar) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@TypeId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@SizeId", [System.Data.SqlDbType]::int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Diff", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Terrain", [System.Data.SqlDbType]::float) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@ShortDesc", [System.Data.SqlDbType]::VarChar, 2048) | Out-Null;
		#See http://support.microsoft.com/kb/970519 for bug workaround
		#$CacheLoadCmd.Parameters["@ShortDesc"].Size = -1;
		$CacheLoadCmd.Parameters.Add("@LongDesc", [System.Data.SqlDbType]::ntext) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Hint", [System.Data.SqlDbType]::nVarChar, 1024) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Avail", [System.Data.SqlDbType]::bit) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@Archived", [System.Data.SqlDbType]::bit) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@PremOnly", [System.Data.SqlDbType]::bit) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheStatus",[System.Data.SqlDbType]::Int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheUpdated", [System.Data.SqlDbType]::DateTimeOffset) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@CountryId", [System.Data.SqlDbType]::Int) | Out-Null;
		$CacheLoadCmd.Parameters.Add("@StateId", [System.Data.SqlDbType]::Int) | Out-Null;
		#$CacheLoadCmd.Prepare();
	}
	process {
	# TODO: Can't navigate XML element structure anymore, need to use ugliness like $CacheWaypoint | Select-Object -ExpandProperty cache | Select-Object -ExpandProperty name
		$GCNum = $CacheWaypoint | Select-Object -ExpandProperty name;

		$CacheLastUpdatedCmd.Parameters["@CacheId"].Value = $GCNum;
		$CacheLastUpdated = $CacheLastUpdatedCmd.ExecuteScalar();
# If the cache already exists and was updated more recently than the GPX was generated, do nothing
# $script:GPXDate is empty. Need to pass in a different way
		if ($CacheLastUpdated -and ($CacheLastUpdated -ge $LastUpdated)) {
			return;
		}

		$PlacedDate = get-date ($CacheWaypoint | Select-Object -ExpandProperty time);
		$Latitude = $CacheWaypoint | Select-Object -ExpandProperty lat;
		$Longitude = $CacheWaypoint | Select-Object -ExpandProperty lon;
		$CacheWaypoint = $CacheWaypoint | Select-Object -ExpandProperty cache;

		# Load/Update cache table
		if (!$CacheLastUpdated){
			$CacheLoadCmd.CommandText = @"
		INSERT INTO [dbo].[caches]
				 ([cacheid]
				 ,[gsid]
				 ,[cachename]
				 ,[latitude]
				 ,[longitude]
				 ,[lastupdated]
				 ,[placed]
				 ,[placedby]
				 ,[typeid]
				 ,[sizeid]
				 ,[difficulty]
				 ,[terrain]
				 ,[shortdesc]
				 ,[longdesc]
				 ,[hint]
				 ,[available]
				 ,[archived]
				 ,[premiumonly]
				 ,[cachestatus]
				 ,[created]
				 ,[StateId]
				 ,[CountryId]
,[NeedsExternalUpdate],[Elevation])
			 VALUES
				 (@CacheId
				 ,@GSID
				 ,@CacheName
				 ,@Lat
				 ,@Long
				 ,@CacheUpdated
				 ,@Placed
				 ,@PlacedBy
				 ,@TypeId
				 ,@SizeId
				 ,@Diff
				 ,@Terrain
				 ,@ShortDesc
				 ,@LongDesc
				 ,@Hint
				 ,@Avail
				 ,@Archived
				 ,@PremOnly
				 ,@CacheStatus
				 ,SYSDATETIMEOFFSET()
				 ,@StateId
				 ,@CountryId
,1,0
				 );
"@;
		} else {
			$CacheLoadCmd.CommandText = @"
		UPDATE [dbo].[caches]
		 SET [gsid] = @gsid
			 ,[cachename] = @CacheName
			 ,[latitude] = @Lat
			 ,[longitude] = @Long
			 ,[lastupdated] = @CacheUpdated
			 ,[placed] = @Placed
			 ,[placedby] = @PlacedBy
			 ,[typeid] = @TypeId
			 ,[sizeid] = @SizeId
			 ,[difficulty] = @Diff
			 ,[terrain] = @Terrain
			 ,[shortdesc] = @ShortDesc
			 ,[longdesc] = @LongDesc
			 ,[hint] = @Hint
			 ,[available] = @Avail
			 ,[archived] = @Archived
			 ,[premiumonly] = @PremOnly
			 ,[cachestatus] = @CacheStatus
			 ,[StateId] = @StateId
			 ,[CountryId] = @CountryId
		 WHERE CacheId = @CacheId;
"@;
		}
		$CacheLoadCmd.Parameters["@CacheId"].Value = $GCNum;
		$CacheLoadCmd.Parameters["@gsid"].Value = $CacheWaypoint | Select-Object -ExpandProperty id;
		$CacheLoadCmd.Parameters["@CacheName"].Value = $CacheWaypoint | Select-Object -ExpandProperty name;
		$CacheLoadCmd.Parameters["@Lat"].Value = $Latitude;
		$CacheLoadCmd.Parameters["@Long"].Value = $Longitude;
		$CacheLoadCmd.Parameters["@Placed"].Value = $PlacedDate;
		$CacheLoadCmd.Parameters["@PlacedBy"].Value = $CacheWaypoint | Select-Object -ExpandProperty placed_by;

		$CacheLoadCmd.Parameters["@TypeId"].Value = Get-PointTypeId -PointTypeName $($CacheWaypoint | Select-Object -ExpandProperty type) -DBConnection $DBConnection;

		$CacheLoadCmd.Parameters["@SizeId"].Value = Get-CacheSizeId -SizeName $($CacheWaypoint | Select-Object -ExpandProperty container) -DBConnection $DBConnection;

        if ([string]::IsNullOrEmpty($CacheWaypoint.state)) {
            $StateName = "Not Set";
        } else {
            $StateName = $CacheWaypoint.state;
        }
        if ([string]::IsNullOrEmpty($CacheWaypoint.country)) {
            $CountryName = "Not Set";
        } else {
            $CountryName = $CacheWaypoint.country;
        }
		
		$StateId = Get-StateId -StateName $StateName -DBConnection $DBConnection;
		$CountryId = Get-CountryId -CountryName $CountryName -DBConnection $DBConnection;

		$CacheLoadCmd.Parameters["@StateId"].Value = $StateId;
		$CacheLoadCmd.Parameters["@CountryId"].Value = $CountryId;

		$CacheLoadCmd.Parameters["@Diff"].Value = $CacheWaypoint | Select-Object -ExpandProperty difficulty;
		$CacheLoadCmd.Parameters["@Terrain"].Value = $CacheWaypoint | Select-Object -ExpandProperty terrain;
		$CacheLoadCmd.Parameters["@ShortDesc"].Value = $CacheWaypoint | Select-Object -ExpandProperty short_description | Select-Object -ExpandProperty innertext;
		$CacheLoadCmd.Parameters["@LongDesc"].Value = $CacheWaypoint | Select-Object -ExpandProperty long_description | Select-Object -ExpandProperty innertext;
		$CacheLoadCmd.Parameters["@Hint"].Value = $CacheWaypoint | Select-Object -ExpandProperty encoded_hints;
		$CacheLoadCmd.Parameters["@Avail"].Value = Get-DBTypeFromTrueFalse ($CacheWaypoint | Select-Object -ExpandProperty available);
		$CacheLoadCmd.Parameters["@Archived"].Value = Get-DBTypeFromTrueFalse ($CacheWaypoint | Select-Object -ExpandProperty archived);

		$CacheLoadCmd.Parameters["@CacheUpdated"].Value = $LastUpdated;

		if (($CacheWaypoint | Select-Object -ExpandProperty archived) -eq "true") {
			$StatusName = "Archived";
		} else {
			if (($CacheWaypoint | Select-Object -ExpandProperty available) -eq "true") {
				$StatusName = "Available";
			} else {
				$StatusName = "Disabled";
			}
		}
		$CacheLoadCmd.Parameters["@CacheStatus"].Value = Get-CacheStatusId -StatusName $StatusName -DBConnection $DBConnection;
		# TODO: Figure out where premium only comes from. Doesn't appear to be in the GPX
		$CacheLoadCmd.Parameters["@PremOnly"].Value = 0; #Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.
		# Execute
		$CacheLoadCmd.ExecuteNonQuery() | Out-Null;

		Update-CacheOwner -DBConnection $DBConnection -GCNum $GCNum -OwnerId $($CacheWaypoint | Select-Object -ExpandProperty owner | Select-Object -ExpandProperty id) -PlacedByName $($CacheWaypoint | Select-Object -ExpandProperty placed_by);
	}
	end {
		$CacheLoadCmd.Dispose();
		$CacheLastUpdatedCmd.Dispose();
		switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}
#TODO: This probably doesn't work for the CacheLog parameter (all data in one)
#TODO: This needs a connection parameter (set of parameters) passed in!
function Update-Log {
<#
.SYNOPSIS
	Creates or updates a geocache log
.DESCRIPTION
	Creates or updates a geocache log, and links it to its parent cache.
.PARAMETER LogId
	Groundspeak unique ID for the log
.PARAMETER CacheId
	GC code for the cache the log is attached to
.PARAMETER LogDate
	Date of the log entry
.PARAMETER LogTypeName
	Log entry type - found, didn't find, etc.
.PARAMETER Finder
	Groundspeak internal ID of the finder of the
.PARAMETER LogText
	Full text of the log entry
.PARAMETER Latitude
	Latitude of the waypoint attached to the log by the finder, if any
.PARAMETER Longitude
	Longitude of the waypoint attached to the log by the finder, if any
.PARAMETER CacheLog
	XMLElement from the GPX file which contains the full log details
.EXAMPLE
	Update-Log -LogId 12345 -CacheId GCABCD -LogDate "2013-09-01" -LogTypeName "Found It" -Finder "Bob" -LogText "I found the cache!" -Latitude 40.12345 -Longitude -80.87321
.EXAMPLE
	$CacheData.SelectNodes("//log") | foreach-Object {Update-Log -CacheLog $_}
#>
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[int]$LogId,
	[Parameter(Mandatory=$true)]
	[string]$CacheId,
	[Parameter(Mandatory=$true)]
	[DateTimeOffset]$LogDate,
	[Parameter(Mandatory=$true)]
	[string]$LogTypeName,
	[Parameter(Mandatory=$true)]
	[int]$Finder,
	[Parameter(Mandatory=$false)]
	[string]$LogText="",
	[Parameter(Mandatory=$false)]
	[float]$Latitude,
	[Parameter(Mandatory=$false)]
	[float]$Longitude,
#	[Parameter(Mandatory=$true,ParameterSetName="LogObject")]
#	[System.Xml.XmlElement]$CacheLog,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
begin {
    switch ($PsCmdlet.ParameterSetName) {
		    "DBConnectionDetails" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
                $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
                $DBCSBuilder['Data Source'] = $SQLInstance;
			    $DBCSBuilder['Initial Catalog'] = $DBName;
                $DBCSBuilder['Application Name'] = "Cache Loader";
                $DBCSBuilder['Integrated Security'] = "true";
                $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			    $DBConnection.Open();
		    }
		    "DBConnectionString" {
			    $DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			    $DBConnection.ConnectionString = $DBConnectionString;
			    $DBConnection.Open();
		    }
			"DBConnection" {
				$DBName = $DBConnection.Database;
				$SQLInstance = $DBConnection.DataSource;
				$DBConnectionString = $DBConnection.ConnectionString;
			}
	    }
		$LogExistsCmd = $DBConnection.CreateCommand();
		$LogExistsCmd.CommandText = "select count(1) from logs where logid = @LogId;"
		$LogExistsCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogExistsCmd.Prepare();
		$LogTableUpdateCmd = $DBConnection.CreateCommand();
		$LogTableUpdateCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::VarChar, 50) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogDate", [System.Data.SqlDbType]::DateTimeOffset) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogType", [System.Data.SqlDbType]::Int) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogText", [System.Data.SqlDbType]::NVarChar, 4000) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::Float) | Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::Float) | Out-Null;
		$LogTypes = Get-DataFromQuery -DBConnection $DBConnection -Query "select logtypeid,logtypedesc from log_types";
		$LogLinkToCacheCmd = $DBConnection.CreateCommand();
		$LogLinkToCacheCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogLinkToCacheCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$LogLinkToCacheCmd.CommandText = "insert into cache_logs (cacheid,logid) values (@CacheId, @LogId)";
		$LogLinkToCacheCmd.Prepare();
		$LogLinkedCmd = $DBConnection.CreateCommand();
		$LogLinkedCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt) | Out-Null;
		$LogLinkedCmd.CommandText = "select count(1) from cache_logs where logid = @LogId";
		$LogLinkedCmd.Prepare();
	}
	process{
        $LogType = $LogTypes | Where-Object{$_.logtypedesc -eq $LogTypeName} | Select-Object -ExpandProperty logtypeid;
		$LogExistsCmd.Parameters["@LogId"].Value = $LogId;
		$LogExists = $LogExistsCmd.ExecuteScalar();
		if ($LogExists){
			$LogTableUpdateCmd.CommandText = "update logs set logdate=@LogDate, logtypeid=@LogType, cacherid = @CacherId, logtext = @LogText, latitude = @Lat, longitude = @Long where logid = @LogId;";
		} else {
			$LogTableUpdateCmd.CommandText = "insert into logs (logid,logdate, logtypeid, cacherid,logtext,latitude,longitude) values (@LogId,@LogDate,@LogType, @CacherId,@LogText,@Lat,@Long);";
		}
		$LogTableUpdateCmd.Parameters["@CacherId"].Value = $Finder;
		$LogTableUpdateCmd.Parameters["@LogId"].Value = $LogId;
		$LogTableUpdateCmd.Parameters["@LogDate"].Value = $LogDate;
		$LogTableUpdateCmd.Parameters["@LogType"].Value = $LogType;
		$LogTableUpdateCmd.Parameters["@LogText"].Value = $LogText;
		$LogTableUpdateCmd.Parameters["@Lat"].Value = $Latitude;
		$LogTableUpdateCmd.Parameters["@Long"].Value = $Longitude;
		$LogTableUpdateCmd.ExecuteNonQuery() | Out-Null;

		$LogLinkedCmd.Parameters["@LogId"].Value = $LogId;
		$LogLinked = $LogLinkedCmd.ExecuteScalar();
		if (!$LogLinked) {
			$LogLinkToCacheCmd.Parameters["@LogId"].Value = $LogId;
			$LogLinkToCacheCmd.Parameters["@CacheId"].Value = $CacheId;
			$LogLinkToCacheCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
		$LogExistsCmd.Dispose();
		$LogTableUpdateCmd.Dispose();
        switch ($PsCmdlet.ParameterSetName) {
			{$_ -ne "DBConnection"} {
				$DBConnection.Close();
				$DBConnection.Dispose();
			}
		}
	}
}

function Get-DataFromQuery  {
[cmdletBinding()]
param(
	[Parameter(Mandatory=$true)]
	[string]$Query,
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$SQLInstance,
    [Alias("Database")]
	[Parameter(ParameterSetName="DBConnectionDetails")]
	[string]$DBName,
	[Parameter(ParameterSetName="DBConnectionString")]
	[string]$DBConnectionString,
	[Parameter(ParameterSetName="DBConnection")]
	[System.Data.SqlClient.SqlConnection]$DBConnection
)
	switch ($PsCmdlet.ParameterSetName) {
		"DBConnectionDetails" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
            $DBCSBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder;
            $DBCSBuilder['Data Source'] = $SQLInstance;
			$DBCSBuilder['Initial Catalog'] = $DBName;
            $DBCSBuilder['Application Name'] = "Cache Loader";
            $DBCSBuilder['Integrated Security'] = "true";
            $DBConnection.ConnectionString = $DBCSBuilder.ToString();
			$DBConnection.Open();
		}
		"DBConnectionString" {
			$DBConnection = New-Object System.Data.SqlClient.SqlConnection;
			$DBConnection.ConnectionString = $DBConnectionString;
			$DBConnection.Open();
		}
		"DBConnection" {
			$DBName = $DBConnection.Database;
			$SQLInstance = $DBConnection.DataSource;
			$DBConnectionString = $DBConnection.ConnectionString;
		}
	}
	$QueryCmd = $DBConnection.CreateCommand();
	$QueryCmd.CommandText = $Query;
	$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
	$QueryCmd.Connection = $DBConnection;
    $SqlAdapter.SelectCommand = $QueryCmd;
    $DataSet = New-Object System.Data.DataSet;
	$SqlAdapter.Fill($DataSet)

	switch ($PsCmdlet.ParameterSetName) {
		{$_ -ne "DBConnection"} {
			$DBConnection.Close();
			$DBConnection.Dispose();
		}
	}
	$DataSet.Tables[0]
}

Export-ModuleMember Update-Cacher;
Export-ModuleMember Update-CacheOwner;
Export-ModuleMember New-TravelBug;
export-modulemember Move-TravelBugToCache;
Export-ModuleMember Update-TravelBug;
Export-ModuleMember Update-Geocache;
Export-ModuleMember Update-Log;
Export-ModuleMember Set-CorrectedCoordinates;
Export-ModuleMember Get-PointTypeLookups;
Export-ModuleMember Get-CacheSizeLookup;
Export-ModuleMember Get-CacheStatusLookup;
Export-ModuleMember Get-PointTypeId;
Export-ModuleMember Get-CacheSizeId;
Export-ModuleMember Get-CacheStatusId;
Export-ModuleMember Get-StateId;
Export-ModuleMember Get-CountryId;
Export-ModuleMember Update-Waypoint;
Export-ModuleMember Find-ParentCacheId;
Export-ModuleMember New-Attribute;
Export-ModuleMember Remove-Attribute;
Export-ModuleMember Register-AttributeToCache;
Export-ModuleMember Get-DBTypeFromTrueFalse;
Export-ModuleMember Get-DataFromQuery;