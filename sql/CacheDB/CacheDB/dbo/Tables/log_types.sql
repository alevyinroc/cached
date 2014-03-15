CREATE TABLE [dbo].[log_types] (
    [logtypeid]   INT          DEFAULT (NEXT VALUE FOR [logtypeid]) NOT NULL,
    [logtypedesc] NVARCHAR(30) NOT NULL,
    [CountsAsFind] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [pk_log_types] PRIMARY KEY CLUSTERED ([logtypeid] ASC)
);

