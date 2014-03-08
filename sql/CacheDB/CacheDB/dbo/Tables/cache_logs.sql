CREATE TABLE [dbo].[cache_logs] (
    [cacheid] VARCHAR (8) NOT NULL,
    [logid]   BIGINT      NOT NULL,
    CONSTRAINT [pk_cache_logs] PRIMARY KEY CLUSTERED ([cacheid] ASC, [logid] ASC),
    CONSTRAINT [fk_log_cacheid] FOREIGN KEY ([cacheid]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [fk_log_logid] FOREIGN KEY ([logid]) REFERENCES [dbo].[logs] ([logid])
);


GO

CREATE INDEX [IX_cache_logs_logid] ON [dbo].[cache_logs] ([logid])
