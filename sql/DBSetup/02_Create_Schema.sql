USE Geocaches;
create table PointType
(
	TypeId int identity(1,1) not null constraint PK_PointType primary key,
	TypeName varchar(30) not null
);

create table CacheSize
(
	SizeId int not null constraint PK_CacheSize primary key,
	SizeName varchar(16)
);

create table Country
(
	CountryId int not null constraint PK_Country primary key,
	CountryName nvarchar(50)
);

create table [State]
(
	StateId int not null constraint PK_State primary key,
	StateName nvarchar(50)
);

create table [Status]
(
	StatusId int identity (1,1) not null constraint PK_Status primary key,
	StatusName varchar(12) not null
);

create table Geocache
(
	CacheId varchar(8) not null constraint PK_Geocache primary key,
	gsid int not null,
	cachename nvarchar(50) not null,
	latitude float not null,
	longitude float not null,
	lastupdated datetime not null default getdate(),
	placed date not null,
	placedby nvarchar(50) not null,
	TypeId int not null,
	SizeId int not null,
	difficulty float not null,
	terrain float not null,
	shortdesc nvarchar(500) not null,
	/* Matches geocaching.com maximum length */
	longdesc ntext not null,
	hint nvarchar(1000) NULL,
	available bit not null default 1,
	archived bit not null default 0,
	premiumonly bit not null default 0,
	GeocacheStatus int not null default 1,
	created datetime not null default getdate(),
	latlong as geography::Point (latitude, longitude, 4326) persisted
		constraint FK_cache_type foreign key (TypeId) references PointType (TypeId),
	constraint FK_cache_size foreign key (SizeId) references CacheSize (SizeId),
	constraint FK_cache_status foreign key (GeocacheStatus) references Status (StatusId)
);

create table Attribute
(
	AttributeId int not null constraint PK_Attribute primary key,
	AttributeName varchar(50) not null
);
create table CacheAttributeMap
(
	CacheId varchar(8) not null,
	AttributeId int not null,
	AttributeApplies bit default 1 /* Attributes can be tagged to a cache as "yes" or "no". For example a cache may have the "poisonous plants" attribute set, but flagged as "no poisonous plants" indicating that there isn't poison ivy at a cache site. If the inc attribute of the <groundspeak:attribute> element is 1, this indicates "yes".*/
		constraint FK_attr_CacheId foreign key (CacheId) references Geocache (CacheId),
	constraint FK_attr_id foreign key (AttributeId) references Attribute (AttributeId)
);
create table Cacher
(
	CacherId int not null constraint PK_Cacher primary key,
	CacherName varchar(50) not null
);
create table CacheOwner
(
	CacheId varchar(8) constraint PK_CacheOwner primary key,
	CacherId int
		constraint FK_owner_CacheId foreign key (CacheId) references Geocache (CacheId),
	constraint FK_owner_cacher foreign key (CacherId) references Cacher (CacherId)
);
create table Waypoint
(
	waypointid varchar(10) not null constraint PK_Waypoint primary key,
	parentcache varchar(8) not null,
	latitude float not null,
	longitude float not null,
	TypeId int,
	[waypointname] varchar(50) not null,
	description varchar(2000) not null,
	url varchar(2038) not null,
	urldesc nvarchar(200),
	lookupcode nvarchar(6),
	latlong as geography::Point (latitude, longitude, 4326) persisted
	constraint FK_waypoint_CacheId foreign key (parentcache) references Geocache (CacheId),
	constraint FK_waypoint_type foreign key (TypeId) references PointType (TypeId)
);

create table LogType
(
	LogTypeId int identity(1,1) not null constraint PK_LogType primary key,
	LogTypeDesc varchar(30) not null
);

create table CacheLog
(
	LogId bigint not null constraint PK_CacheLog primary key,
	logdate datetime not null,
	LogTypeId int not null,
	CacherId int not null,
	logtext nvarchar(4000),
	latitude float null,
	longitude float null,
	latlong as geography::Point(latitude, longitude, 4326) persisted
		constraint FK_logtype foreign key (LogTypeId) references LogType (LogTypeId),
	constraint FK_cacher foreign key (CacherId) references Cacher (CacherId)
);

create table CacheLogMap
(
	CacheId varchar(8) not null,
	LogId bigint not null,
	constraint FK_log_CacheId foreign key (CacheId) references Geocache (CacheId),
	constraint FK_log_LogId foreign key (LogId) references CacheLog (LogId),
	constraint PK_CacheLogMap primary key (CacheId,LogId)
);
create table TravelBug
(
	TravelBugPublicId varchar(8) not null constraint PK_TravelBug primary key,
	TravelBugInternalId int not null,
	TravelBugName varchar(50) not null
);

create table TravelBugCacheMap
(
	CacheId varchar(8) not null,
	TravelBugPublicId varchar(8) not null,
	constraint FK_tb_id foreign key (TravelBugPublicId) references TravelBug (TravelBugPublicId),
	constraint FK_CacheId foreign key (CacheId) references Geocache (CacheId),
	constraint PK_TravelBugCacheMap primary key (CacheId,TravelBugPublicId)
);

create table CenterPoint
(
	LocationName varchar(20) not null,
	LocationGeo geography not null
		constraint PK_centerpoints primary key (LocationName)
);