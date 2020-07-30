USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_inbound_integrator_failed_message') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_inbound_integrator_failed_message];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_inbound_integrator_failed_message]
    @in_vchmwInboundId            NVARCHAR(50),
    @in_vchMessageType            NVARCHAR(200),
    @in_vchOrderType              NVARCHAR(200),
    @in_vchMessageId              NVARCHAR(200),
    @in_xmlMessage                XML,
    @in_vchReason                 NVARCHAR(200),
    @in_vchDetails                NVARCHAR(MAX)
AS

SET NOCOUNT ON;

DECLARE

    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_inbound_integrator_failed_message';
    SET @c_nErrorLineOffSet = 7;

BEGIN TRANSACTION

BEGIN TRY

    INSERT INTO t_mw_inbound_failed_message (
        mw_inbound_id,
        message_type,
        order_type,
        message_id,
        message,
        reason,
        details
    ) VALUES (
        @in_vchmwInboundId,
        @in_vchMessageType,
        @in_vchOrderType,
        @in_vchMessageId,
        @in_xmlMessage,
        ISNULL(@in_vchReason, 'UNKNOWN'),
        @in_vchDetails
    );

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_mw_inbound_failed_message.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    INSERT INTO t_mw_inbound_log (
        mw_inbound_id,
        message_type,
        order_type,
        message_id,
        message
    ) VALUES (
        @in_vchMwInboundId,
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
    RETURN;
GO

