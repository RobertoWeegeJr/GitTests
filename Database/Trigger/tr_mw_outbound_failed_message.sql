USE [AAD]
GO

IF OBJECT_ID('dbo.tr_mw_outbound_failed_message') IS NOT NULL
BEGIN
    DROP TRIGGER [dbo].[tr_mw_outbound_failed_message];
END;
GO

CREATE TRIGGER [dbo].[tr_mw_outbound_failed_message]
    ON [dbo].[t_mw_outbound_failed_message]
INSTEAD OF INSERT AS
BEGIN

    DECLARE @v_dRecordCreatedDatetime DATETIME2 = SYSDATETIME();

    INSERT INTO [dbo].[t_mw_outbound_failed_message]
    (
        [record_created_date],
        [record_created_datetime],
        [mw_outbound_id],
        [wh_id],
        [message_type],
        [order_type],
        [message_id],
        [message],
        [status],
        [reason],
        [details]
    )
    SELECT CAST(@v_dRecordCreatedDatetime AS DATE)
          ,@v_dRecordCreatedDatetime
          ,[mw_outbound_id]
          ,[wh_id]
          ,[message_type]
          ,[order_type]
          ,[message_id]
          ,[message]
          ,[status]
          ,[reason]
          ,[details]
      FROM inserted
END;
GO

