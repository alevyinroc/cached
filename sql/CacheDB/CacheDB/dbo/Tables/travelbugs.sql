CREATE TABLE [dbo].[travelbugs] (
    [tbpublicid]   VARCHAR (8)  NOT NULL,
    [tbinternalid] INT          NOT NULL,
    [tbname]       VARCHAR (50) NOT NULL,
    CONSTRAINT [pk_travelbugs] PRIMARY KEY CLUSTERED ([tbpublicid] ASC)
);

