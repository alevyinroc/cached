CREATE TABLE [dbo].[Countries] (
    [CountryId] INT           CONSTRAINT [DF_Countries_CountryId] DEFAULT (NEXT VALUE FOR [countryid]) NOT NULL,
    [Name]      NVARCHAR (50) NULL,
    CONSTRAINT [PC_Countries] PRIMARY KEY CLUSTERED ([CountryId] ASC)
);



