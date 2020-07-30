USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_inbound_failed_message') IS NULL    
BEGIN
    
    CREATE TABLE [dbo].[t_mw_inbound_failed_message] (
        [mw_inbound_failed_message_id]        BIGINT              IDENTITY,
        [record_created_date]                 DATE,
        [record_created_datetime]             DATETIME2,
        [mw_inbound_id]                       NVARCHAR(50)        COLLATE DATABASE_DEFAULT,
        [message_type]                        NVARCHAR(200)       COLLATE DATABASE_DEFAULT,
        [order_type]                          NVARCHAR(200)       COLLATE DATABASE_DEFAULT, 
        [message_id]                          NVARCHAR(200)       COLLATE DATABASE_DEFAULT, 
        [message]                             XML,
        [status]                              NCHAR(1)            DEFAULT 'N',
        [reason]                              NVARCHAR(200)       COLLATE DATABASE_DEFAULT, 
        [details]                             NVARCHAR(MAX)       COLLATE DATABASE_DEFAULT, 
        CONSTRAINT [pk_mw_inbound_failed_message]         
            PRIMARY KEY ([mw_inbound_failed_message_id])
    );
    
    CREATE INDEX [i_mw_inbound_failed_message]
        ON [t_mw_inbound_failed_message] ([record_created_date], [status])
    
END;
GO
