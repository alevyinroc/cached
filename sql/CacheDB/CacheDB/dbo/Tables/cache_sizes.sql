CREATE TABLE [dbo].[cache_sizes] (
    [sizeid]   INT          NOT NULL,
    [sizename] VARCHAR (16) NULL,
    CONSTRAINT [pk_cache_sizes] PRIMARY KEY CLUSTERED ([sizeid] ASC)
);

