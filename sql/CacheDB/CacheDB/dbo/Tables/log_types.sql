CREATE TABLE [dbo].[log_types] (
    [logtypeid]    INT           CONSTRAINT [DF_log_types_logtypeid] DEFAULT (NEXT VALUE FOR [logtypeid]) NOT NULL,
    [logtypedesc]  NVARCHAR (30) NOT NULL,
    [CountsAsFind] BIT           NOT NULL,
    CONSTRAINT [PK_LogTypes] PRIMARY KEY NONCLUSTERED ([logtypeid] ASC)
);



