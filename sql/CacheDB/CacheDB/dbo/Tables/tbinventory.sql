CREATE TABLE [dbo].[tbinventory] (
    [cacheid]    VARCHAR (8) NOT NULL,
    [tbpublicid] VARCHAR (8) NOT NULL,
    CONSTRAINT [pk_tbinventory] PRIMARY KEY CLUSTERED ([cacheid] ASC, [tbpublicid] ASC),
    CONSTRAINT [fk_cacheid] FOREIGN KEY ([cacheid]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [fk_tb_id] FOREIGN KEY ([tbpublicid]) REFERENCES [dbo].[travelbugs] ([tbpublicid])
);

