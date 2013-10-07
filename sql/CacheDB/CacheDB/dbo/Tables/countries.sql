CREATE TABLE [dbo].[countries] (
    [countryid] INT           NOT NULL,
    [name]      NVARCHAR (50) NULL,
    CONSTRAINT [pk_countries] PRIMARY KEY CLUSTERED ([countryid] ASC)
);

