CREATE TABLE [dbo].[statuses] (
    [statusid]   INT          DEFAULT (NEXT VALUE FOR [statusid]) NOT NULL,
    [statusname] NVARCHAR(12) NOT NULL,
    CONSTRAINT [pk_statuses] PRIMARY KEY CLUSTERED ([statusid] ASC)
);

