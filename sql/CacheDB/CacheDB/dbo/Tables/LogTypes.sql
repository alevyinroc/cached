CREATE TABLE [dbo].[LogTypes] (
    [LogTypeId]    INT           CONSTRAINT [DF_LogTypes_LogTypeId] DEFAULT (NEXT VALUE FOR [LogTypeId]) NOT NULL,
    [LogTypeDesc]  NVARCHAR (30) NOT NULL,
    [CountsAsFind] BIT           NOT NULL,
    CONSTRAINT [PK_LogTypes] PRIMARY KEY CLUSTERED ([LogTypeId] ASC)
);



