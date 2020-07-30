USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_inbound_integrated_message_id') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_inbound_integrated_message_id] (
        [message_id]                   NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [record_created_datetime]      DATETIME2            DEFAULT SYSDATETIME()
        CONSTRAINT [pk_mw_inbound_integrated_message_id]    
            PRIMARY KEY ([message_id])
    );    
END
GO