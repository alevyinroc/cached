CREATE TABLE [dbo].[cachers] (
    [cacherid]   INT          NOT NULL,
    [cachername] NVARCHAR(50) NOT NULL,
    CONSTRAINT [pk_cachers] PRIMARY KEY CLUSTERED ([cacherid] ASC)
);


GO

CREATE INDEX [IX_cachers_CacherName] ON [dbo].[cachers] (cachername)
