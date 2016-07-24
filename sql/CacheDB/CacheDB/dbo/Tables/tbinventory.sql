CREATE TABLE [dbo].[TBInventory] (
    [CacheId]    VARCHAR (8) NOT NULL,
    [TBPublicId] VARCHAR (8) NOT NULL,
    CONSTRAINT [PK_TBInventory] PRIMARY KEY NONCLUSTERED ([CacheId] ASC, [TBPublicId] ASC),
    CONSTRAINT [FK_TBInventory_CacheId] FOREIGN KEY ([CacheId]) REFERENCES [dbo].[Caches] ([CacheId]),
    CONSTRAINT [FK_TBInventory_TBId] FOREIGN KEY ([TBPublicId]) REFERENCES [dbo].[TravelBugs] ([TBPublicId])
);




GO
CREATE NONCLUSTERED INDEX [IX_TBInventory_TBPublicId]
    ON [dbo].[TBInventory]([TBPublicId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TBInventory_CacheId]
    ON [dbo].[TBInventory]([CacheId] ASC);

