CREATE TABLE [dbo].[point_types] (
    [typeid]   INT          DEFAULT (NEXT VALUE FOR [pointtypeid]) NOT NULL,
    [typename] NVARCHAR(30) NOT NULL,
    CONSTRAINT [pk_point_types] PRIMARY KEY CLUSTERED ([typeid] ASC)
);

