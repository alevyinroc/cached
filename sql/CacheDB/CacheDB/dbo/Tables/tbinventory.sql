CREATE TABLE [dbo].[tbinventory] (
    [cacheid]    VARCHAR (8) NOT NULL,
    [tbpublicid] VARCHAR (8) NOT NULL,
    CONSTRAINT [PK_TBInventory] PRIMARY KEY NONCLUSTERED ([cacheid] ASC, [tbpublicid] ASC),
    CONSTRAINT [FK_TBInventory_CacheId] FOREIGN KEY ([cacheid]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [FK_TBInventory_TBId] FOREIGN KEY ([tbpublicid]) REFERENCES [dbo].[travelbugs] ([tbpublicid])
);




GO
CREATE NONCLUSTERED INDEX [IX_tbinventory_tbpublicid]
    ON [dbo].[tbinventory]([tbpublicid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tbinventory_cacheid]
    ON [dbo].[tbinventory]([cacheid] ASC);

