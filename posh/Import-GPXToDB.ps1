<#
Copyright Andy Levy andy@levyclan.us 2013
#>

#requires -version 2.0
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Path -path $_ -Pathtype Leaf})]
	[string]$FileToImport = 'C:\Users\andy\Documents\Code\cachedb\scratchpad\GCF7C6.gpx',
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
$ErrorActionPreference = "Stop";
Clear-Host;
$Error.Clear();
Push-Location;
if ((Get-Module|Where-Object{$_.name -eq "sqlps"}|Measure-Object).count -lt 1){
	Import-Module sqlps;
}
Pop-Location;

#region Globals
$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;";
$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();
#endregion

#region Functions
function Get-DBTypeFromTrueFalse{
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
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacherDetails")]
	[string]$CacherName,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacherDetails")]
	[int]$CacherId,
	[Parameter(Mandatory=$true,ParameterSetName="CacherObject")]
	[object]$Cacher
)
	begin {
		$CacherExistsCmd = $SQLConnection.CreateCommand();
		$CacherExistsCmd.CommandText = "select count(1) from cachers where cacherid = @CacherId;"
		$CacherExistsCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int)|out-null;
		$CacherExistsCmd.Prepare();
		$CacherTableUpdateCmd = $SQLConnection.CreateCommand();
		$CacherTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int)|Out-Null;
		$CacherTableUpdateCmd.Parameters.Add("@CacherName", [System.Data.SqlDbType]::varchar, 50)|Out-Null;
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
	}
}

function Update-CacheOwner {
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[string]$GCNum,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[int]$OwnerId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[string]$PlacedByName
)
	begin {
		$CacheHasOwnerCmd = $SQLConnection.CreateCommand();
		$CacheHasOwnerCmd.CommandText = "select count(1) as CacheOnOwners from cache_owners where cacheid = @gcnum;";
		$CacheHasOwnerCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::varchar, 8)|Out-Null;
		$CacheHasOwnerCmd.Prepare();
	
		$CacheOwnerUpdateCmd = $SQLConnection.CreateCommand();
		$CacheOwnerUpdateCmd.Parameters.Add("@ownerid", [System.Data.SqlDbType]::int)|Out-Null;
		$CacheOwnerUpdateCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::varchar, 8)|Out-Null;
	}
	process {
		Update-Cacher -Cachername $PlacedByName -CacherId $OwnerId;
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
	}
}

function New-TravelBug {
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[int]$TBId,
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$TBPublicId,
#	[ValidationScript({$_.Length -le 50})]
	[string]$TBName
)
	begin {
		$TBCheckCmd = $SQLConnection.CreateCommand();
		$TBCheckCmd.CommandText = "select count(1) as tbexists from travelbugs where tbinternalid = @tbid";
		$TBCheckCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int)|Out-Null;
		$TBCheckCmd.Prepare();

		$TBInsertCmd = $SQLConnection.CreateCommand();
		$TBInsertCmd.CommandText = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (@tbid, @tbpublicid, @tbname)";
		$TBInsertCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int)|Out-Null;
		$TBInsertCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::varchar, 8)|Out-Null;
		$TBInsertCmd.Parameters.Add("@tbname", [System.Data.SqlDbType]::varchar, 50)|Out-Null;
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
	}
}

function Move-TravelBugToCache {
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
#	[ValidationScript({$_.Length -le 8})]
	[string]$TBPublicId
)
	begin {
		$TBAddToCacheCmd = $SQLConnection.CreateCommand();
		$TBAddToCacheCmd.CommandText = "insert into tbinventory (cacheid, tbpublicid) values (@cacheid,@tbpublicid)";
		$TBAddToCacheCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50)|Out-Null;
		$TBAddToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8)|Out-Null;
		$TBAddToCacheCmd.Prepare();
		$TBRemoveFromCacheInventoryCmd = $SQLConnection.CreateCommand();
		$TBRemoveFromCacheInventoryCmd.CommandText = "delete from tbinventory where cacheid <> @cacheid and tbpublicid = @tbpublicid";
		$TBRemoveFromCacheInventoryCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50)|Out-Null;
		$TBRemoveFromCacheInventoryCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8)|Out-Null;
		$TBRemoveFromCacheInventoryCmd.Prepare();
	}
	process {
		$TBRemoveFromCacheInventoryCmd.Parameters["@cacheid"].Value = $GCNum;
		$TBRemoveFromCacheInventoryCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
		$TBWasInOtherCache = $TBRemoveFromCacheInventoryCmd.ExecuteNonQuery() | Out-Null;
		if ($TBWasInOtherCache) {
			$TBAddToCacheCmd.Parameters["@cacheid"].Value = $GCNum;
			$TBAddToCacheCmd.Parameters["@tbpublicid"].Value = $TBPublicId;
			$TBAddToCacheCmd.ExecuteNonQuery() | Out-Null;
		}
	}
	end {
		$TBAddToCacheCmd.Dispose();
	}
}

# TODO: Make this pipeline-aware & pass in single TBs.
function Update-TravelBug {
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$GCNum,
	[Parameter(Mandatory=$true)]
	[string]$TBPublicId,
	[Parameter(Mandatory=$true)]
	[int]$TBInternalId,
	[Parameter(Mandatory=$true)]
	[string]$TBName
)
	begin {
	}
	process{
		New-TravelBug -TBId $TBInternalId -TBPublicId $TBPublicId -TBName $TBName;
		Move-TravelBugToCache -GCNum $GCNum -TBPublicId $TBPublicId;
	}
	end {
	}
}
function Update-Geocache {
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[System.Xml.XmlElement[]]$CacheWaypoint
)
	begin {
		$CacheLoadCmd = $SQLConnection.CreateCommand();
		$CacheExistsCmd = $SQLConnection.CreateCommand();
		$CacheExistsCmd.CommandText = "select count(1) from caches where cacheid = @CacheId;";
		$CacheExistsCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar,8)|out-null;
		$CacheExistsCmd.Prepare();
		$CacheLoadCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar, 8)|out-null;
		$CacheLoadCmd.Parameters.Add("@gsid", [System.Data.SqlDbType]::int)|out-null;
		$CacheLoadCmd.Parameters.Add("@CacheName", [System.Data.SqlDbType]::nvarchar, 50)|out-null;
		$CacheLoadCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::float)|out-null;
		$CacheLoadCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::float)|out-null;
		$CacheLoadCmd.Parameters.Add("@Placed", [System.Data.SqlDbType]::datetime)|out-null;
		$CacheLoadCmd.Parameters.Add("@PlacedBy", [System.Data.SqlDbType]::nvarchar)|out-null;
		$CacheLoadCmd.Parameters.Add("@TypeId", [System.Data.SqlDbType]::int)|out-null;
		$CacheLoadCmd.Parameters.Add("@SizeId", [System.Data.SqlDbType]::int)|out-null;
		$CacheLoadCmd.Parameters.Add("@Diff", [System.Data.SqlDbType]::float)|out-null;
		$CacheLoadCmd.Parameters.Add("@Terrain", [System.Data.SqlDbType]::float)|out-null;
		$CacheLoadCmd.Parameters.Add("@ShortDesc", [System.Data.SqlDbType]::nvarchar, 5000)|out-null;
		#See http://support.microsoft.com/kb/970519 for bug workaround
		$CacheLoadCmd.Parameters["@ShortDesc"].Size = -1;
		$CacheLoadCmd.Parameters.Add("@LongDesc", [System.Data.SqlDbType]::ntext)|out-null;
		$CacheLoadCmd.Parameters.Add("@Hint", [System.Data.SqlDbType]::nvarchar, 1000)|out-null;
		$CacheLoadCmd.Parameters.Add("@Avail", [System.Data.SqlDbType]::bit)|out-null;
		$CacheLoadCmd.Parameters.Add("@Archived", [System.Data.SqlDbType]::bit)|out-null;
		$CacheLoadCmd.Parameters.Add("@PremOnly", [System.Data.SqlDbType]::bit)|out-null;
		$CacheLoadCmd.Parameters.Add("@CacheStatus",[System.Data.SqlDbType]::Int)|Out-Null;
		$CacheLoadCmd.Parameters.Add("@CacheUpdated", [System.Data.SqlDbType]::DateTime) | Out-Null;
		#$CacheLoadCmd.Prepare();
	}
	process {
	# TODO: Can't navigate XML element structure anymore, need to use ugliness like $CacheWaypoint|select -expandproperty cache|select -expandproperty name
		$GCNum = $CacheWaypoint | Select-Object -ExpandProperty name;
		$GCNum;
		$PlacedDate = get-date ($CacheWaypoint | select-object -expandproperty time);
		
		$Latitude = $CacheWaypoint | Select-object -expandproperty lat;
		$Longitude = $CacheWaypoint | Select-object -expandproperty lon;
		$CacheExistsCmd.Parameters["@CacheId"].Value = $GCNum;
		$CacheExists = $CacheExistsCmd.ExecuteScalar();
		$CacheWaypoint = $CacheWaypoint | select-object -expandproperty cache;
		# Load/Update cache table
# TODO: Use GPX time for Last Updated. $cachedata.gpx.time
		if (!$CacheExists){
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
				   ,[created])
		     VALUES
		           (@CacheId
		           ,@GSID
		           ,@CacheName
		           ,@Lat
		           ,@Long
		           ,getdate()
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
				   ,getdate()
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
		 WHERE CacheId = @CacheId;
"@;
		}
		$CacheLoadCmd.Parameters["@CacheId"].Value = $GCNum;
		$CacheLoadCmd.Parameters["@gsid"].Value = $CacheWaypoint | select-object -expandproperty id;
		$CacheLoadCmd.Parameters["@CacheName"].Value = $CacheWaypoint | select-object -expandproperty name;
		$CacheLoadCmd.Parameters["@Lat"].Value = $Latitude;
		$CacheLoadCmd.Parameters["@Long"].Value = $Longitude;
		$CacheLoadCmd.Parameters["@Placed"].Value = $PlacedDate;
		$CacheLoadCmd.Parameters["@PlacedBy"].Value = $CacheWaypoint | select-object -expandproperty placed_by;
		$CacheLoadCmd.Parameters["@TypeId"].Value = $PointTypeLookup|where-object{$_.typename -eq ($CacheWaypoint | select-object -expandproperty type)} | Select-Object -expandproperty typeid;
		$CacheLoadCmd.Parameters["@SizeId"].Value = $CacheSizeLookup|where-object{$_.sizename -eq ($CacheWaypoint | select-object -expandproperty container)} | Select-Object -expandproperty sizeid;
		$CacheLoadCmd.Parameters["@Diff"].Value = $CacheWaypoint | select-object -expandproperty difficulty;
		$CacheLoadCmd.Parameters["@Terrain"].Value = $CacheWaypoint | select-object -expandproperty terrain;
		$CacheLoadCmd.Parameters["@ShortDesc"].Value = $CacheWaypoint | select-object -expandproperty short_description | select-object -expandproperty innertext;
		$CacheLoadCmd.Parameters["@LongDesc"].Value = $CacheWaypoint | select-object -expandproperty long_description | select-object -expandproperty innertext;
		$CacheLoadCmd.Parameters["@Hint"].Value = $CacheWaypoint | select-object -expandproperty encoded_hints;
		$CacheLoadCmd.Parameters["@Avail"].Value = Get-DBTypeFromTrueFalse ($CacheWaypoint | select-object -expandproperty available);
		$CacheLoadCmd.Parameters["@Archived"].Value = Get-DBTypeFromTrueFalse ($CacheWaypoint | select-object -expandproperty archived);
		$CacheLoadCmd.Parameters["@CacheUpdated"].Value = $GPXDate;
		if (($CacheWaypoint|Select-Object -expandproperty archived)  -eq "true") {
			$UnifiedStatus = $CacheStatusLookup |Where-Object{$_.statusname -eq "archived"}|Select-Object -ExpandProperty statusid;
		} else{
			if (($CacheWaypoint|Select-Object -expandproperty available) -eq "true") {
				$UnifiedStatus = $CacheStatusLookup |Where-Object{$_.statusname -eq "available"}|Select-Object -ExpandProperty statusid;
			} else {
				$UnifiedStatus = $CacheStatusLookup |Where-Object{$_.statusname -eq "disabled"}|Select-Object -ExpandProperty statusid;
			}
		}
		$CacheLoadCmd.Parameters["@CacheStatus"].Value = $UnifiedStatus;
		# TODO: Figure out where premium only comes from. Doesn't appear to be in the GPX
		$CacheLoadCmd.Parameters["@PremOnly"].Value = 0; #Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.
		# Execute
		$CacheLoadCmd.ExecuteNonQuery() | Out-Null;

		Update-CacheOwner -GCNum $GCNum -OwnerId $($CacheWaypoint|Select-Object -ExpandProperty owner|Select-Object -ExpandProperty id) -PlacedByName $($CacheWaypoint | select-object -expandproperty placed_by);
	}
	end {
		$CacheLoadCmd.Dispose();
		$CacheExistsCmd.Dispose();
	}
}

function Update-Log {
param (
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[int]$LogId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[string]$CacheId,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[System.DateTime]$LogDate,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[string]$LogTypeName,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitLogDetails")]
	[int]$Finder,
	[Parameter(Mandatory=$false,ParameterSetName="ExplicitLogDetails")]
	[string]$LogText="",
	[Parameter(Mandatory=$false,ParameterSetName="ExplicitLogDetails")]
	[float]$Latitude,
	[Parameter(Mandatory=$false,ParameterSetName="ExplicitLogDetails")]
	[float]$Longitude,
	[Parameter(Mandatory=$true,ParameterSetName="LogObject")]
	[System.Xml.XmlElement]$CacheLog
)
begin {
		$LogExistsCmd = $SQLConnection.CreateCommand();
		$LogExistsCmd.CommandText = "select count(1) from logs where logid = @LogId;"
		$LogExistsCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::BigInt)|out-null;
		$LogExistsCmd.Prepare();
		$LogTableUpdateCmd = $SQLConnection.CreateCommand();
		$LogTableUpdateCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::bigint)|Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::varchar, 50)|Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogDate", [System.Data.SqlDbType]::DateTime)|Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogType", [System.Data.SqlDbType]::Int)|Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@LogText", [System.Data.SqlDbType]::NVarChar, 4000)|Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::Float)|Out-Null;
		$LogTableUpdateCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::Float)|Out-Null;
		$LogTypes = Invoke-Sqlcmd -ServerInstance $SQLInstance -Database $Database -Query "select logtypeid,logtypedesc from log_types";
		$LogLinkToCacheCmd = $SQLConnection.CreateCommand();
		$LogLinkToCacheCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::bigint)|Out-Null;
		$LogLinkToCacheCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar, 8)|Out-Null;
		$LogLinkToCacheCmd.CommandText = "insert into cache_logs (cacheid,logid) values (@CacheId, @LogId)";
		$LogLinkToCacheCmd.Prepare();
		$LogLinkedCmd = $SQLConnection.CreateCommand();
		$LogLinkedCmd.Parameters.Add("@LogId", [System.Data.SqlDbType]::bigint)|Out-Null;
		$LogLinkedCmd.CommandText = "select count(1) from cache_logs where logid = @LogId";
		$LogLinkedCmd.Prepare();
	}
	process{
		switch ($PsCmdlet.ParameterSetName) {
			"LogObject" {
				$Finder = $CacheLog.finder.id;
				$LogId = $CacheLog.id;
				$LogDate = Get-Date $CacheLog.date;
				$LogType = $LogTypes|Where-Object{$_.logtypedesc -eq $CacheLog.type};
				$LogText = $CacheLog.text;
				$Latitude = $CacheLog.lat;
				$Longitude = $CacheLog.lon;
			}
			"ExplicitLogDetails" {
				$LogType = $LogTypes|Where-Object{$_.logtypedesc -eq $LogTypeName}|Select-Object -ExpandProperty logtypeid;
			}
		}
		
		$LogExistsCmd.Parameters["@LogId"].Value = $LogId;
		$LogExists = $LogExistsCmd.ExecuteScalar();
		if ($LogExists){
		# Update cacher name if it's changed
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
	}
}

function Update-Waypoint {
[cmdletbinding()]
param (
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[PSObject[]]$Waypoint
)
	begin {
		$WptExistsCmd = $SQLConnection.CreateCommand();
		$WptExistsCmd.CommandText = "select count(1) from waypoints where waypointid = @wptid and parentcache = @cacheid;";
		$WptExistsCmd.Parameters.Add("@wptid", [System.Data.SqlDbType]::VarChar,10);
		$WptExistsCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar,8);
		$WptUpsertCmd = $SQLConnection.CreateCommand();
		$WptExistsCmd.Prepare();
		$WptUpsertCmd.Parameters.Add("@wptid", [System.Data.SqlDbType]::VarChar,10);
		$WptUpsertCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar,8);
		$WptUpsertCmd.Parameters.Add("@lat",[System.Data.SqlDbType]::Float);
		$WptUpsertCmd.Parameters.Add("@long",[System.Data.SqlDbType]::Float);
		$WptUpsertCmd.Parameters.Add("@name",[System.Data.SqlDbType]::VarChar,50);
		$WptUpsertCmd.Parameters.Add("@desc",[System.Data.SqlDbType]::VarChar, 2000);
		$WptUpsertCmd.Parameters.Add("@url",[System.Data.SqlDbType]::varchar,2038);
		$WptUpsertCmd.Parameters.Add("@urldesc",[System.Data.SqlDbType]::nvarchar, 200);
		$WptUpsertCmd.Parameters.Add("@pointtype", [System.Data.SqlDbType]::int);
		
	}
	process {
		$Latitude = [float]($Waypoint | select-object -expandproperty Lat);
		$Longitude =  = [float]($Waypoint | select-object -expandproperty Long);
		$WptDate =  = get-date ($Waypoint | select-object -expandproperty  DateTime);
		$Id = $Waypoint | select-object -expandproperty Id;
		$Name = $Waypoint | select-object -expandproperty Name;
		$Description = $Waypoint | select-object -expandproperty Description;
		$Url = $Waypoint | select-object -expandproperty Url;
		$UrlDesc = $Waypoint | select-object -expandproperty UrlDesc;
		$Symbol = $Waypoint | select-object -expandproperty Symbol;
		$PointType = $Waypoint | select-object -expandproperty PointType;
# Check for point type. If it doesn't exist, create it
# Get parent cache id. Same as waypoint ID but first 2 chars are GC
		$ParentCache = "GC" + $Id.Substring(2,$Id.Length - 2);
		$WptExistsCmd.Parameters["@wptid"].Value = $Id;
		$WptExistsCmd.Parameters["@cacheid"].Value = $ParentCache;
		$WaypointExists = $WptExistsCmd.ExecuteScalar();
		if ($WaypointExists) {
			$WptUpsertCmd.CommandText = @"
update waypoints set
	latitude = @lat,
	longitude = @long,
	name = @name,
	description = @desc,
	url = @url,
	urldesc = @urldesc,
	typeid = @pointtype
where
	waypointid = @wptid
	and parentcache = @cacheid;
"@;
		} else {
			$WptUpsertCmd.CommandText = @"
insert into waypoints (waypointid,parentcache,latitude,longitude,name,description,url,urldesc,typeid) values (
@wptid, @cacheid,@lat,@long,@name,@desc,@url,@urldesc,@typeid);
"@;
		}
	}
	end {
	}
}
function New-Attribute {
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [PSObject[]]$Attribute
)
	begin {
		$CacheAttributeCheckCmd = $SQLConnection.CreateCommand();
		$CacheAttributeCheckCmd.CommandText = "select count(1) as attrexists from attributes where attributeid = @attrid";
		$CacheAttributeCheckCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int)|Out-Null;
		$CacheAttributeCheckCmd.Prepare();

		$CacheAttributeInsertCmd = $SQLConnection.CreateCommand();
		$CacheAttributeInsertCmd.CommandText = "insert into attributes (attributeid,attributename) values (@attrid, @attrname)";
		$CacheAttributeInsertCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int)|Out-Null;
		$CacheAttributeInsertCmd.Parameters.Add("@attrname", [System.Data.SqlDbType]::varchar, 50)|Out-Null;
		$CacheAttributeInsertCmd.Prepare();
	}
	process {
		$AttrId = [int]($Attribute | select-object -expandproperty AttrId);
		$AttrName = $Attribute | select-object -expandproperty AttrName;
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
	}
}

function Drop-Attributes {
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true)]
    [string]$CacheId
)
	begin {
		$DropCacheAttributesCmd = $SQLConnection.CreateCommand();
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
	}
}
function Register-AttributeToCache {
[cmdletbinding()]
param(
	[Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Object[]]$Attribute
)
	begin {
		$RegisterAttributeToCacheCmd = $SQLConnection.CreateCommand();
		$RegisterAttributeToCacheCmd.CommandText = "insert into cache_attributes (cacheid,attributeid,attribute_applies) values (@cacheid,@attrid,@attrapplies);";
		$RegisterAttributeToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8) | Out-Null;
		$RegisterAttributeToCacheCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int) | Out-Null;
		$RegisterAttributeToCacheCmd.Parameters.Add("@attrapplies", [System.Data.SqlDbType]::Bit) | Out-Null;
		$RegisterAttributeToCacheCmd.Prepare();
	}
	process {
		$RegisterAttributeToCacheCmd.Parameters["@cacheid"].Value = $Attribute | Select-Object -ExpandProperty ParentCache;
		$RegisterAttributeToCacheCmd.Parameters["@attrid"].Value = $Attribute | Select-Object -ExpandProperty AttrId;
		$RegisterAttributeToCacheCmd.Parameters["@attrapplies"].Value = [bool]($Attribute | Select-Object -ExpandProperty AttrInc);
		$RegisterAttributeToCacheCmd.ExecuteNonQuery() | Out-Null;
	}
	end {
		$RegisterAttributeToCacheCmd.Dispose();
	}
}
#endregion

# Get Type & Size lookup tables
$PointTypeLookup = invoke-sqlcmd -server $SQLInstance -database $Database -query "select typeid, typename from point_types;";
$CacheSizeLookup = invoke-sqlcmd -server $SQLInstance -database $Database -query "select sizeid, sizename from cache_sizes;";
$CacheStatusLookup = Invoke-SQLCmd -server $SQLInstance -database $Database -query "select statusid, statusname from statuses;";

[xml]$cachedata = get-content $FileToImport;
$GPXDate = get-date $cachedata.gpx.time;
# For each $cachedata.gpx.wpt
# Check for a cache child element
# If one exists, it's a cache
# Otherwise, it's a waypoint
$cachedata.gpx.wpt|where-object{$_.type.split("|")[0] -eq "Geocache"} | ForEach-Object {
	$GCNum = $_.name;
	Update-Geocache $_; #Process as geocache
# Load cacher table if no record for current cache's owner, or update name
	Update-Cacher -Cacher $_.cache.owner;
# Insert attributes & TBs into respective tables
	$AllAttributes = New-Object -TypeName System.Collections.Generic.List[PSObject];
	$_.cache.attributes.attribute | ForEach-Object {
		$CacheAttribute = New-Object -TypeName PSObject -Property @{
			AttrId = $_.id
			AttrInc = $_.inc
			AttrName = $_."#text"
			ParentCache = $GCNum
		};
		$AllAttributes.Add($CacheAttribute);
	};
	
	$AllAttributes | New-Attribute;
	Drop-Attributes -CacheID $GCNum;
	$AllAttributes| Register-AttributeToCache;
#TODO: Make this pipeline aware with $cachedata.gpx.wpt.cache.travelbugs.travelbug|update-travelbugs
	
	if ($_.cache.travelbugs.length -gt 0) {
		$tbs = $_.cache.travelbugs | select-object -expandproperty travelbug;
		ForEach ($tb in $tbs) {
			Update-TravelBug -GCNum $GCNum -TBPublicId $tb.ref -TBName $tb.name -TBInternalId $tb.id;
		}
	}
	$logs = $_.cache.logs|Select-Object -ExpandProperty log;
# TODO: Make this pipeline aware with $logs.finder |Update-Cacher
	$logs | Select-Object -ExpandProperty finder|foreach-object{Update-Cacher -Cacher $_}
	$logs | foreach-object {
		$UpdateLogVars = @{
			'LogId' = $_.id;
			'CacheId' = $GCNum;
			'LogDate' = $_.date;
			'LogTypeName' = $_.type;
			'Finder' = $_.finder.id;
		};
		if (($_.text|select -ExpandProperty "#text" -ErrorAction SilentlyContinue) -eq $null) {
			$UpdateLogVars.Add('LogText', '');
		} else {
			$UpdateLogVars.Add('LogText', $($_.text|Select-Object -ExpandProperty "#text"));
		}
		if ($_.log_wpt) {
			$UpdateLogVars.Add('Latitude',$_.log_wpt.lat);
			$UpdateLogVars.Add('Longitude',$_.log_wpt.lon);
		}
		Update-Log @UpdateLogVars;
	};
};
$ChildWaypoints = New-Object -TypeName System.Collections.Generic.List[PSObject];
$cachedata.gpx.wpt|Where-Object{$_.type.split("|")[0] -ne "Geocache"} | ForEach-Object{
	$Waypoint = New-Object -TypeName PSObject -Property @{
			Lat = $_.lat
			Long = $_.lon
			DateTime = $_.time
			Id = $_.name
			Name = $_.cmt
			Description = $_.desc
			Url = $_.url
			UrlDesc = $_.urlname
			Symbol = $_.sym
			PointType = $_.type.split("|")[1];
		};
		$ChildWaypoints.Add($Waypoint);
};

$ChildWaypoints | Update-Waypoint;

$SQLConnection.Close();
Remove-Module sqlps;
