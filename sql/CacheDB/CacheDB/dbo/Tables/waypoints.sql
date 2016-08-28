CREATE TABLE [dbo].[waypoints] (
    [WaypointId]  VARCHAR (10)       NOT NULL,
    [ParentCache] VARCHAR (8)        NOT NULL,
    [Latitude]    DECIMAL (8, 6)     NOT NULL,
    [Longitude]   DECIMAL (9, 6)     NOT NULL,
    [TypeId]      INT                NOT NULL,
    [Name]        NVARCHAR (50)      NOT NULL,
    [Description] NVARCHAR (2000)    NOT NULL,
    [URL]         NVARCHAR (2038)    NOT NULL,
    [URLDesc]     NVARCHAR (200)     NOT NULL,
    [LastUpdated] DATETIMEOFFSET (7) NULL,
	[Created]     DATETIMEOFFSET (7) NULL,
    [LatLong]     AS                 ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
    CONSTRAINT [PK_Waypoints] PRIMARY KEY NONCLUSTERED ([WaypointId] ASC),
    CONSTRAINT [FK_Waypoints_Cacheid] FOREIGN KEY ([ParentCache]) REFERENCES [dbo].[Caches] ([CacheId]),
    CONSTRAINT [FK_Waypoints_Typeid] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[PointTypes] ([PointTypeId])
);
GO
CREATE CLUSTERED INDEX [IX_WPUpdated]
    ON [dbo].[Waypoints]([Created] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Waypoints_TypeId]
    ON [dbo].[Waypoints]([TypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Waypoints_ParentCache]
    ON [dbo].[Waypoints]([ParentCache] ASC);

