USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound_control') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_outbound_control] (
        [mw_outbound_id]        NVARCHAR(50)     COLLATE DATABASE_DEFAULT,
        [control_type]          NVARCHAR(200)    COLLATE DATABASE_DEFAULT,
        [value]                 NVARCHAR(500)    COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_outbound_control]         
            PRIMARY KEY ([mw_outbound_id], [control_type]),
        CONSTRAINT [fk_mw_outbound_control] 
            FOREIGN KEY ([mw_outbound_id])
            REFERENCES [dbo].[t_mw_outbound] ([mw_outbound_id])
    );        
END
GO