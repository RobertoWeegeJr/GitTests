USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_inbound_01') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_inbound_01];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_inbound_01]
    @in_vchMwInboundId            NVARCHAR(50),
    @in_vchMessageType            NVARCHAR(200),
    @in_vchOrderType              NVARCHAR(200),
    @in_vchMessageId              NVARCHAR(200),
    @in_xmlMessage                XML,
    @out_vchValidationCode        NVARCHAR(200) OUTPUT,
    @out_vchValidationMessage     NVARCHAR(MAX) OUTPUT
AS

SET NOCOUNT ON;

DECLARE

    @v_vchValidationCode            NVARCHAR(200),
    @v_vchValidationMessage         NVARCHAR(MAX),
    @v_uiConversationHandle         UNIQUEIDENTIFIER,

    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_inbound_01';
    SET @c_nErrorLineOffSet = 7;

BEGIN TRY

    EXEC usp_mw_inbound_validate_message_id 
        @in_vchMessageId,
        @v_vchValidationCode    OUTPUT,
        @v_vchValidationMessage OUTPUT
        
END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while running usp_mw_inbound_validate_message_id.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

IF @v_vchValidationCode IS NOT NULL
    GOTO EXIT_LABEL;
    
BEGIN TRANSACTION

BEGIN TRY

    BEGIN DIALOG CONVERSATION @v_uiConversationHandle
     FROM SERVICE [s_mw_inbound_request_01]
       TO SERVICE 's_mw_inbound_process_01'
       ON CONTRACT [c_mw_inbound_default]
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

    INSERT INTO t_mw_inbound_log (
        mw_inbound_id,
        sssb_conversation_handle,
        message_type,
        order_type,
        message_id,
        message
    ) VALUES (
        @in_vchMwInboundId,
        @v_uiConversationHandle,
        @in_vchMessageType,
        @in_vchOrderType,
        @in_vchMessageId,
        @in_xmlMessage
    );

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_mw_wcs_in_log.';
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
    SET @out_vchValidationCode = @v_vchValidationCode;
    SET @out_vchValidationMessage = @v_vchValidationMessage;
    RETURN;
GO
