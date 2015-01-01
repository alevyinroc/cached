--exec sp_askbrent

select * from sys.dm_db_missing_index_details

select top 1 cacheid from cachedb.dbo.caches;

alter table caches  add constraint PK_caches primary key nonclustered (cacheid);

drop index ix_cacheplaced on dbo.caches;
create clustered index IX_CachePlaced on dbo.caches (placed asc) with fillfactor=90;

select * from caches where cacheid = 'gc100gz';
select top 10  * from caches order by placed;


create clustered index IX_LogLogDate on dbo.logs (logdate asc) with fillfactor=90;
alter table dbo.logs add constraint PK_Logs primary key nonclustered (logid);

alter table dbo.attributes add constraint PK_Attributes primary key clustered (attributeid);

alter table dbo.cache_logs add constraint PK_CacheLogs primary key nonclustered (cacheid,logid);

alter table dbo.cache_attributes add constraint PK_CacheAttributes primary key nonclustered (cacheid,attributeid);

alter table dbo.cache_attributes add constraint FK_AttrId foreign key (attributeid) references dbo.attributes (attributeid);
alter table dbo.cache_attributes add constraint FK_CacheId foreign key (cacheid) references dbo.caches (cacheid);

alter table dbo.cache_logs add constraint FK_CLCacheID foreign key (cacheid) references dbo.caches (cacheid);
alter table dbo.cache_logs add constraint FK_CacheLogs_LogID foreign key (logid) references dbo.logs (logid);

alter table dbo.cache_owners add constraint FK_CacheOwners_CacheID foreign key (cacheid) references dbo.caches(cacheid);
alter table dbo.cache_owners alter column cacherid int not null;

begin transaction
alter table dbo.cache_owners drop constraint FK_CacheOwners_CacherID;
alter table dbo.cachers drop constraint PK_CacherId; 
alter table dbo.cachers add constraint PK_CacherId primary key clustered (cacherid);
alter table dbo.cache_owners add constraint FK_CacheOwners_CacherID foreign key (cacherid) references dbo.cachers(cacherid);
commit transaction
alter table dbo.cache_owners add constraint PK_CacherOwners primary key nonclustered (cacheid,cacherid);
alter table dbo.cache_owners add constraint FK_CacheOwners_CacherID foreign key (cacherid) references dbo.cachers(cacherid);

alter table dbo.cache_sizes add constraint PK_CacheSizes primary key nonclustered (sizeid);
alter table dbo.caches add constraint FK_Caches_SizeId foreign key (sizeid) references dbo.cache_sizes (sizeid);
alter table dbo.states add constraint PK_States primary key nonclustered (stateid);
alter table dbo.caches add constraint FK_Caches_StateId foreign key (stateid) references dbo.states (stateid);

alter table dbo.statuses add constraint PK_Statuses primary key nonclustered (statusid);
alter table dbo.caches add constraint FK_Caches_StatusId foreign key (cachestatus) references dbo.statuses (statusid);

alter table dbo.log_types add constraint PK_LogTypes primary key nonclustered (logtypeid);
alter table dbo.logs add constraint FK_Log_LogType foreign key (logtypeid) references dbo.log_types (logtypeid);

alter table dbo.point_types add constraint PK_PointType primary key nonclustered (typeid);
alter table dbo.caches add constraint FK_Caches_PointType foreign key (typeid) references dbo.point_types (typeid);

alter table dbo.tbinventory add constraint PK_TBInventory primary key nonclustered (cacheid,tbpublicid);
alter table dbo.tbinventory add constraint FK_TBInventory_CacheId foreign key (cacheid) references dbo.caches (cacheid);

alter table dbo.travelbugs add constraint PK_Travelbugs primary key nonclustered (tbpublicid);
alter table dbo.tbinventory add constraint FK_TBInventory_TBId foreign key (tbpublicid) references dbo.travelbugs (tbpublicid);

alter table dbo.waypoints add constraint PK_Waypoints primary key nonclustered (waypointid);
alter table dbo.waypoints add constraint FK_Waypoints_Cacheid foreign key (parentcache) references dbo.caches (cacheid);
alter table dbo.waypoints add constraint FK_Waypoints_Typeid foreign key (typeid) references dbo.point_types (typeid);

alter table dbo.waypoints add Created datetimeoffset null;
create clustered index IX_WPUpdated on dbo.waypoints (Created asc) with fillfactor=90;
alter table dbo.centerpoints add constraint PK_CenterPoints primary key  (locationname);

alter table Counties add constraint PK_Counties PRIMARY KEY (CountyId,StateId);
alter table countries add constraint PC_Countries PRIMARY KEY (CountryId);
alter table Counties add constraint FK_Counties_State  FOREIGN KEY (StateId) references States(StateId);
alter table Caches add constraint FK_Caches_Statuses FOREIGN KEY (cachestatus) references statuses(statusid);
alter table Caches add constraint FK_Caches_Countries  FOREIGN KEY (CountryId) references Countries(CountryId);
