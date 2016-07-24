CREATE TABLE [dbo].[Statuses] (
    [StatusId]   INT           CONSTRAINT [DF_Statuses_StatusId] DEFAULT (NEXT VALUE FOR [StatusId]) NOT NULL,
    [StatusName] NVARCHAR (12) NOT NULL,
    CONSTRAINT [PK_Statuses] PRIMARY KEY NONCLUSTERED ([StatusId] ASC)
);



