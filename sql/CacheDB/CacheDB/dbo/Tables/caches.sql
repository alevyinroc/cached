﻿CREATE TABLE [dbo].[caches] (
	[cacheid] VARCHAR(8) NOT NULL
	,[gsid] INT NOT NULL
	,[cachename] NVARCHAR(50) NOT NULL
	,[latitude] DECIMAL(8, 6) NOT NULL
	,[longitude] DECIMAL(9, 6) NOT NULL
	,[lastupdated] DATETIMEOFFSET(7) DEFAULT(SYSDATETIMEOFFSET()) NOT NULL
	,[placed] DATE NOT NULL
	,[placedby] NVARCHAR(50) NOT NULL
	,[typeid] INT NOT NULL
	,[sizeid] INT NOT NULL
	,[difficulty] FLOAT(53) NOT NULL
	,[terrain] FLOAT(53) NOT NULL
	,[shortdesc] NVARCHAR(2048) NOT NULL
	,[longdesc] NTEXT NOT NULL
	,[hint] NVARCHAR(1024) NULL
	,[available] BIT DEFAULT((1)) NOT NULL
	,[archived] BIT DEFAULT((0)) NOT NULL
	,[premiumonly] BIT DEFAULT((0)) NOT NULL
	,[cachestatus] INT DEFAULT((1)) NOT NULL
	,[created] DATETIMEOFFSET DEFAULT(SYSDATETIMEOFFSET()) NOT NULL
	,[url] NVARCHAR(2038) NULL
	,[urldesc] NVARCHAR(200) NULL
	,[CorrectedLatitude] DECIMAL(8, 6) NULL
	,[CorrectedLongitude] DECIMAL(9, 6) NULL
	,[CountryId] INT NULL
	,[StateId] INT NULL
	,[CorrectedLatLong] AS ([geography]::Point(isnull([CorrectedLatitude], (0)), isnull([CorrectedLongitude], (0)), (4326))) PERSISTED
	,[latlong] AS ([geography]::Point([latitude], [longitude], (4326))) PERSISTED
	,[Elevation] FLOAT DEFAULT(0) NOT NULL
	,[NeedsExternalUpdate] BIT DEFAULT(1) NOT NULL
	,CONSTRAINT [pk_caches] PRIMARY KEY CLUSTERED ([cacheid] ASC)
	,CONSTRAINT [fk_cache_size] FOREIGN KEY ([sizeid]) REFERENCES [dbo].[cache_sizes]([sizeid])
	,CONSTRAINT [fk_cache_status] FOREIGN KEY ([cachestatus]) REFERENCES [dbo].[statuses]([statusid])
	,CONSTRAINT [fk_cache_type] FOREIGN KEY ([typeid]) REFERENCES [dbo].[point_types]([typeid])
	,CONSTRAINT [FK_caches_Country] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Countries]([CountryId])
	,CONSTRAINT [FK_caches_State] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States]([StateId])
	);
