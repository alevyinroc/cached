CREATE TABLE [dbo].[statuses] (
    [statusid]   INT          DEFAULT (NEXT VALUE FOR [statusid]) NOT NULL,
    [statusname] VARCHAR (12) NOT NULL,
    CONSTRAINT [pk_statuses] PRIMARY KEY CLUSTERED ([statusid] ASC)
);

