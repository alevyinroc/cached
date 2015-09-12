CREATE TABLE [dbo].[CenterPoints] (
    [Locationname] VARCHAR (20) NOT NULL,
    [Latitude]     DECIMAL(8, 6)   NULL,
    [Longitude]    DECIMAL(9, 6)   NULL,
    [latlong]      AS           ([geography]::Point([Latitude],[Longitude],(4326))) PERSISTED,
    CONSTRAINT [pk_centerpoints] PRIMARY KEY CLUSTERED ([Locationname] ASC)
);





