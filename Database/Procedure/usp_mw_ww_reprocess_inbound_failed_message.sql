USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_ww_reprocess_inbound_failed_message') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_ww_reprocess_inbound_failed_message];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_ww_reprocess_inbound_failed_message]
    @in_vchWwUserId            NVARCHAR(200),
    @in_vchViewId              NVARCHAR(200),
    @in_chProcessAll           NCHAR(1),
    @out_vchMsg                uddt_output_msg        OUTPUT,
    @ww_result                 uddt_output_code       OUTPUT
AS

SET NOCOUNT ON;

DECLARE

    @v_nCounter                         INT,

    @v_vchProcessProc                   NVARCHAR(256),
    @v_vchMwInboundFailedMessageId      BIGINT,
    @v_vchMwInboundId                   NVARCHAR(50),
    @v_vchMessageType                   NVARCHAR(200),
    @v_vchOrderType                     NVARCHAR(200),
    @v_vchMessageId                     NVARCHAR(200),
    @v_xmlMessage                       XML,

    @v_vchTranGroupID                   NVARCHAR(30),

    -- Error handling variables
    @v_nSysErrorNum             INTEGER,
    @v_vchCode                  uddt_output_code,
    @v_vchMsg                   uddt_output_msg,
    @c_vchObjName               uddt_obj_name,
    @c_nErrorLineOffSet         INTEGER,
    @v_nErrorNumber             INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_ww_reprocess_inbound_failed_message';
    SET @c_nErrorLineOffSet = 7;
    SET @ww_result = N'FAIL';

DECLARE c_failed_messages CURSOR FOR
    SELECT ifm.mw_inbound_failed_message_id
          ,ifm.mw_inbound_id
          ,ifm.message_type
          ,ifm.order_type
          ,ifm.message_id
          ,ifm.message
          ,mir.reintegration_proc
      FROM t_mw_inbound_failed_message ifm
     INNER JOIN t_mw_ww_view_inbound_failed_message viw
        ON viw.mw_inbound_failed_message_id = ifm.mw_inbound_failed_message_id
      LEFT JOIN t_mw_inbound_rules mir
        ON mir.mw_inbound_id = ifm.mw_inbound_id
       AND mir.message_type = ifm.message_type
       AND mir.order_type = ifm.order_type
     WHERE ifm.status IN ('N', 'E')
       AND (@in_chProcessAll = 'Y' OR viw.selected = 1)
       AND viw.view_id = @in_vchViewId
     ORDER BY ifm.mw_inbound_failed_message_id;

BEGIN TRY

    EXEC usp_get_next_value
            @in_vchType        = N'TRAN_GROUP_ID',
            @out_nUID          = @v_vchTranGroupID    OUTPUT,
            @out_nErrorNumber  = @v_nErrorNumber OUTPUT,
            @out_vchLogMsg     = @v_vchMsg         OUTPUT;

    IF @v_vchMsg <> 'SUCCESS'
    BEGIN
        SET @v_vchMsg = (N'ERROR CODE [' + ISNULL(CAST(@v_vchCode AS NVARCHAR(10)), '?') + N'] ' +
                        @v_vchMsg);

        THROW 50000, @v_vchMsg, 1;
    END

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occured executing usp_get_next_value_range.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    OPEN c_failed_messages;

    FETCH NEXT FROM c_failed_messages
     INTO @v_vchMwInboundFailedMessageId
         ,@v_vchMwInboundId
         ,@v_vchMessageType
         ,@v_vchOrderType
         ,@v_vchMessageId
         ,@v_xmlMessage
         ,@v_vchProcessProc;

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while opening c_failed_messages.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

WHILE @@FETCH_STATUS = 0
BEGIN

    BEGIN TRY

        UPDATE t_mw_inbound_failed_message
           SET status = 'P'
         WHERE mw_inbound_failed_message_id = @v_vchMwInboundFailedMessageId
           AND status IN ('N', 'E');

        SET @v_nCounter = @@ROWCOUNT

    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occurred while updating t_mw_inbound_failed_message.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

    IF (@v_nCounter > 0)
    BEGIN

        BEGIN TRY

            EXECUTE @v_vchProcessProc
                @v_vchTranGroupID,
                @in_vchWwUserId,
                @v_vchMwInboundFailedMessageId,
                @v_vchMwInboundId,
                @v_vchMessageType,
                @v_vchOrderType,
                @v_vchMessageId,
                @v_xmlMessage;

        END TRY
        BEGIN CATCH
            SET @v_nSysErrorNum = ERROR_NUMBER();
            SET @v_vchCode = ERROR_LINE();
            SET @v_vchMsg = N'An error occurred while executing ' + ISNULL(@v_vchProcessProc, '?') + '.';
            SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
            GOTO ERROR_HANDLER_SENDING_ERROR;
        END CATCH

        BEGIN TRY

            UPDATE t_mw_inbound_failed_message
               SET status = 'C'
             WHERE mw_inbound_failed_message_id = @v_vchMwInboundFailedMessageId
               AND status = 'P';

        END TRY
        BEGIN CATCH
            SET @v_nSysErrorNum = ERROR_NUMBER();
            SET @v_vchCode = ERROR_LINE();
            SET @v_vchMsg = N'An error occurred while updating t_mw_inbound_failed_message.';
            SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
            GOTO ERROR_HANDLER;
        END CATCH

    END

    BEGIN TRY

        FETCH NEXT FROM c_failed_messages
         INTO @v_vchMwInboundFailedMessageId
             ,@v_vchMwInboundId
             ,@v_vchMessageType
             ,@v_vchOrderType
             ,@v_vchMessageId
             ,@v_xmlMessage
             ,@v_vchProcessProc;

    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occurred while fetching next from c_failed_messages.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

END

BEGIN TRY

    CLOSE c_failed_messages;
    DEALLOCATE c_failed_messages;

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while closing c_failed_messages.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

SET @v_vchCode = 'SUCCESS';
SET @ww_result = N'PASS';

GOTO EXIT_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER_SENDING_ERROR:

    BEGIN TRY

        UPDATE t_mw_inbound_failed_message
           SET status = 'E'
         WHERE mw_inbound_failed_message_id = @v_vchMwInboundFailedMessageId
           AND status = 'P';

    END TRY
    BEGIN CATCH
        SET @v_vchMsg = @v_vchMsg + ' | Error handler: ' + ISNULL(ERROR_MESSAGE(), N'?');
    END CATCH

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

    IF CURSOR_STATUS('global','c_failed_messages') >= -1 BEGIN
        IF CURSOR_STATUS('global','c_failed_messages') > -1 BEGIN
            CLOSE c_failed_messages
        END
        DEALLOCATE c_failed_messages
    END

    SET @v_vchMsg = N'Procedure: ' + ISNULL(@c_vchObjName, N'?') +
                    N': Sys Error ' + ISNULL(CONVERT(NVARCHAR(50), @v_nSysErrorNum), N'?') +
                    N': Line Number ' + ISNULL(CONVERT(NVARCHAR(50), CONVERT(INTEGER, @v_vchCode) + @c_nErrorLineOffSet), N'?') +
                    N': ' +  ISNULL(@v_vchMsg, N'?');

    BEGIN TRY

        --Log to console
        EXEC usp_log_console_message 1, @v_vchMsg;

    END TRY
    BEGIN CATCH
        --Concatenate the error handler exception.
        SET @v_vchMsg = @v_vchMsg + ' | Error handler: ' + ISNULL(ERROR_MESSAGE(), N'?');
    END CATCH;

-----------------------------------------------------------------------------------
--                            Exit the Process
-----------------------------------------------------------------------------------
EXIT_LABEL:
    SET @out_vchMsg = @v_vchMsg;
    RETURN;
GO
