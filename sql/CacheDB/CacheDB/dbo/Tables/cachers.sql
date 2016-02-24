CREATE TABLE [dbo].[cachers] (
    [cacherid]   INT           NOT NULL,
    [cachername] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_CacherId] PRIMARY KEY CLUSTERED ([cacherid] ASC)
);




GO
CREATE NONCLUSTERED INDEX [ix_cachername]
    ON [dbo].[cachers]([cachername] ASC)
    INCLUDE([cacherid]);

