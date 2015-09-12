CREATE TABLE [dbo].[logs] (
    [logid]     BIGINT          NOT NULL,
    [logdate]   DATETIMEOFFSET        NOT NULL,
    [logtypeid] INT             NOT NULL,
    [cacherid]  INT             NOT NULL,
    [logtext]   NVARCHAR (4000) NULL,
    [latitude]  DECIMAL(8, 6)      NULL,
    [longitude] DECIMAL(9, 6)      NULL,
    [latlong]   AS              ([geography]::Point([latitude],[longitude],(4326))) PERSISTED,
    CONSTRAINT [pk_logs] PRIMARY KEY CLUSTERED ([logid] ASC),
    CONSTRAINT [fk_cacher] FOREIGN KEY ([cacherid]) REFERENCES [dbo].[cachers] ([cacherid]),
    CONSTRAINT [fk_logtype] FOREIGN KEY ([logtypeid]) REFERENCES [dbo].[log_types] ([logtypeid])
);


GO

CREATE INDEX [IX_logs_cacherid] ON [dbo].[logs] (cacherid)
