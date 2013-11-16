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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
	$StateLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select StateId, rtrim(ltrim(Name)) as Name from states order by StateId Desc;";
	$StateLookup;
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
		$PointTypeId = New-LookupEntry -LookupName $PointTypeName -SQLInstance $SQLInstance -Database $Database -LookupType Point;
		$script:PointTypeLookup = Get-PointTypeLookups -SQLInstance $SQLInstance -Database $Database;
	}
	$PointTypeId;
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
		$CacheSizeId = New-LookupEntry -LookupName $SizeName -SQLInstance $SQLInstance -Database $Database -LookupType Size;
		$script:CacheSizeLookup = Get-CacheSizeLookup -SQLInstance $SQLInstance -Database $Database;
	}
	$CacheSizeId;
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
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	if ($script:CacheStatusLookup -eq $null) {
		$script:CacheStatusLookup = Get-CacheStatusLookup -SQLInstance $SQLInstance -Database $Database;
	}

	$CacheStatusId = $script:CacheStatusLookup | where-object{$_.statusname -eq $StatusName} | Select-Object -ExpandProperty statusid;
	if ($CacheStatusId -eq $null) {
		$CacheStatusId = New-CacheStatus -LookupName $StatusName -SQLInstance $SQLInstance -Database $Database -LookupType Status;
		$script:CacheStatusLookup = Get-CacheStatusLookup -SQLInstance $SQLInstance -Database $Database;
	}
	$CacheStatusId;
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
	[Parameter(Mandatory=$true)]
	[string]$StateName,
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	if ($script:StateLookup -eq $null) {
		$script:StateLookup = Get-StateLookup -SQLInstance $SQLInstance -Database $Database;
	}

	$StateId = $script:StateLookup | where-object{$_.Name -eq $StateName} | Select-Object -ExpandProperty StateId;
	if ($StateId -eq $null) {
		$StateId = New-LookupEntry -LookupName $StateName -SQLInstance $SQLInstance -Database $Database -LookupType State;
		$script:StateLookup = Get-StateLookup -SQLInstance $SQLInstance -Database $Database;
	}
	$StateId;
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
	[Parameter(Mandatory=$true)]
	[string]$CountryName,
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -count 1 -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)

	if ($script:CountryLookup -eq $null) {
		$script:CountryLookup = Get-CountryLookup -SQLInstance $SQLInstance -Database $Database;
	}

	$CountryId = $script:CountryLookup | where-object{$_.Name -eq $CountryName} | Select-Object -ExpandProperty CountryId;
	if ($CountryId -eq $null) {
		$CountryId = New-LookupEntry -LookupName $CountryName -SQLInstance $SQLInstance -Database $Database -LookupName Country;
		$script:CountryLookup = Get-CountryLookup -SQLInstance $SQLInstance -Database $Database;
	}
	$CountryId;
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
	$NewLookupItemCmd = $SQLConnection.CreateCommand();
	$GetIdCmd = $SQLConnection.CreateCommand();

	switch ($Type) {
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
	$NewLookupItemCmd.Parameters["@Name"].Value = $LookupName;
	$GetIdCmd.Parameters["@Name"].Value = $LookupName;
	$NewLookupItemCmd.ExecuteNonQuery() | Out-Null;
	$NewId = $GetIdCmd.ExecuteScalar();
	$NewLookupItemCmd.Dispose();
	$GetIdCmd.Dispose();
	$SQLConnection.Close();
	$SQLConnection.Dispose();
	$NewId;
}

Export-ModuleMember Set-CorrectedCoordinates;
Export-ModuleMember Get-PointTypeLookups;
Export-ModuleMember Get-CacheSizeLookup;
Export-ModuleMember Get-CacheStatusLookup;
Export-ModuleMember Get-PointTypeId;
Export-ModuleMember Get-CacheSizeId;
Export-ModuleMember Get-CacheStatusId;
Export-ModuleMember Get-StateId;
Export-ModuleMember Get-CountryId;