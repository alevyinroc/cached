CREATE TABLE [dbo].[attributes] (
    [attributeid]   INT          NOT NULL,
    [attributename] NVARCHAR(50) NOT NULL,
    CONSTRAINT [pk_attributes] PRIMARY KEY CLUSTERED ([attributeid] ASC)
);

