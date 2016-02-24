CREATE TABLE [dbo].[statuses] (
    [statusid]   INT           CONSTRAINT [DF_statuses_statusid] DEFAULT (NEXT VALUE FOR [statusid]) NOT NULL,
    [statusname] NVARCHAR (12) NOT NULL,
    CONSTRAINT [PK_Statuses] PRIMARY KEY NONCLUSTERED ([statusid] ASC)
);



