USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_outbound') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_outbound];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_outbound]
    @in_vchWhId                    NVARCHAR(10),
    @in_vchMessageType             NVARCHAR(200),
    @in_vchOrderType               NVARCHAR(200),
    @in_xmlMessage                 XML
AS

SET NOCOUNT ON;

DECLARE

    @v_uiMessageId                      UNIQUEIDENTIFIER,
    @v_xmlMessage                       XML,
    @v_vchSssbDestinationService        NVARCHAR(256),
    @v_vchDestinationId                 NVARCHAR(50),
    @v_uiConversationHandle             UNIQUEIDENTIFIER,

    -- Error handling variables
    @v_nSysErrorNum             INTEGER,
    @v_vchCode                  uddt_output_code,
    @v_vchMsg                   uddt_output_msg,
    @c_vchObjName               uddt_obj_name,
    @c_nErrorLineOffSet         INTEGER,
    @v_nErrorNumber             INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_outbound';
    SET @c_nErrorLineOffSet = 7;

BEGIN TRANSACTION;

BEGIN TRY

    SELECT @v_vchSssbDestinationService = destination_sssb_service
          ,@v_vchDestinationId = mw_outbound_destination_id
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

    SET @v_uiMessageId = NEWID();

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while generating the message id.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SET @v_xmlMessage = (
        SELECT Outbound.destinationId
              ,Outbound.messageId
              ,Outbound.whId
              ,Outbound.messageType
              ,Outbound.orderType
              ,Host2KiSoft.messageID
          FROM
          (
            SELECT @v_vchDestinationId    AS destinationId
                  ,@v_uiMessageId         AS messageId
                  ,@in_vchWhId            AS whId
                  ,@in_vchMessageType     AS messageType
                  ,@in_vchOrderType       AS orderType
          ) AS Outbound
          CROSS JOIN
          (
            SELECT @v_uiMessageId         AS messageID
          ) AS Host2KiSoft
         FOR XML AUTO
    );


END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while building the xml message root.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SET @v_xmlMessage.modify('insert sql:variable("@in_xmlMessage") as first into (/Outbound/Host2KiSoft)[1]')

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while building the xml message.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    BEGIN DIALOG CONVERSATION @v_uiConversationHandle
     FROM SERVICE [s_mw_outbound_request_01]
       TO SERVICE @v_vchSssbDestinationService
       ON CONTRACT [c_mw_outbound_default]
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
    MESSAGE TYPE [m_mw_outbound] (@v_xmlMessage);

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while sending on conversation.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    INSERT INTO t_mw_outbound_log (
        destination_sssb_service,
        mw_outbound_destination_id,
        sssb_conversation_handle,
        wh_id,
        message_type,
        order_type,
        message_id,
        message
    ) VALUES (
        @v_vchSssbDestinationService,
        @v_vchDestinationId,
        @v_uiConversationHandle,
        @in_vchWhId,
        @in_vchMessageType,
        @in_vchOrderType,
        @v_uiMessageId,
        @v_xmlMessage
    );

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_mw_outbound_log.';
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