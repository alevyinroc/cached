CREATE TABLE [dbo].[cache_attributes] (
    [cacheid]           VARCHAR (8) NOT NULL,
    [attributeid]       INT         NOT NULL,
    [attribute_applies] BIT         DEFAULT ((1)) NULL,
    CONSTRAINT [fk_attr_cacheid] FOREIGN KEY ([cacheid]) REFERENCES [dbo].[caches] ([cacheid]),
    CONSTRAINT [fk_attr_id] FOREIGN KEY ([attributeid]) REFERENCES [dbo].[attributes] ([attributeid])
);

