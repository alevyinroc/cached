CREATE TABLE [dbo].[waypoints] (
    [waypointid]  VARCHAR (10)   NOT NULL,
    [parentcache] VARCHAR (8)    NOT NULL,
    [latitude]    FLOAT (53)     NOT NULL,
    [longitude]   FLOAT (53)     NOT NULL,
    [typeid]      INT            NOT NULL,
    [name]        VARCHAR (50)   NOT NULL,
    [description] VARCHAR (2000) NOT NULL,
    [url]         VARCHAR (2038) NOT NULL,
    [lookupcode]  NVARCHAR (6)   NULL,
    [latlong]     AS             ([geography]::Point([latitude],[longitude],(4326))) PERSISTED,
    [urldesc]     VARCHAR (200)  NOT NULL,
    CONSTRAINT [pk_waypoints] PRIMARY KEY CLUSTERED ([waypointid] ASC),
    CONSTRAINT [fk_waypoint_cacheid] FOREIGN KEY ([parentcache]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [fk_waypoint_type] FOREIGN KEY ([typeid]) REFERENCES [dbo].[point_types] ([typeid])
);

