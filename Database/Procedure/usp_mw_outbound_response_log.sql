USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_outbound_response_log') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_outbound_response_log];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_outbound_response_log]
    @in_vchmwOutboundId                     NVARCHAR(50),
    @in_vchSssbConversationHandle           UNIQUEIDENTIFIER,
    @in_vchOutboundDestinationId            NVARCHAR(50),
    @in_vchUri                              NVARCHAR(200),
    @in_vchWhId                             NVARCHAR(10),
    @in_vchMessageType                      NVARCHAR(200),
    @in_vchOrderType                        NVARCHAR(200),
    @in_vchMessageId                        NVARCHAR(200),
    @in_vchMessage                          NVARCHAR(MAX),
    @in_vchResponseCode                     NVARCHAR(100),
    @in_vchResponse                         NVARCHAR(MAX),
    @in_nExecutionTime                      INT
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
    SET @c_vchObjName = N'usp_mw_outbound_response_log';
    SET @c_nErrorLineOffSet = 7;

BEGIN TRY

    INSERT INTO t_mw_outbound_response_log (
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
    ) VALUES (
        @in_vchMwOutboundId,
        @in_vchSssbConversationHandle,
        @in_vchOutboundDestinationId,
        @in_vchUri,
        @in_vchWhId,
        @in_vchMessageType,
        @in_vchOrderType,
        @in_vchMessageId,
        @in_vchMessage,
        @in_vchResponseCode,
        @in_vchResponse,
        @in_nExecutionTime
    );

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_mw_outbound_response_log.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

GOTO EXIT_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

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

