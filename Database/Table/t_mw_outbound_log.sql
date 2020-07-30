USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound_log') IS NULL
BEGIN

    CREATE TABLE [dbo].[t_mw_outbound_log] (
        [mw_outbound_log_id]                BIGINT               IDENTITY,
        [record_created_date]               DATE,
        [record_created_datetime]           DATETIME2,
        [destination_sssb_service]          NVARCHAR(50)         COLLATE DATABASE_DEFAULT,
        [mw_outbound_destination_id]        NVARCHAR(50)         COLLATE DATABASE_DEFAULT,
        [sssb_conversation_handle]          UNIQUEIDENTIFIER,
        [wh_id]                             NVARCHAR(10)         COLLATE DATABASE_DEFAULT,
        [message_type]                      NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [order_type]                        NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [message_id]                        NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [message]                           XML,
        CONSTRAINT [pk_mw_outbound_log]
            PRIMARY KEY ([mw_outbound_log_id])
    );

    CREATE INDEX [i_mw_outbound_log_date]
        ON [dbo].[t_mw_outbound_log]([record_created_date]);

END
GO