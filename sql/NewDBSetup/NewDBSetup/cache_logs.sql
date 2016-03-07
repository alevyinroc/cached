CREATE TABLE [dbo].[cache_logs](
	[cacheid] [varchar](8) NOT NULL,
	[logid] [bigint] NOT NULL,
 CONSTRAINT [PK_CacheLogs] PRIMARY KEY NONCLUSTERED 
(
	[cacheid] ASC,
	[logid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[cache_logs]  WITH CHECK ADD  CONSTRAINT [FK_CacheLogs_LogID] FOREIGN KEY([logid])
REFERENCES [dbo].[logs] ([logid])
GO

ALTER TABLE [dbo].[cache_logs] CHECK CONSTRAINT [FK_CacheLogs_LogID]
GO

ALTER TABLE [dbo].[cache_logs]  WITH CHECK ADD  CONSTRAINT [FK_CLCacheID] FOREIGN KEY([cacheid])
REFERENCES [dbo].[caches] ([cacheid])
GO

ALTER TABLE [dbo].[cache_logs] CHECK CONSTRAINT [FK_CLCacheID]
GO
