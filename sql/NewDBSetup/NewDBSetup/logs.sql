
CREATE TABLE [dbo].[logs](
	[logid] [bigint] NOT NULL,
	[logdate] [datetimeoffset](7) NOT NULL,
	[logtypeid] [int] NOT NULL,
	[cacherid] [int] NOT NULL,
	[logtext] [nvarchar](4000) NULL,
	[latitude] [decimal](8, 6) NULL,
	[longitude] [decimal](9, 6) NULL,
    [latlong]   AS              ([geography]::Point([latitude],[longitude],(4326))) PERSISTED,
 CONSTRAINT [PK_Logs] PRIMARY KEY NONCLUSTERED 
(
	[logid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[logs]  WITH CHECK ADD  CONSTRAINT [FK_Log_LogType] FOREIGN KEY([logtypeid])
REFERENCES [dbo].[log_types] ([logtypeid])
GO

ALTER TABLE [dbo].[logs] CHECK CONSTRAINT [FK_Log_LogType]
GO

ALTER TABLE [dbo].[logs]  WITH CHECK ADD  CONSTRAINT [FK_logs_cacherid] FOREIGN KEY([cacherid])
REFERENCES [dbo].[cachers] ([cacherid])
GO

ALTER TABLE [dbo].[logs] CHECK CONSTRAINT [FK_logs_cacherid]
GO

