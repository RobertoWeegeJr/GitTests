USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_outbound_reprocess') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_outbound_reprocess];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_outbound_reprocess]
    @in_vchTranGroupID                  NVARCHAR(30),
    @in_vchWwUserId                     NVARCHAR(200),
    @in_vchMwOutboundFailedMessageId    BIGINT,
    @in_vchWhId                         NVARCHAR(10),
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
    @v_vchSssbDestinationService    NVARCHAR(256),
    
    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_outbound_reprocess';
    SET @c_nErrorLineOffSet = 7;

    SET @v_dStartDate = GETDATE();

BEGIN TRANSACTION

BEGIN TRY

    SELECT @v_vchSssbDestinationService = destination_sssb_service
      FROM t_mw_outbound_rules
     WHERE wh_id = @in_vchWhId
       AND message_type = @in_vchMessageType
       AND order_type = @in_vchOrderType;

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while querying t_mw_outbound_rules.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    BEGIN DIALOG CONVERSATION @v_uiConversationHandle
     FROM SERVICE [s_mw_outbound_request_01]
       TO SERVICE @v_vchSssbDestinationService
       ON CONTRACT [c_mw_outbound_reprocess]
     WITH ENCRYPTION = OFF ;

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
    MESSAGE TYPE [m_mw_outbound] (@in_xmlMessage);

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
        control_number,     --mw_outbound_failed_message_id
        wh_id,
        generic_text1,      --message_type
        generic_text2,      --order_type
        generic_text3,      --message_id
        generic_text4,      --sssb_destination_service
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
          ,log.mw_outbound_failed_message_id                  AS control_number
          ,log.wh_id                                          AS wh_id
          ,log.message_type                                   AS generic_text1
          ,log.order_type                                     AS generic_text2
          ,log.message_id                                     AS generic_text3
          ,log.sssb_destination_service                       AS generic_text4
          ,log.conversation_handle                            AS generic_text5
      FROM (
            SELECT @in_vchMwOutboundFailedMessageId     AS mw_outbound_failed_message_id
                  ,@in_vchWhId                          AS wh_id
                  ,@in_vchMessageType                   AS message_type
                  ,@in_vchOrderType                     AS order_type
                  ,@in_vchMessageId                     AS message_id
                  ,@v_vchSssbDestinationService         AS sssb_destination_service
                  ,@v_uiConversationHandle              AS conversation_handle
      ) log
      LEFT JOIN t_transaction trn
             ON trn.system_id = 'WA'
            AND trn.tran_type = '732';

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
