USE [AAD]
GO
IF OBJECT_ID('dbo.t_mw_inbound_rules') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_inbound_rules] (
        [mw_inbound_id]                NVARCHAR(50)         COLLATE DATABASE_DEFAULT,
        [message_type]                 NVARCHAR(200)        COLLATE DATABASE_DEFAULT, 
        [order_type]                   NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [xml_schema_definition]        XML,
        [integration_proc]             NVARCHAR(256)        COLLATE DATABASE_DEFAULT,
        [reintegration_proc]           NVARCHAR(256)        COLLATE DATABASE_DEFAULT,
        [process_proc]                 NVARCHAR(256)        COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_inbound_rules]         
            PRIMARY KEY ([mw_inbound_id], [message_type], [order_type]),
        CONSTRAINT [fk_mw_inbound_rules] 
            FOREIGN KEY ([mw_inbound_id])
            REFERENCES [dbo].[t_mw_inbound] ([mw_inbound_id])
    );
END
GO
