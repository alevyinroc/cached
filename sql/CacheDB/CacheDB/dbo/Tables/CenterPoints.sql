CREATE TABLE [dbo].[CenterPoints](
	[LocationName] [varchar](20) NOT NULL,
	[Latitude] [decimal](8, 6) NULL,
	[Longitude] [decimal](9, 6) NULL,
    [LatLong]      AS           ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
 CONSTRAINT [PK_CenterPoints] PRIMARY KEY CLUSTERED 
(
	[LocationName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]