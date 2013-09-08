create table caches as (
	cacheid varchar(8) not null unique,
	gsid int not null unique
	cachename varchar() not null,
	latitude float not null,
	longitude float not null,
	latlong geography not null,
	lastupdated datetime not null default getdate(),
	placed date not null,
	placedby varchar() not null,
	typeid varchar() not null,
	containerid int not null,
	sizeid int not null,
	difficulty double not null,
	terrain not null,
	country varchar(50) not null,
	[state] varchar(50) not null,
	shortdesc UNKNOWN not null,
	longdesc UNKNOWN not null,
	hint UNKNOWN NULL,
	available bit not null default 1,
	archived bit not null default 0
	constraint fk_cache_type foreign key (typeid) references point_types (typeid),
	constraint fk_container_type foreign key (containerid) references cache_containers (containerid),
	constraint fk_cache_size foreign key (size) references cache_sizes (sizeid)
)
create table attributes as (
	attributeid int not null unique,
	attributename varchar(50) not null
)
create table cache_attributes as (
	cacheid varchar(8) not null,
	attributeid int not null,
	attribute_applies bit default 1 /* Attributes can be tagged to a cache as "yes" or "no". For example a cache may have the "poisonous plants" attribute set, but flagged as "no poisonous plants" indicating that there isn't poison ivy at a cache site. If the inc attribute of the <groundspeak:attribute> element is 1, this indicates "yes".*/
	constraint fk_attr_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_attr_id foreign key (attributeid) references attributes (attributeid)
)
create table cachers as (
	cacherid int not null unique,
	cachername varchar(50) not null
)
create table cache_owners as (
	cacheid varchar(8),
	cacherid int
	constraint fk_owner_cacheid foreign key (cacheid) references caches (cacheid),
	constraint fk_owner_cacher foreign key (cacheid) references caches (cacheid)
)
create table waypoints as (
	waypointid varchar(8) not null unique,
	parentcache varchar(8) not null,
	latitude float not null,
	longitude float not null,
	latlong geography not null,
	typeid int,
	[name] varchar(8) not null,
	description varchar() not null,
	comment varchar(),
	url varchar(200) not null
	constraint fk_waypoint_cacheid foreign key (parentcache) references caches (cacheid),
	constraint fk_waypoint_type foreign key (typeid) references point_types (typeid)
)
create table point_types as (
	typeid int not null unique,
	typename varchar(16) not null unique,
	symbol varchar(16) not null
)
create table cache_sizes as (
	sizeid int not null unique,
	sizename varchar(16)
)
create table cache_containers as (
	containerid int not null unique,
	containername varchar(16)
)
create table logs as (
	logid bigint not null unique,
	logdate datetime not null,
	logtypeid int not null,
	cacherid int not null,
	logtext UNKNOWN,
	latitude float null,
	longitude float null,
	latlong geography null,
	foreign key (fk_logtype) references log_types (logtypeid),
	foreign key (fk_cacher) references cachers (cacherid)
)
create table cache_logs as (
	cacheid varchar(8) not null,
	logid bigint not null,
	foreign key (fk_log_cacheid) references caches (cacheid),
	foreign key (fk_log_logid) references logs (logid)
)
create table log_types as (
	logtypeid int not null unique,
	logtypedesc varchar(20) not null
)
create table tbinventory as (
	cacheid varchar(8) not null,
	tbid UNKNOWN not null
	constraint fk_tb_id foreign key (tbid) references travelbugs (tbid)
)
create table travelbugs as (
	tbid UNKNOWN not null unique
	tbname varchar() not null
)