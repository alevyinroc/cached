CREATE TABLE [dbo].[CenterPoints] (
    [Locationname] VARCHAR (20) NOT NULL,
    [Latitude]     FLOAT (53)   NULL,
    [Longitude]    FLOAT (53)   NULL,
    [latlong]      AS           ([geography]::Point([latitude],[longitude],(4326))) PERSISTED,
    CONSTRAINT [pk_centerpoints] PRIMARY KEY CLUSTERED ([Locationname] ASC)
);





