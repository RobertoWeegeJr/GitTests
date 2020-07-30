USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_inbound') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_inbound] (
        [mw_inbound_id]                 NVARCHAR(50)        COLLATE DATABASE_DEFAULT,
        [description]                   NVARCHAR(500)       COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_inbound]    
            PRIMARY KEY ([mw_inbound_id])
    );    
END
GO