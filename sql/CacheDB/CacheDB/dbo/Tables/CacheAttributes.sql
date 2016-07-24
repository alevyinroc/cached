CREATE TABLE [dbo].[CacheAttributes](
	[CacheId] [varchar](8) NOT NULL,
	[AttributeId] [int] NOT NULL,
	[AttributeApplies] [bit] NULL,
 CONSTRAINT [PK_CacheAttributes] PRIMARY KEY NONCLUSTERED 
(
	[CacheId] ASC,
	[AttributeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CacheAttributes]  WITH CHECK ADD  CONSTRAINT [FK_AttrId] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[attributes] ([AttributeId])
GO

ALTER TABLE [dbo].[CacheAttributes] CHECK CONSTRAINT [FK_AttrId]
GO

ALTER TABLE [dbo].[CacheAttributes]  WITH CHECK ADD  CONSTRAINT [FK_CacheId] FOREIGN KEY([CacheId])
REFERENCES [dbo].[Caches] ([CacheId])
GO

ALTER TABLE [dbo].[CacheAttributes] CHECK CONSTRAINT [FK_CacheId]
GO

