CREATE TABLE [dbo].[point_types] (
    [typeid]   INT          DEFAULT (NEXT VALUE FOR [pointtypeid]) NOT NULL,
    [typename] VARCHAR (30) NOT NULL,
    CONSTRAINT [pk_point_types] PRIMARY KEY CLUSTERED ([typeid] ASC)
);

