CREATE TABLE [dbo].[Counties] (
    [CountyId]   INT           CONSTRAINT [DF_counties_typeid] DEFAULT (NEXT VALUE FOR [countyid]) NOT NULL,
    [CountyName] NVARCHAR (50) NOT NULL,
    [StateId]    INT           NOT NULL,
    CONSTRAINT [PK_Counties] PRIMARY KEY CLUSTERED ([CountyId] ASC, [StateId] ASC),
    CONSTRAINT [FK_Counties_State] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States] ([StateId])
);


