USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_qa_inbound_process_01') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_qa_inbound_process_01];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_qa_inbound_process_01]
AS

SET NOCOUNT ON;

DECLARE

    @v_uiConversationHandle         UNIQUEIDENTIFIER,
    @v_sysMessageTypeName           SYSNAME,
    @v_vchMwInboundId               NVARCHAR(50),
    @v_vchMessageType               NVARCHAR(200),
    @v_vchOrderType                 NVARCHAR(200),
    @v_vchMessageId                 NVARCHAR(200),
    @v_xmlMessage                   XML,
    @v_vchProcessProc               NVARCHAR(256),
    @v_vchFailedMessageReason       NVARCHAR(200),

    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_qa_inbound_process_01';
    SET @c_nErrorLineOffSet = 7;

START_LABEL:

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
                FROM q_mw_inbound_process_01
            ), TIMEOUT 5000;

            IF (@@ROWCOUNT <= 0)
                BREAK;

        END TRY
        BEGIN CATCH
            SET @v_nSysErrorNum = ERROR_NUMBER();
            SET @v_vchCode = ERROR_LINE();
            SET @v_vchMsg = N'An error occureed while receiving data from q_mw_inbound_process_01';
            SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
            GOTO ERROR_HANDLER;
        END CATCH

        IF @v_sysMessageTypeName = N'm_mw_inbound'
        BEGIN

            SET @v_vchMwInboundId = NULL;
            SET @v_vchMessageType = NULL;
            SET @v_vchOrderType = NULL;
            SET @v_vchMessageId = NULL;
            SET @v_vchFailedMessageReason = NULL;
            SET @v_vchProcessProc = NULL;
            SET @v_vchCode = NULL;
            SET @v_vchMsg = NULL;

            BEGIN TRY

                SELECT @v_vchMwInboundId = t.c.value(N'@mwInboundId',    N'NVARCHAR(50)')
                      ,@v_vchMessageType = t.c.value(N'@messageType',    N'NVARCHAR(200)')
                      ,@v_vchOrderType =   t.c.value(N'@orderType',      N'NVARCHAR(200)')
                      ,@v_vchMessageId =   t.c.value(N'@messageId',      N'NVARCHAR(200)')
                 FROM @v_xmlMessage.nodes(N'/Inbound') t(c)

            END TRY
            BEGIN CATCH
                SET @v_nSysErrorNum = ERROR_NUMBER();
                SET @v_vchCode = ERROR_LINE();
                SET @v_vchMsg = N'An error occurred while getting log data from @v_xmlMessage.';
                SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
                GOTO ERROR_HANDLER;
            END CATCH

            BEGIN TRY

                SELECT @v_vchProcessProc = process_proc
                  FROM t_mw_inbound_rules
                 WHERE mw_inbound_id = @v_vchMwInboundId
                   AND message_type = @v_vchMessageType
                   AND order_type = @v_vchOrderType;

            END TRY
            BEGIN CATCH
                SET @v_nSysErrorNum = ERROR_NUMBER();
                SET @v_vchCode = ERROR_LINE();
                SET @v_vchMsg = N'An error occurred while querying t_mw_wcs_in_rules.';
                SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
                GOTO ERROR_HANDLER;
            END CATCH

            IF (@v_vchProcessProc IS NULL)
            BEGIN
                SET @v_vchFailedMessageReason = N'PROCESS_PROC_NOT_FOUND';
                SET @v_vchMsg = N'Process Proc not found for Message Type/Order Type.';
                GOTO FAILED_MESSAGE_HANDLER;
            END;

            BEGIN TRY

                EXECUTE @v_vchProcessProc
                    @v_vchMwInboundId,
                    @v_vchMessageType,
                    @v_vchOrderType,
                    @v_vchMessageId,
                    @v_xmlMessage,
                    @v_vchFailedMessageReason    OUTPUT,
                    @v_vchCode                   OUTPUT,
                    @v_vchMsg                    OUTPUT

            END TRY
            BEGIN CATCH
                SET @v_nSysErrorNum = ERROR_NUMBER();
                SET @v_vchCode = ERROR_LINE();
                SET @v_vchMsg = N'An error occurred while running ' + ISNULL(@v_vchProcessProc, '?') + '.';
                SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
                GOTO ERROR_HANDLER;
            END CATCH

            IF @@TRANCOUNT > 0
            BEGIN

                BEGIN TRY

                    ROLLBACK;

                    IF @v_vchFailedMessageReason IS NULL
                        SET @v_vchFailedMessageReason = N'OPEN_TRANSACTION_AFTER_PROC';

                END TRY
                BEGIN CATCH
                    SET @v_nSysErrorNum = ERROR_NUMBER();
                    SET @v_vchCode = ERROR_LINE();
                    SET @v_vchMsg = N'An error occurred executing rollback.';
                    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
                    GOTO ERROR_HANDLER;
                END CATCH

            END

            IF @v_vchCode <> N'SUCCESS' OR @v_vchFailedMessageReason IS NOT NULL
            BEGIN
                GOTO FAILED_MESSAGE_HANDLER;
            END;

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
        ELSE IF @v_sysMessageTypeName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
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

    END;

    GOTO EXIT_LABEL;

FAILED_MESSAGE_HANDLER:
    BEGIN TRY

        EXEC usp_mw_inbound_add_failed_message
            @v_vchMwInboundId,
            @v_vchMessageType,
            @v_vchOrderType,
            @v_vchMessageId,
            @v_xmlMessage,
            @v_vchFailedMessageReason,
            @v_vchMsg;

    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occurred while running usp_mw_inbound_add_failed_message.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

    BEGIN TRY

        SET @v_vchMsg = N'{"MWInbound-FailedMessage":' +
            N'{"MwInId:"'        + ISNULL(@v_vchMwInboundId, N'?')                + N'"},' +
            N'{"MsgType:"'       + ISNULL(@v_vchMessageType, N'?')                + N'"},' +
            N'{"OrdeType:"'      + ISNULL(@v_vchOrderType, N'?')                  + N'"},' +
            N'{"MsgId:"'         + ISNULL(@v_vchMessageId, N'?')                  + N'"},' +
            N'{"Reason:"'        + ISNULL(@v_vchFailedMessageReason, N'?')        + N'"},' +
            N'{"Details:"'       + ISNULL(@v_vchMsg, N'?')                        + N'"}}';

        EXEC usp_log_console_message 1, @v_vchMsg

    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occurred while logging to console.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

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

    GOTO START_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

    SET @v_vchMsg = N'Procedure: ' + ISNULL(@c_vchObjName, N'?') +
                    N': Sys Error ' + ISNULL(CONVERT(NVARCHAR(50), @v_nSysErrorNum), N'?') +
                    N': Line Number ' + ISNULL(CONVERT(NVARCHAR(50), CONVERT(INTEGER, @v_vchCode) + @c_nErrorLineOffSet), N'?') +
                    N': ' +  ISNULL(@v_vchMsg, N'?');

    --Begin a try/catch block to avoid losing the original error data if an exception occurs in error handler block.
    BEGIN TRY

        --Rollback if there are any open transactions.
        IF @@TRANCOUNT > 0
            ROLLBACK;

        --Just try to end the conversation to avoid problems with the Service Broker Queue.
        --If it has already ended, an exception will be thrown. For this reason, the catch block is empty.
        BEGIN TRY
            IF @v_uiConversationHandle IS NOT NULL
                END CONVERSATION @v_uiConversationHandle;
        END TRY    BEGIN CATCH    END CATCH

        --Try to insert the message to the failed messages table.
        IF @v_xmlMessage IS NOT NULL AND @v_sysMessageTypeName = N'm_mw_inbound'
        BEGIN
            EXEC usp_mw_inbound_add_failed_message
                @v_vchmwInboundId,
                @v_vchMessageType,
                @v_vchOrderType,
                @v_vchMessageId,
                @v_xmlMessage,
                @v_vchFailedMessageReason,
                @v_vchMsg;
        END

        --Log to console
        EXEC usp_log_console_message 1, @v_vchMsg;

    END TRY
    BEGIN CATCH

        --Concatenate the error handler exception.
        SET @v_vchMsg = @v_vchMsg + N' | Error handler: ' + ISNULL(ERROR_MESSAGE(), N'?');

        --Just try to log to console
        BEGIN TRY
            EXEC usp_log_console_message 1, @v_vchMsg;
        END TRY    BEGIN CATCH    END CATCH

    END CATCH;

    --Throw the error
    THROW 50000, @v_vchMsg, 1;

-----------------------------------------------------------------------------------
--                            Exit the Process
-----------------------------------------------------------------------------------
EXIT_LABEL:
    RETURN;
GO