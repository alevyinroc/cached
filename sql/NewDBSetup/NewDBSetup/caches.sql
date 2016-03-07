CREATE TABLE [dbo].[caches] (
    [cacheid]             VARCHAR (8)        NOT NULL,
    [gsid]                INT                NOT NULL,
    [cachename]           NVARCHAR (50)      NOT NULL,
    [latitude]            DECIMAL (8, 6)     NOT NULL,
    [longitude]           DECIMAL (9, 6)     NOT NULL,
    [lastupdated]         DATETIMEOFFSET (7) NOT NULL,
    [placed]              DATE               NOT NULL,
    [placedby]            NVARCHAR (50)      NOT NULL,
    [typeid]              INT                NOT NULL,
    [sizeid]              INT                NOT NULL,
    [difficulty]          FLOAT (53)         NOT NULL,
    [terrain]             FLOAT (53)         NOT NULL,
    [shortdesc]           NVARCHAR (2048)    NOT NULL,
    [longdesc]            NTEXT              NOT NULL,
    [hint]                NVARCHAR (1024)    NULL,
    [premiumonly]         BIT                NOT NULL,
    [cachestatus]         INT                NOT NULL,
    [created]             DATETIMEOFFSET (7) NOT NULL,
    [url]                 NVARCHAR (2038)    NULL,
    [urldesc]             NVARCHAR (200)     NULL,
    [CorrectedLatitude]   DECIMAL (8, 6)     NULL,
    [CorrectedLongitude]  DECIMAL (9, 6)     NULL,
    [CountryId]           INT                NULL,
    [StateId]             INT                NULL,
    [Elevation]           FLOAT (53)         NOT NULL,
    [NeedsExternalUpdate] BIT                NOT NULL,
    [latlong]             AS                 ([geography]::Point([latitude],[longitude],(4326))) PERSISTED NOT NULL,
    [Correctedlatlong]    AS                 ([geography]::Point(isnull([CorrectedLatitude],(0)),isnull([CorrectedLongitude],(0)),(4326))) PERSISTED,
	[CountyId] INT NULL,
    CONSTRAINT [PK_caches] PRIMARY KEY NONCLUSTERED ([cacheid] ASC),
    CONSTRAINT [FK_Caches_Countries] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Countries] ([CountryId]),
    CONSTRAINT [FK_Caches_PointType] FOREIGN KEY ([typeid]) REFERENCES [dbo].[point_types] ([typeid]),
    CONSTRAINT [FK_Caches_SizeId] FOREIGN KEY ([sizeid]) REFERENCES [dbo].[cache_sizes] ([sizeid]),
    CONSTRAINT [FK_Caches_StateId] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States] ([StateId]),
    CONSTRAINT [FK_Caches_StatusId] FOREIGN KEY ([cachestatus]) REFERENCES [dbo].[statuses] ([statusid]),
	CONSTRAINT [FK_Caches_CountyId] FOREIGN KEY([CountyId], [StateId]) REFERENCES [dbo].[Counties] ([CountyId], [StateId])
);



GO
CREATE NONCLUSTERED INDEX [IX_caches_statusid]
    ON [dbo].[caches]([cachestatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_caches_Stateid]
    ON [dbo].[caches]([StateId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_caches_pointtype]
    ON [dbo].[caches]([typeid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_caches_CountryId]
    ON [dbo].[caches]([CountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_caches_cachesize]
    ON [dbo].[caches]([sizeid] ASC);


GO
CREATE CLUSTERED INDEX [IX_CachePlaced]
    ON [dbo].[caches]([placed] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [caches_updated]
    ON [dbo].[caches]([lastupdated] ASC);

