CREATE TABLE [dbo].[states] (
    [stateid] INT           NOT NULL,
    [name]    NVARCHAR (50) NULL,
    CONSTRAINT [pk_states] PRIMARY KEY CLUSTERED ([stateid] ASC)
);

