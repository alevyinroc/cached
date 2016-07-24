CREATE TABLE [dbo].[CacheSizes] (
    [SizeId]   INT          CONSTRAINT [DF_cachesizes_sizeid] DEFAULT (NEXT VALUE FOR [CacheSizeId]) NOT NULL,
    [SizeName] VARCHAR (16) NULL,
    CONSTRAINT [PK_CacheSizes] PRIMARY KEY NONCLUSTERED ([SizeId] ASC)
);



