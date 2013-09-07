create table caches as (
	cacheid varchar(8) not null unique,
)
create table attributes as (
	attributeid int not null unique,
	attributename varchar(50) not null
)
create table cache_attributes as (
	cacheid varchar(8) not null,
	attributeid int not null,
	attribute_applies bit default 1 /* Attributes can be tagged to a cache as "yes" or "no". For example a cache may have the "poisonous plants" attribute set, but flagged as "no poisonous plants" indicating that there isn't poison ivy at a cache site. If the inc attribute of the <groundspeak:attribute> element is 1, this indicates "yes".*/
)
create table cachers as (
	cacherid int not null unique,
	cachername varchar(50) not null
)
create table cache_owners as (
	cacheid varchar(8),
	cacherid int
)
create table waypoints as (
	waypointid varchar(8) not null unique,
	parentcache varchar(8) not null,
	typeid int
)
create table waypoint_types as (
	typeid int not null unique,
	typename varchar(16) not null unique,
	symbol varchar(16) not null
)
create table cache_sizes as (
	sizeid int not null unique,
	name varchar(16)
)
create table logs as (
	logid bigint not null unique
)
create table cache_logs as (
	cacheid varchar(8) not null,
	logid bigint not null
)