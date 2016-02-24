CREATE TABLE [dbo].[point_types] (
    [typeid]      INT           CONSTRAINT [DF_point_types_typeid] DEFAULT (NEXT VALUE FOR [pointtypeid]) NOT NULL,
    [typename]    NVARCHAR (30) NOT NULL,
    [GSAK_Lookup] CHAR (1)      CONSTRAINT [DF_PT_GSAKLUp] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PointType] PRIMARY KEY NONCLUSTERED ([typeid] ASC)
);



