CREATE TABLE [dbo].[PointTypes] (
    [PointTypeId]      INT           CONSTRAINT [DF_PointTypes_PointTypeId] DEFAULT (NEXT VALUE FOR [pointtypeid]) NOT NULL,
    [PointTypeName]    NVARCHAR (30) NOT NULL,
    [GSAK_Lookup] CHAR (1)      CONSTRAINT [DF_PT_GSAKLUp] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PointTypes] PRIMARY KEY NONCLUSTERED ([PointTypeId] ASC)
);



