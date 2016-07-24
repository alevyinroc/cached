CREATE TABLE [dbo].[Caches] (
    [CacheId]             VARCHAR (8)        NOT NULL,
    [GSId]                INT                NOT NULL,
    [CacheName]           NVARCHAR (50)      NOT NULL,
    [Latitude]            DECIMAL (8, 6)     NOT NULL,
    [Longitude]           DECIMAL (9, 6)     NOT NULL,
    [LastUpdated]         DATETIMEOFFSET (7) NOT NULL,
    [Placed]              DATE               NOT NULL,
    [PlacedBy]            NVARCHAR (50)      NOT NULL,
    [TypeId]              INT                NOT NULL,
    [SizeId]              INT                NOT NULL,
    [Difficulty]          FLOAT (53)         NOT NULL,
    [Terrain]             FLOAT (53)         NOT NULL,
    [ShortDesc]           NVARCHAR (2048)    NOT NULL,
    [LongDesc]            NTEXT              NOT NULL,
    [Hint]                NVARCHAR (1024)    NULL,
    [PremiumOnly]         BIT                NOT NULL,
    [CacheStatus]         INT                NOT NULL,
    [Created]             DATETIMEOFFSET (7) NOT NULL,
    [URL]                 NVARCHAR (2038)    NULL,
    [URLDesc]             NVARCHAR (200)     NULL,
    [CorrectedLatitude]   DECIMAL (8, 6)     NULL,
    [CorrectedLongitude]  DECIMAL (9, 6)     NULL,
    [CountryId]           INT                NULL,
    [StateId]             INT                NULL,
    [Elevation]           FLOAT (53)         NOT NULL,
    [NeedsExternalUpdate] BIT                NOT NULL,
    [LatLong]             AS                 ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED NOT NULL,
    [CorrectedLatLong]    AS                 ([geography]::Point(isnull([CorrectedLatitude],(0)),isnull([CorrectedLongitude],(0)),(4326))) PERSISTED,
	[CountyId] INT NULL,
    CONSTRAINT [PK_Caches] PRIMARY KEY NONCLUSTERED ([CacheId] ASC),
    CONSTRAINT [FK_Caches_Countries] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Countries] ([CountryId]),
    CONSTRAINT [FK_Caches_PointType] FOREIGN KEY ([TypeId]) REFERENCES [dbo].[PointTypes] ([PointTypeId]),
    CONSTRAINT [FK_Caches_SizeId] FOREIGN KEY ([SizeId]) REFERENCES [dbo].[CacheSizes] ([SizeId]),
    CONSTRAINT [FK_Caches_StateId] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States] ([StateId]),
    CONSTRAINT [FK_Caches_StatusId] FOREIGN KEY ([CacheStatus]) REFERENCES [dbo].[Statuses] ([StatusId]),
	CONSTRAINT [FK_Caches_CountyId] FOREIGN KEY([CountyId], [StateId]) REFERENCES [dbo].[Counties] ([CountyId], [StateId])
);



GO
CREATE NONCLUSTERED INDEX [IX_Caches_StatusId]
    ON [dbo].[Caches]([CacheStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Caches_StateId]
    ON [dbo].[Caches]([StateId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Caches_PointType]
    ON [dbo].[Caches]([TypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Caches_CountryId]
    ON [dbo].[Caches]([CountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Caches_CacheSize]
    ON [dbo].[Caches]([SizeId] ASC);


GO
CREATE CLUSTERED INDEX [IX_Caches_Placed]
    ON [dbo].[Caches]([Placed] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Caches_Updated]
    ON [dbo].[Caches]([LastUpdated] ASC);

