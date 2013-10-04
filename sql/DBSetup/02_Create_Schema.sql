USE Geocaches;

create table point_types (
	typeid int not null constraint pk_point_types primary key,
	typename varchar(30) not null
);

create table cache_sizes (
	sizeid int not null constraint pk_cache_sizes primary key,
	sizename varchar(16)
);

create table countries (
	countryid int not null constraint pk_countries primary key,
	name nvarchar(50)
);

create table states (
	stateid int not null constraint pk_states primary key,
	name nvarchar(50)
);

CREATE sequence statusid as int start with 1 increment by 1;
create table statuses (
	statusid int not null constraint pk_statuses primary key default next value FOR statusid,
	statusname varchar(12) not null
);

create table caches (
	cacheid varchar(8) not null constraint pk_caches primary key,
	gsid int not null,
	cachename nvarchar(50) not null,
	latitude float not null,
	longitude float not null,
	lastupdated datetime not null default getdate(),
	placed date not null,
	placedby nvarchar(50) not null,
	typeid int not null,
	sizeid int not null,
	difficulty float not null,
	terrain float not null,
	shortdesc nvarchar(500) not null, /* Matches geocaching.com maximum length */
	longdesc ntext not null,
	hint nvarchar(1000) NULL,
	available bit not null default 1,
	archived bit not null default 0,
	premiumonly bit not null default 0,
	cachestatus int not null default 1,
	created datetime not null default getdate()
	constraint fk_cache_type foreign key (typeid) references point_types (typeid),
	constraint fk_cache_size foreign key (sizeid) references cache_sizes (sizeid),
	constraint fk_cache_status foreign key (cachestatus) references statuses (statusid)
);
alter table caches
add latlong
as geography::Point(latitude, longitude, 4326) persisted;


create table attributes (
	attributeid int not null constraint pk_attributes primary key,
	attributename varchar(50) not null
);
create table cache_attributes (
	cacheid varchar(8) not null,
	attributeid int not null,
	attribute_applies bit default 1 /* Attributes can be tagged to a cache as "yes" or "no". For example a cache may have the "poisonous plants" attribute set, but flagged as "no poisonous plants" indicating that there isn't poison ivy at a cache site. If the inc attribute of the <groundspeak:attribute> element is 1, this indicates "yes".*/
	constraint fk_attr_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_attr_id foreign key (attributeid) references attributes (attributeid)
);
create table cachers  (
	cacherid int not null constraint pk_cachers primary key,
	cachername varchar(50) not null
);
create table cache_owners (
	cacheid varchar(8) constraint pk_cache_owners primary key,
	cacherid int
	constraint fk_owner_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_owner_cacher foreign key (cacherid) references cachers (cacherid)
);
create table waypoints (
	waypointid varchar(8) not null constraint pk_waypoints primary key,
	parentcache varchar(8) not null,
	latitude float not null,
	longitude float not null,
	typeid int,
	[name] varchar(50) not null,
	description varchar(2000) not null,
	url varchar(2038) not null,
	urldesc nvarchar(200),
	lookupcode nvarchar(6)
	constraint fk_waypoint_cacheid foreign key (parentcache) references caches (cacheid),
	constraint fk_waypoint_type foreign key (typeid) references point_types (typeid)
);

alter table waypoints
add latlong
as geography::Point(latitude, longitude, 4326) persisted;

CREATE sequence logtypeid as int start with 1 increment by 1;
create table log_types (
	logtypeid int not null constraint pk_log_types primary key  DEFAULT (NEXT VALUE FOR logtypeid),
	logtypedesc varchar(30) not null
);

create table logs (
	logid bigint not null constraint pk_logs primary key,
	logdate datetime not null,
	logtypeid int not null,
	cacherid int not null,
	logtext nvarchar(4000),
	latitude float null,
	longitude float null
	constraint fk_logtype foreign key (logtypeid) references log_types (logtypeid),
	constraint fk_cacher foreign key (cacherid) references cachers (cacherid)
);

alter table logs
add latlong
as geography::Point(latitude, longitude, 4326) persisted;

create table cache_logs (
	cacheid varchar(8) not null,
	logid bigint not null,
	constraint fk_log_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_log_logid foreign key (logid) references logs (logid),
	constraint pk_cache_logs primary key (cacheid,logid)
);
create table travelbugs (
	tbpublicid varchar(8) not null constraint pk_travelbugs primary key,
	tbinternalid int not null,
	tbname varchar(50) not null
);

create table tbinventory (
	cacheid varchar(8) not null,
	tbpublicid varchar(8) not null,
	constraint fk_tb_id foreign key (tbpublicid) references travelbugs (tbpublicid),
	constraint fk_cacheid foreign key (cacheid) references caches (cacheid),
	constraint pk_tbinventory primary key (cacheid,tbpublicid)
);

create table CenterPoints  (
	Locationname varchar(20) not null,
	LocationGeo geography not null
	constraint pk_centerpoints primary key (Locationname)
);