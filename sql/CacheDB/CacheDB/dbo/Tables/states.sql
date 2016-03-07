CREATE TABLE [dbo].[States] (
    [StateId] INT           CONSTRAINT [DF_states_stateid] DEFAULT (NEXT VALUE FOR [StateId]) NOT NULL,
    [Name]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_States] PRIMARY KEY NONCLUSTERED ([StateId] ASC)
);



