USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound_response_log') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_outbound_response_log] (
        [mw_outbound_response_log_id]           BIGINT                  IDENTITY,
        [record_created_date]                   DATE,
        [record_created_datetime]               DATETIME2,
        [mw_outbound_id]                        NVARCHAR(50)            COLLATE DATABASE_DEFAULT,
        [sssb_conversation_handle]              UNIQUEIDENTIFIER, 
        [mw_outbound_destination_id]            NVARCHAR(50)            COLLATE DATABASE_DEFAULT,
        [uri]                                   NVARCHAR(200)           COLLATE DATABASE_DEFAULT,
        [wh_id]                                 NVARCHAR(10)            COLLATE DATABASE_DEFAULT,
        [message_type]                          NVARCHAR(200)           COLLATE DATABASE_DEFAULT,
        [order_type]                            NVARCHAR(200)           COLLATE DATABASE_DEFAULT, 
        [message_id]                            NVARCHAR(200)           COLLATE DATABASE_DEFAULT,
        [message]                               NVARCHAR(MAX)           COLLATE DATABASE_DEFAULT,
        [response_code]                         NVARCHAR(100)            COLLATE DATABASE_DEFAULT,
        [response]                              NVARCHAR(MAX)           COLLATE DATABASE_DEFAULT,
        [execution_time]                        BIGINT
        CONSTRAINT [pk_mw_outbound_response_log]         
            PRIMARY KEY ([mw_outbound_response_log_id])
    );

    CREATE INDEX [i_mw_outbound_response_log_date] 
        ON [dbo].[t_mw_outbound_response_log]([record_created_date]);

END
GO