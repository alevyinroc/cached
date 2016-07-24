CREATE TABLE [dbo].[cachers] (
    [CacherId]   INT           NOT NULL,
    [CacherName] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_CacherId] PRIMARY KEY CLUSTERED ([CacherId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IX_CacherName]
    ON [dbo].[Cachers]([CacherName] ASC)
    INCLUDE([CacherId]);

