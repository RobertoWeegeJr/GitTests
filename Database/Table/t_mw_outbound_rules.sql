USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound_rules') IS NULL
BEGIN
    CREATE TABLE [dbo].[t_mw_outbound_rules] (
        [wh_id]                             NVARCHAR(10)         COLLATE DATABASE_DEFAULT,
        [message_type]                      NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [order_type]                        NVARCHAR(200)        COLLATE DATABASE_DEFAULT,
        [destination_sssb_service]          NVARCHAR(128)        COLLATE DATABASE_DEFAULT,
        [mw_outbound_destination_id]        NVARCHAR(50)         COLLATE DATABASE_DEFAULT,
        [reprocess_proc]                    NVARCHAR(128)        COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_outbound_rules]
            PRIMARY KEY ([wh_id], [message_type], [order_type])
    );
END
GO