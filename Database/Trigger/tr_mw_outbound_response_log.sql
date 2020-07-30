USE [AAD]
GO

IF OBJECT_ID('dbo.tr_mw_outbound_response_log') IS NOT NULL
BEGIN
    DROP TRIGGER [dbo].[tr_mw_outbound_response_log];
END;
GO

CREATE TRIGGER [dbo].[tr_mw_outbound_response_log]
    ON [dbo].[t_mw_outbound_response_log]
INSTEAD OF INSERT AS
BEGIN

    DECLARE @v_dRecordCreatedDatetime DATETIME2 = SYSDATETIME();

    INSERT INTO [dbo].[t_mw_outbound_response_log]
    (
       [record_created_date],
       [record_created_datetime],
       [mw_outbound_id],
       [sssb_conversation_handle],
       [mw_outbound_destination_id],
       [uri],
       [wh_id],
       [message_type],
       [order_type],
       [message_id],
       [message],
       [response_code],
       [response],
       [execution_time]
    )
    SELECT CAST(@v_dRecordCreatedDatetime AS DATE)
          ,@v_dRecordCreatedDatetime
          ,[mw_outbound_id]
          ,[sssb_conversation_handle]
          ,[mw_outbound_destination_id]
          ,[uri]
          ,[wh_id]
          ,[message_type]
          ,[order_type]
          ,[message_id]
          ,[message]
          ,[response_code]
          ,[response]
          ,[execution_time]
      FROM inserted
END;
GO