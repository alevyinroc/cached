CREATE TABLE [dbo].[cache_attributes](
	[cacheid] [varchar](8) NOT NULL,
	[attributeid] [int] NOT NULL,
	[attribute_applies] [bit] NULL,
 CONSTRAINT [PK_CacheAttributes] PRIMARY KEY NONCLUSTERED 
(
	[cacheid] ASC,
	[attributeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[cache_attributes]  WITH CHECK ADD  CONSTRAINT [FK_AttrId] FOREIGN KEY([attributeid])
REFERENCES [dbo].[attributes] ([attributeid])
GO

ALTER TABLE [dbo].[cache_attributes] CHECK CONSTRAINT [FK_AttrId]
GO

ALTER TABLE [dbo].[cache_attributes]  WITH CHECK ADD  CONSTRAINT [FK_CacheId] FOREIGN KEY([cacheid])
REFERENCES [dbo].[caches] ([cacheid])
GO

ALTER TABLE [dbo].[cache_attributes] CHECK CONSTRAINT [FK_CacheId]
GO

