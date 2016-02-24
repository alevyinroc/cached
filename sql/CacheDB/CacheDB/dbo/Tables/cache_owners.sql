CREATE TABLE [dbo].[cache_owners](
	[cacheid] [varchar](8) NOT NULL,
	[cacherid] [int] NOT NULL,
 CONSTRAINT [PK_CacherOwners] PRIMARY KEY NONCLUSTERED 
(
	[cacheid] ASC,
	[cacherid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[cache_owners]  WITH CHECK ADD  CONSTRAINT [FK_CacheOwners_CacheID] FOREIGN KEY([cacheid])
REFERENCES [dbo].[caches] ([cacheid])
GO

ALTER TABLE [dbo].[cache_owners] CHECK CONSTRAINT [FK_CacheOwners_CacheID]
GO

ALTER TABLE [dbo].[cache_owners]  WITH CHECK ADD  CONSTRAINT [FK_CacheOwners_CacherID] FOREIGN KEY([cacherid])
REFERENCES [dbo].[cachers] ([cacherid])
GO

ALTER TABLE [dbo].[cache_owners] CHECK CONSTRAINT [FK_CacheOwners_CacherID]
GO

