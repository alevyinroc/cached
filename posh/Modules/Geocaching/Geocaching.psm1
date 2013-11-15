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
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
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
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
	$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
	$SQLConnection.ConnectionString = $SQLConnectionString;
	$SQLConnection.Open();
	$NewStateCountryCmd = $SQLConnection.CreateCommand();
	$NewStateCountryCmd.Parameters.Add("@Name", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null;
	$GetIdCmd = $SQLConnection.CreateCommand();
	$GetIdCmd.Parameters.Add("@Name", [System.Data.SqlDbType]::NVarChar, 50) | Out-Null;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	$StateLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select StateId, rtrim(ltrim(Name)) as Name from states order by StateId Desc;";
	$StateLookup;
}

function Get-CountryLookups {
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	$CountryLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select CountryId, rtrim(ltrim(Name)) as Name from Countries order by CountryId Desc;";
	$CountryLookup;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	$PointTypeLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select typeid, typename from point_types;";
	$PointTypeLookup;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	$CacheSizeLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select sizeid, sizename from cache_sizes;";
	$CacheSizeLookup;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	$CacheStatusLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select statusid, statusname from statuses;";
	$CacheStatusLookup;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	
	if ($script:PointTypeLookup -eq $null) {
		$script:PointTypeLookup = Get-PointTypeLookups -SQLInstance $SQLInstance -Database $Database;
	}
	
	$PointTypeId = $script:PointTypeLookup | where-object{$_.typename -eq $PointTypeName} | Select-Object -ExpandProperty typeid;
	if ($PointTypeId -eq $null) {
		$PointType = New-PointType -TypeName $PointTypeName -SQLInstance $SQLInstance -Database $Database;
		$script:PointTypeLookup = Get-PointTypeLookups -SQLInstance $SQLInstance -Database $Database;
	}
	$PointTypeId;
}

function New-PointType {
<#
.SYNOPSIS
	Adds a new point type to the database
.DESCRIPTION
	Adds a new point type to the database and returns its ID.
.PARAMETER TypeName
	Name of the new point type
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param(
	[Parameter(Mandatory=$true)]
	[string]$TypeName,
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
	$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
	$SQLConnection.ConnectionString = $SQLConnectionString;
	$SQLConnection.Open();
	$NewPointTypeCmd = $SQLConnection.CreateCommand();
	$NewPointTypeCmd.Parameters.Add("@TypeName", [System.Data.SqlDbType]::NVarChar, 30) | Out-Null;
	$GetIdCmd = $SQLConnection.CreateCommand();
	$GetIdCmd.Parameters.Add("@TypeName", [System.Data.SqlDbType]::NVarChar, 30) | Out-Null;
	
	$NewPointTypeCmd.CommandText = "insert into point_types (typename) values (@TypeName);";
	$GetIdCmd.CommandText = "select typeid from point_types where typeName = @TypeName;"
	
	$NewPointTypeCmd.Prepare();
	$GetIdCmd.Prepare();
	$NewPointTypeCmd.Parameters["@TypeName"].Value = $TypeName;
	$GetIdCmd.Parameters["@TypeName"].Value = $TypeName;
	$NewPointTypeCmd.ExecuteNonQuery() | Out-Null;
	$NewId = $GetIdCmd.ExecuteScalar();
	$NewPointTypeCmd.Dispose();
	$GetIdCmd.Dispose();
	$SQLConnection.Close();
	$SQLConnection.Dispose();
	$NewId;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	
	if ($script:CacheSizeLookup -eq $null) {
		$script:CacheSizeLookup = Get-CacheSizeLookup -SQLInstance $SQLInstance -Database $Database;
	}
	
	$CacheSizeId = $script:CacheSizeLookup | where-object{$_.sizename -eq $SizeName} | Select-Object -ExpandProperty sizeid;
	if ($CacheSizeId -eq $null) {
		$CacheSize = New-PointType -TypeName $SizeName -SQLInstance $SQLInstance -Database $Database;
		$script:CacheSizeLookup = Get-CacheSizeLookup -SQLInstance $SQLInstance -Database $Database;
	}
	$CacheSizeId;
}

function New-CacheSize {
<#
.SYNOPSIS
	Adds a new cache size to the database
.DESCRIPTION
	Adds a cache size to the database and returns its ID.
.PARAMETER SizeName
	Name of the new cache size
.PARAMETER SQLInstance
	SQL Server instance to hosting the database
.PARAMETER Database
	Database on the SQLInstance hosting the geocache database
.EXAMPLE
#>
[cmdletbinding(SupportsShouldProcess=$False)]
param(
	[Parameter(Mandatory=$true)]
	[string]$SizeName,
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;Application Name=Geocache Loader;";
	$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
	$SQLConnection.ConnectionString = $SQLConnectionString;
	$SQLConnection.Open();
	$NewCacheSizeCmd = $SQLConnection.CreateCommand();
	$NewCacheSizeCmd.Parameters.Add("@SizeName", [System.Data.SqlDbType]::NVarChar, 16) | Out-Null;
	$GetIdCmd = $SQLConnection.CreateCommand();
	$GetIdCmd.Parameters.Add("@SizeName", [System.Data.SqlDbType]::NVarChar, 16) | Out-Null;
	
	$NewCacheSizeCmd.CommandText = "insert into cache_sizes (sizename) values (@SizeName);";
	$GetIdCmd.CommandText = "select typeid from cache_sizes where sizename = @SizeName;"
	
	$NewCacheSizeCmd.Prepare();
	$GetIdCmd.Prepare();
	$NewCacheSizeCmd.Parameters["@SizeName"].Value = $SizeName;
	$GetIdCmd.Parameters["@SizeName"].Value = $SizeName;
	$NewCacheSizeCmd.ExecuteNonQuery() | Out-Null;
	$NewId = $GetIdCmd.ExecuteScalar();
	$NewCacheSizeCmd.Dispose();
	$GetIdCmd.Dispose();
	$SQLConnection.Close();
	$SQLConnection.Dispose();
	$NewId;
}

Export-ModuleMember Set-CorrectedCoordinates;
Export-ModuleMember New-StateCountryId;
Export-ModuleMember Get-StateLookups;
Export-ModuleMember Get-CountryLookups;
Export-ModuleMember Get-PointTypeLookups;
Export-ModuleMember Get-CacheSizeLookup;
Export-ModuleMember Get-CacheStatusLookup;
Export-ModuleMember Get-PointTypeId;
Export-ModuleMember Get-CacheSizeId;