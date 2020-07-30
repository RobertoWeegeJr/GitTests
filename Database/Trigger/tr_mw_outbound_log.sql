USE [AAD]
GO

IF OBJECT_ID('dbo.tr_mw_outbound_log') IS NOT NULL
BEGIN
    DROP TRIGGER [dbo].[tr_mw_outbound_log];
END;
GO

CREATE TRIGGER [dbo].[tr_mw_outbound_log]
    ON [dbo].[t_mw_outbound_log]
INSTEAD OF INSERT AS
BEGIN

    DECLARE @v_dRecordCreatedDatetime DATETIME2 = SYSDATETIME();

    INSERT INTO [dbo].[t_mw_outbound_log]
    (
        [record_created_date],
        [record_created_datetime],
        [destination_sssb_service],
        [mw_outbound_destination_id],
        [sssb_conversation_handle],
        [wh_id],
        [message_type],
        [order_type],
        [message_id],
        [message]
    )
    SELECT CAST(@v_dRecordCreatedDatetime AS DATE)
          ,@v_dRecordCreatedDatetime
          ,[destination_sssb_service]
          ,[mw_outbound_destination_id]
          ,[sssb_conversation_handle]
          ,[wh_id]
          ,[message_type]
          ,[order_type]
          ,[message_id]
          ,[message]
      FROM inserted
END;
GO


