CREATE TABLE [dbo].[waypoints] (
    [waypointid]  VARCHAR (10)       NOT NULL,
    [parentcache] VARCHAR (8)        NOT NULL,
    [latitude]    DECIMAL (8, 6)     NOT NULL,
    [longitude]   DECIMAL (9, 6)     NOT NULL,
    [typeid]      INT                NOT NULL,
    [name]        NVARCHAR (50)      NOT NULL,
    [description] NVARCHAR (2000)    NOT NULL,
    [url]         NVARCHAR (2038)    NOT NULL,
    [urldesc]     NVARCHAR (200)     NOT NULL,
    [LastUpdated] DATETIMEOFFSET (7) NULL,
[Created] DATETIMEOFFSET (7) NULL,
    [latlong]     AS                 ([geography]::Point([latitude],[longitude],(4326))) PERSISTED,
    CONSTRAINT [pk_waypoints] PRIMARY KEY CLUSTERED ([waypointid] ASC),
    CONSTRAINT [fk_waypoint_cacheid] FOREIGN KEY ([parentcache]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [fk_waypoint_type] FOREIGN KEY ([typeid]) REFERENCES [dbo].[point_types] ([typeid])
);



