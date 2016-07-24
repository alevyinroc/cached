CREATE TABLE [dbo].[TravelBugs] (
    [TBPublicId]   VARCHAR (8)   NOT NULL,
    [TBInternalId] INT           NOT NULL,
    [TBName]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TravelBugs] PRIMARY KEY NONCLUSTERED ([TBPublicId] ASC)
);



