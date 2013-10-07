CREATE TABLE [dbo].[CenterPoints] (
    [Locationname] VARCHAR (20)      NOT NULL,
    [LocationGeo]  [sys].[geography] NOT NULL,
    CONSTRAINT [pk_centerpoints] PRIMARY KEY CLUSTERED ([Locationname] ASC)
);

