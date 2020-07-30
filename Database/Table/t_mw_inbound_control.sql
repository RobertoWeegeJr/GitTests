USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_inbound_control') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_inbound_control] (
        [mw_inbound_id]         NVARCHAR(50)        COLLATE DATABASE_DEFAULT,
        [control_type]          NVARCHAR(200)       COLLATE DATABASE_DEFAULT,
        [value]                 NVARCHAR(500)       COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_inbound_control]
            PRIMARY KEY ([mw_inbound_id], [control_type]),
        CONSTRAINT [fk_mw_inbound_control] 
            FOREIGN KEY ([mw_inbound_id])
            REFERENCES [dbo].[t_mw_inbound] ([mw_inbound_id])
    );        
END
GO