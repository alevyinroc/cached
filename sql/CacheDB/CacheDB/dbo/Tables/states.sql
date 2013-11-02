CREATE TABLE [dbo].[States] (
    [StateId] INT           NOT NULL DEFAULT next value for StateId,
    [Name]    NVARCHAR (50) NULL,
    CONSTRAINT [pk_states] PRIMARY KEY CLUSTERED ([StateId] ASC)
);

