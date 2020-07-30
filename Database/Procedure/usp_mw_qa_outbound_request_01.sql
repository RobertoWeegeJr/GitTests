USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_qa_outbound_request_01') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_qa_outbound_request_01];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_qa_outbound_request_01]
AS

SET NOCOUNT ON;

DECLARE

    @v_uiConversationHandle         UNIQUEIDENTIFIER,
    @v_xmlMessage                   XML,
    @v_sysMessageTypeName           SYSNAME,

    -- Error handling variables
    @v_nSysErrorNum                INTEGER,
    @v_vchCode                     uddt_output_code,
    @v_vchMsg                      uddt_output_msg,
    @c_vchObjName                  uddt_obj_name,
    @c_nErrorLineOffSet            INTEGER,
    @v_nErrorNumber                INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_qa_outbound_request_01';
    SET @c_nErrorLineOffSet = 7;

WHILE (1=1)
BEGIN

    SET @v_uiConversationHandle = NULL;
    SET @v_xmlMessage = NULL;
    SET @v_sysMessageTypeName = NULL;

    BEGIN TRY

        WAITFOR
        (
            RECEIVE TOP (1)
                @v_uiConversationHandle = conversation_handle,
                @v_xmlMessage = CAST(message_body AS XML),
                @v_sysMessageTypeName = message_type_name
            FROM q_mw_outbound_request_01
        ), TIMEOUT 5000;

        IF (@@ROWCOUNT <= 0)
            BREAK;

    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occureed while receiving data from q_mw_outbound_request_01.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

    IF @v_sysMessageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN

        BEGIN TRY
            END CONVERSATION @v_uiConversationHandle;
        END TRY
        BEGIN CATCH
            SET @v_nSysErrorNum = ERROR_NUMBER();
            SET @v_vchCode = ERROR_LINE();
            SET @v_vchMsg = N'An error occurred while ending conversation.';
            SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
            GOTO ERROR_HANDLER;
        END CATCH

    END
    ELSE
    BEGIN

        SET @v_nSysErrorNum = NULL;
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'Message type ' + ISNULL(@v_sysMessageTypeName, N'?') + ' is not expected.';
        GOTO ERROR_HANDLER;

    END

END

GOTO EXIT_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

    BEGIN TRY
        IF @v_uiConversationHandle IS NOT NULL
            END CONVERSATION @v_uiConversationHandle;
    END TRY    BEGIN CATCH    END CATCH

    SET @v_vchMsg = N'Procedure: ' + ISNULL(@c_vchObjName, N'?') +
                    N': Sys Error ' + ISNULL(CONVERT(NVARCHAR(50), @v_nSysErrorNum), N'?') +
                    N': Line Number ' + ISNULL(CONVERT(NVARCHAR(50), CONVERT(INTEGER, @v_vchCode) + @c_nErrorLineOffSet), N'?') +
                    N': ' +  ISNULL(@v_vchMsg, N'?');

    --Begin a try/catch block to avoid losing the original error data if an exception occurs in error handler block.
    BEGIN TRY

        --Log to console
        EXEC usp_log_console_message 1, @v_vchMsg;

    END TRY
    BEGIN CATCH
        --Concatenate the error handler exception.
        SET @v_vchMsg = @v_vchMsg + ' | Error handler: ' + ISNULL(ERROR_MESSAGE(), N'?');
    END CATCH;

    THROW 50000, @v_vchMsg, 1;

-----------------------------------------------------------------------------------
--                            Exit the Process
-----------------------------------------------------------------------------------
EXIT_LABEL:
    RETURN;
GO