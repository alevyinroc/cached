CREATE TABLE [dbo].[cache_sizes] (
    [sizeid]   INT          NOT NULL DEFAULT Next value for CacheSizeId,
    [sizename] VARCHAR (16) NULL,
    CONSTRAINT [pk_cache_sizes] PRIMARY KEY CLUSTERED ([sizeid] ASC)
);

