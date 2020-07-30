USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_inbound_reprocess_01') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_inbound_reprocess_01];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_inbound_reprocess_01]
    @in_vchTranGroupID                  NVARCHAR(30),
    @in_vchWwUserId                     NVARCHAR(200),
    @in_vchMwInboundFailedMessageId     BIGINT,
    @in_vchMwInboundId                  NVARCHAR(50),
    @in_vchMessageType                  NVARCHAR(200),
    @in_vchOrderType                    NVARCHAR(200),
    @in_vchMessageId                    NVARCHAR(200),
    @in_xmlMessage                      XML
AS

SET NOCOUNT ON;

DECLARE

    @v_dStartDate                   DATETIME2,
    @v_dEndDate                     DATETIME2,
    @v_uiConversationHandle         UNIQUEIDENTIFIER,

    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_inbound_reprocess_01';
    SET @c_nErrorLineOffSet = 7;

    SET @v_dStartDate = GETDATE();

BEGIN TRANSACTION

BEGIN TRY

    MERGE t_mw_inbound_integrated_message_id imi
    USING (SELECT @in_vchMessageId AS message_id) AS mid
       ON mid.message_id = imi.message_id
     WHEN NOT MATCHED THEN
          INSERT (message_id)
          VALUES (mid.message_id)
     WHEN MATCHED THEN
          UPDATE SET imi.record_created_datetime = GETDATE();

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while merging into t_mw_inbound_integrated_message_id.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    BEGIN DIALOG CONVERSATION @v_uiConversationHandle
     FROM SERVICE [s_mw_inbound_request_01]
       TO SERVICE 's_mw_inbound_process_01'
       ON CONTRACT [c_mw_inbound_reprocess]
     WITH ENCRYPTION = OFF;

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while beginning the dialog conversation.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SEND ON CONVERSATION @v_uiConversationHandle
    MESSAGE TYPE [m_mw_inbound] (@in_xmlMessage);

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while sending on conversation.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SET @v_dEndDate = GETDATE();

    INSERT INTO t_tran_log_holding (
        tran_group_id,
        tran_type,
        description,
        start_tran_date,
        start_tran_time,
        end_tran_date,
        end_tran_time,
        elapsed_time,
        employee_id,
        wh_id,
        control_number,     --mw_inbound_failed_message_id
        generic_text1,      --mw_inbound_id
        generic_text2,      --message_type
        generic_text3,      --order_type
        generic_text4,      --message_id
        generic_text5       --conversation_handler
    )
    SELECT @in_vchTranGroupID
          ,trn.tran_type
          ,trn.description
          ,CAST(@v_dStartDate AS DATE)                        AS start_tran_date
          ,CAST(@v_dStartDate AS TIME)                        AS start_tran_time
          ,CAST(@v_dEndDate AS DATE)                          AS end_tran_date
          ,CAST(@v_dEndDate AS TIME)                          AS end_tran_time
          ,DATEDIFF(ss, @v_dStartDate, @v_dEndDate)           AS elapsed_time
          ,RIGHT(@in_vchWwUserId, 10)                         AS employee_id
          ,ISNULL(wmi.wh_id, '-')                             AS wh_id
          ,log.mw_inbound_failed_message_id                   AS control_number
          ,log.mw_inbound_id                                  AS generic_text1
          ,log.message_type                                   AS generic_text2
          ,log.order_type                                     AS generic_text3
          ,log.message_id                                     AS generic_text4
          ,@v_uiConversationHandle                            AS generic_text5
      FROM (
            SELECT @in_vchMwInboundFailedMessageId     AS mw_inbound_failed_message_id
                  ,@in_vchMwInboundId                  AS mw_inbound_id
                  ,@in_vchMessageType                  AS message_type
                  ,@in_vchOrderType                    AS order_type
                  ,@in_vchMessageId                    AS message_id
      ) log
      LEFT JOIN t_whse_mw_inbound wmi
        ON wmi.mw_inbound_id = log.mw_inbound_id
      LEFT JOIN t_transaction trn
             ON trn.system_id = 'WA'
            AND trn.tran_type = '730';

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_tran_log_holding.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

COMMIT;
GOTO EXIT_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

    IF @@TRANCOUNT > 0
        ROLLBACK;

    SET @v_vchMsg = N'Procedure: ' + ISNULL(@c_vchObjName, N'?') +
                    N': Sys Error ' + ISNULL(CONVERT(NVARCHAR(50), @v_nSysErrorNum), N'?') +
                    N': Line Number ' + ISNULL(CONVERT(NVARCHAR(50), CONVERT(INTEGER, @v_vchCode) + @c_nErrorLineOffSet), N'?') +
                    N': ' +  ISNULL(@v_vchMsg, N'?');

    THROW 50000, @v_vchMsg, 1;

-----------------------------------------------------------------------------------
--                            Exit the Process
-----------------------------------------------------------------------------------
EXIT_LABEL:
    RETURN;
GO
