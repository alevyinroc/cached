﻿CREATE TABLE Attributes (aCode text, aId integer, aInc integer);
CREATE TABLE CacheImages

  (iCode text default '' not null, iName iCode text default '' not null, iDescription iCode text default '' not null,

  iGuid text default '' not null,iImage text default '' not null);
CREATE TABLE CacheMemo (Code text default "" not null,LongDescription text default "" not null, ShortDescription text default "" not null,

Url text default "" not null,Hints text default "" not null,UserNote text default "" not null,TravelBugs text default "" not null);
CREATE TABLE Caches

  (Code text default '' not null, Name text default '' not null, Distance real default 0.00 not null, PlacedBy text default '' not null, Archived integer default 0 not null,

   Bearing text default '' not null, CacheId text default '1' not null, CacheType text default 'O' not null, Changed text default current_date not null,

   Container text default 'Unknown' not null, County text default '' not null, Country text default '' not null, Degrees real default 0.00 not null,

   Difficulty real default  1.0 not null, DNF integer default  0 not null, DNFDate text default '' not null, Found integer default  0 not null,

   FoundCount integer default  0 not null, FoundByMeDate text default  '' not null, FTF integer default  0 not null, HasCorrected integer default  0 not null,

   HasTravelBug integer default  0 not null, HasUserNote integer default 0 not null, LastFoundDate text default '' not null, 

   LastGPXDate text default '' not null, LastLog text default '' not null, LastUserDate text default current_date  not null, Latitude text default '0.0' not null,

   Lock integer default 0 not null,LongHtm integer default 0 not null, Longitude text default '0.0' not null, MacroFlag integer default 0 not null,

   MacroSort text default '' not null, NumberOfLogs integer default 0 not null, OwnerId text default '' not null, OwnerName text default '' not null,

   PlacedDate text default current_date not null, ShortHtm integer default 0 not null, SmartName text default '' not null,SmartOverride integer default 0 not null, 

   Source text default '' not null, State text default '' not null, Symbol text default '' not null, TempDisabled integer default 0 not null, 

   Terrain real default 1.0 not null, UserData text default '' not null, User2 text default '' not null, User3 text default '' not null, 

   User4 text default '' not null, UserFlag integer default 0 not null, UserNoteDate text default  '' not null, UserSort integer default 0 not null,

   Watch integer default 0 not null, IsOwner integer default 0 not null, LatOriginal text default '0.0' not null, LonOriginal text default '0.0' not null,

   Created text default current_date not null, Status text default 'A' not null, Color text default '' not null, ChildLoad integer default 0 not null,

   LinkedTo text default '' not null, GetPolyFlag integer default 0 not null,  Elevation real default 0.0 not null,Resolution text default '' not null, GcNote text default '' not null, IsPremium Integer default 0 not null, Guid text default '' not null, FavPoints Integer default 0 not null);
CREATE TABLE Corrected (kCode not null,kBeforeLat , kBeforeLon , kBeforeState, kBeforeCounty, kAfterLat,kAfterLon,kAfterState, kAftercounty);
CREATE TABLE Custom (cCode text default "" not null primary key);
CREATE TABLE CustomCheck (cData text default "" not null );
CREATE TABLE CustomLocal (fname text primary key, ftype text, fsequence integer, fdefault text, fcontrol text, fheight integer);
CREATE TABLE Filter (Ftype text, fCode text);
CREATE TABLE Ignore (iCode text, iName text);
CREATE TABLE LogImages

  (iCode text default '' not null, iLogid Integer default 0, iName text default '' not null, iDescription iCode text default '' not null,

  iGuid text default '' not null, iImage text default '' not null);
CREATE TABLE LogMemo (lParent ,lLogId integer, lText default "");
CREATE TABLE Logs (lParent not null,lLogId integer not null, lType, lBy, lDate date, lLat, lLon, lEncoded boolean, lownerid integer, lHasHtml boolean, lIsowner boolean, lTime text);
CREATE TABLE Recalc (rCode text primary key);
CREATE TABLE WayMemo (cParent,cCode,cComment default "", cUrl default "");
CREATE TABLE Waypoints (cParent not null,cCode not null, cPrefix, cName, cType, cLat, cLon, cByuser boolean, cDate date, cFlag boolean, sB1 boolean);
CREATE VIEW AttName as select aCode,aId,g_attributename(aid) as aName,aInc from attributes;
CREATE VIEW CachesAll as select *,Caches.rowid as rowid from Caches left join cachememo on Caches.code = cachememo.code left join custom on Caches.code = custom.ccode;
CREATE VIEW LogsAll as select *,logs.rowid as rowid from logs left join logmemo on logs.lparent = logmemo.lparent and logs.llogid = logmemo.llogid;
CREATE VIEW WayAll as select *,waypoints.rowid as rowid from Waypoints left join waymemo on waypoints.cparent = waymemo.cparent and waypoints.ccode = waymemo.ccode;
CREATE INDEX CacheImagesI1 on CacheImages (iCode);
CREATE UNIQUE INDEX CachesCode on  caches (Code);
CREATE INDEX LogImagesI1 on LogImages (iCode,iLogId);
CREATE UNIQUE INDEX acode on attributes (aCode,aId);
CREATE INDEX cachessmart on caches (smartname collate gsaknocase);
CREATE UNIQUE INDEX corcode on  corrected (kcode);
CREATE UNIQUE INDEX icode on Ignore (iCode);
CREATE INDEX [idx_CacheType] ON [Caches] ([CacheType]);
CREATE UNIQUE INDEX [idx_GCCode_PK] ON [Caches] ([Code]);
CREATE INDEX [idx_LastFoundDate] ON [Caches] ([LastFoundDate]);
CREATE INDEX [idx_LastGPXDate] ON [Caches] ([LastGPXDate]);
CREATE INDEX [idx_PlacedDate] ON [Caches] ([PlacedDate]);
CREATE INDEX [idx_Status] ON [Caches] ([Status]);
CREATE UNIQUE INDEX logParent on  logmemo (lParent,lLogId);
CREATE UNIQUE INDEX logkey on logs (lparent,llogid);
CREATE UNIQUE INDEX memocode on  cachememo (code);
CREATE UNIQUE INDEX wayParent on  waymemo (cParent,cCode);
CREATE UNIQUE INDEX waykey on waypoints (cparent,ccode);
CREATE TRIGGER Add_Caches Insert ON Caches

BEGIN

INSERT into Custom (ccode) values(new.code); 

END;
CREATE TRIGGER Delete_Caches Delete ON Caches

BEGIN

delete from logs where lparent = old.code;

delete from waypoints where cparent = old.code;

delete from CacheMemo where code = old.code;

delete from Attributes where acode = old.code;

delete from Custom where ccode = old.code;

delete from CacheImages where iCode = old.code;

END;
CREATE TRIGGER Delete_Logs Delete ON Logs

BEGIN

delete from logmemo where lparent = old.lparent and llogid = old.llogid ;

delete from LogImages where iCode = old.lparent and ilogid = old.llogid ;

END;
CREATE TRIGGER Delete_Waypoints Delete ON Waypoints

BEGIN

delete from waymemo where cparent = old.cparent and ccode = old.ccode;

END;
CREATE TRIGGER Name_RemoveCrlf after UPDATE OF Name ON Caches

Begin

	Update Caches set name = replace(name,g_chr(10),'') where code = old.code and new.name <> old.name;

	Update Caches set name = replace(name,g_chr(13),'') where code = old.code and new.name <> old.name;

END;
CREATE TRIGGER Update_Caches_Code UPDATE OF Code ON Caches

BEGIN

UPDATE logs SET lparent = new.code WHERE lparent = old.code and new.code <> lparent;

UPDATE waypoints SET cparent = new.code WHERE cparent = old.code and new.code <> cparent;

UPDATE Cachememo SET code = new.code WHERE code = old.code and new.code <> code;

UPDATE or replace Corrected SET kcode = new.code WHERE kcode = old.code and new.code <> kcode;

UPDATE attributes SET acode = new.code WHERE acode = old.code and new.code <> acode;

UPDATE custom SET ccode = new.code WHERE ccode = old.code and new.code <> ccode;

UPDATE CacheImages SET icode = new.code WHERE icode = old.code and new.code <> iCode;

UPDATE LogImages SET icode = new.code WHERE icode = old.code and new.code <> iCode;

END;
CREATE TRIGGER Update_Logs_lLogId UPDATE OF lLogId ON Logs

BEGIN

UPDATE logmemo SET llogid = new.llogid WHERE lparent = old.lparent and llogid = old.llogid and new.llogid <> llogid;

UPDATE LogImages SET ilogid = new.llogid WHERE iCode = old.lparent and iLogId = old.llogid and new.llogid <> iLogId;

END;
CREATE TRIGGER Update_Logs_lParent UPDATE OF lparent ON Logs

BEGIN

UPDATE logmemo SET lparent = new.lparent WHERE lparent = old.lparent and new.lparent <> lparent;

UPDATE LogImages SET iCode = new.lparent WHERE iCode = old.lparent and new.lparent <> iCode;

END;
CREATE TRIGGER Update_Waypoints_cCode UPDATE OF ccode ON Waypoints

BEGIN

UPDATE waymemo SET ccode = new.ccode WHERE cparent = old.cparent and ccode = old.ccode and new.ccode <> ccode;

END;
CREATE TRIGGER Update_Waypoints_cParent UPDATE OF cparent ON Waypoints

BEGIN

UPDATE waymemo SET cparent = new.cparent WHERE cparent = old.cparent and new.cparent <> cparent;

END;
