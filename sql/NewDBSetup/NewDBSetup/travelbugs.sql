CREATE TABLE [dbo].[travelbugs] (
    [tbpublicid]   VARCHAR (8)   NOT NULL,
    [tbinternalid] INT           NOT NULL,
    [tbname]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Travelbugs] PRIMARY KEY NONCLUSTERED ([tbpublicid] ASC)
);



