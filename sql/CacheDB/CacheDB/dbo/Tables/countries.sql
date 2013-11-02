CREATE TABLE [dbo].[Countries] (
    [CountryId] INT           NOT NULL DEFAULT next value for CountryId,
    [Name]      NVARCHAR (50) NULL,
    CONSTRAINT [pk_countries] PRIMARY KEY CLUSTERED ([CountryId] ASC)
);

