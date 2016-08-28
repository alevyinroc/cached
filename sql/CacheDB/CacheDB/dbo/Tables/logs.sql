
CREATE TABLE [dbo].[Logs](
	[LogId] [bigint] NOT NULL,
	[LogDate] [datetimeoffset](7) NOT NULL,
	[LogTypeId] [int] NOT NULL,
	[CacherId] [int] NOT NULL,
	[LogText] [nvarchar](4000) NULL,
	[Latitude] [decimal](8, 6) NULL,
	[Longitude] [decimal](9, 6) NULL,
    [LatLong]   AS              ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
 CONSTRAINT [PK_Logs] PRIMARY KEY NONCLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Logs] ADD  CONSTRAINT [FK_Log_LogType] FOREIGN KEY([LogTypeId])
REFERENCES [dbo].[LogTypes] ([LogTypeId])
GO

ALTER TABLE [dbo].[Logs] CHECK CONSTRAINT [FK_Log_LogType]
GO

ALTER TABLE [dbo].[Logs] ADD  CONSTRAINT [FK_Logs_CacherId] FOREIGN KEY([CacherId])
REFERENCES [dbo].[Cachers] ([CacherId])
GO
