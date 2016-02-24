CREATE TABLE [dbo].[cache_owners] (
    [cacheid]  VARCHAR (8) NOT NULL,
    [cacherid] INT         NULL,
    CONSTRAINT [pk_cache_owners] PRIMARY KEY CLUSTERED ([cacheid] ASC),
    CONSTRAINT [fk_owner_cacheid] FOREIGN KEY ([cacheid]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [fk_owner_cacher] FOREIGN KEY ([cacherid]) REFERENCES [dbo].[cachers] ([cacherid])
);

