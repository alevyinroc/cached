CREATE TABLE [dbo].[Counties]
(
	[CountyId] INT NOT NULL DEFAULT next value for CountyId, 
    [CountyName] NVARCHAR(50) NOT NULL, 
    [StateId] INT NOT NULL, 
	CONSTRAINT [PK_Counties] PRIMARY KEY CLUSTERED ([CountyId] ASC),
    CONSTRAINT [FK_Counties_States] FOREIGN KEY ([StateId]) REFERENCES [States]([StateId])
)
