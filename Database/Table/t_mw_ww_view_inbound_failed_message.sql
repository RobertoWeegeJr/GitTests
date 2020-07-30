USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_ww_view_inbound_failed_message') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_ww_view_inbound_failed_message] (
        [ww_user_id]                          NVARCHAR(200)         COLLATE DATABASE_DEFAULT,
        [view_id]                             NVARCHAR(200)         COLLATE DATABASE_DEFAULT,
        [record_created_date]                 DATETIME2             DEFAULT      SYSDATETIME(),
        [mw_inbound_failed_message_id]        BIGINT,
        [selected]                            TINYINT               DEFAULT 0
    );

    CREATE INDEX i_mw_ww_view_inbound_failed_message_user
        ON [dbo].[t_mw_ww_view_inbound_failed_message] ([ww_user_id])

	CREATE INDEX i_mw_ww_view_inbound_failed_message_view
        ON [dbo].[t_mw_ww_view_inbound_failed_message] ([view_id])

END
GO
