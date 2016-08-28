CREATE TABLE [dbo].[CacheOwners](
	[CacheId] [varchar](8) NOT NULL,
	[CacherId] [int] NOT NULL,
 CONSTRAINT [PK_CacheOwners] PRIMARY KEY NONCLUSTERED 
(
	[CacheId] ASC,
	[CacherId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CacheOwners]   ADD  CONSTRAINT [FK_CacheOwners_CacheID] FOREIGN KEY([CacheId])
REFERENCES [dbo].[Caches] ([CacheId])
GO

ALTER TABLE [dbo].[CacheOwners] CHECK CONSTRAINT [FK_CacheOwners_CacheID]
GO

ALTER TABLE [dbo].[CacheOwners]   ADD  CONSTRAINT [FK_CacheOwners_CacherID] FOREIGN KEY([CacherId])
REFERENCES [dbo].[Cachers] ([CacherId])
GO

ALTER TABLE [dbo].[CacheOwners] CHECK CONSTRAINT [FK_CacheOwners_CacherID]
GO

