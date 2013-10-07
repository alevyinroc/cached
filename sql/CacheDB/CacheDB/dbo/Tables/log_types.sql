CREATE TABLE [dbo].[log_types] (
    [logtypeid]   INT          DEFAULT (NEXT VALUE FOR [logtypeid]) NOT NULL,
    [logtypedesc] VARCHAR (30) NOT NULL,
    CONSTRAINT [pk_log_types] PRIMARY KEY CLUSTERED ([logtypeid] ASC)
);

