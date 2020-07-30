USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_ww_report_outbound_log') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_ww_report_outbound_log];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_ww_report_outbound_log]
    @in_vchWwUserLocaleId           INT,
    @in_vchStartDateTime            NVARCHAR(100),
    @in_vchEndDateTime              NVARCHAR(100),
    @in_vchDestinationSssbService   NVARCHAR(50),
    @in_vchMwOutboundDestinationId  NVARCHAR(50),
    @in_vchSssbConversationHandle   NVARCHAR(200),
    @in_vchWhId                     NVARCHAR(10),
    @in_vchMessageType              NVARCHAR(200),
    @in_vchOrderType                NVARCHAR(200),
    @in_vchMessageId                NVARCHAR(200),
    @in_vchMessage                  NVARCHAR(MAX)
AS

SET NOCOUNT ON;

DECLARE

    @v_dStartDate               DATE,
    @v_dEndDate                 DATE,
    @v_dStartDateTime           DATETIME2,
    @v_dEndDateTime             DATETIME2,

    @v_vchSqlQuery              NVARCHAR(MAX),
    @v_vchParamsList            NVARCHAR(MAX),

    -- Error handling variables
    @v_nSysErrorNum            INTEGER,
    @v_vchCode                 uddt_output_code,
    @v_vchMsg                  uddt_output_msg,
    @c_vchObjName              uddt_obj_name,
    @c_nErrorLineOffSet        INTEGER,
    @v_nErrorNumber            INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_ww_report_outbound_log';
    SET @c_nErrorLineOffSet = 7;

BEGIN TRY

    SET @v_dStartDateTime = dbo.usf_format_date_to_glb_locale(@in_vchWwUserLocaleId, @in_vchStartDateTime);
    SET @v_dStartDate = CAST(@v_dStartDateTime AS DATE);

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while casting start date.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SET @v_dEndDateTime = dbo.usf_format_date_to_glb_locale(@in_vchWwUserLocaleId, @in_vchEndDateTime);
    SET @v_dEndDateTime = DATEADD(nanosecond, 999999900, @v_dEndDateTime);
    SET @v_dEndDate = CAST(@v_dEndDateTime AS DATE);

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while casting end date.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SET @v_vchSqlQuery =
    'DECLARE
        @v_dStartDate                   DATE            = @in_dStartDate,
        @v_dEndDate                     DATE            = @in_dEndDate,
        @v_dStartDateTime               DATETIME2       = @in_dStartDateTime,
        @v_dEndDateTime                 DATETIME2       = @in_dEndDateTime,
        @v_vchDestinationSssbService    NVARCHAR(50)    = @in_vchDestinationSssbService,
        @v_vchMwOutboundDestinationId   NVARCHAR(50)    = @in_vchMwOutboundDestinationId,
        @v_vchSssbConversationHandle    NVARCHAR(200)   = @in_vchSssbConversationHandle,
        @v_vchWhId                      NVARCHAR(10)    = @in_vchWhId,
        @v_vchMessageType               NVARCHAR(200)   = @in_vchMessageType,
        @v_vchOrderType                 NVARCHAR(200)   = @in_vchOrderType,
        @v_vchMessageId                 NVARCHAR(200)   = @in_vchMessageId,
        @v_vchMessage                   NVARCHAR(MAX)   = @in_vchMessage

    SELECT mw_outbound_log_id, record_created_date, record_created_datetime, destination_sssb_service, mw_outbound_destination_id, sssb_conversation_handle, wh_id, message_type, order_type, message_id, message
       FROM t_mw_outbound_log
      WHERE record_created_date BETWEEN @v_dStartDate AND @v_dEndDate
        AND record_created_datetime BETWEEN @v_dStartDateTime AND @v_dEndDateTime';

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while setting @v_vchSqlQuery.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    SET @v_vchParamsList =
    '@in_dStartDate                  DATE,
     @in_dEndDate                    DATE,
     @in_dStartDateTime              DATETIME2,
     @in_dEndDateTime                DATETIME2,
     @in_vchDestinationSssbService   NVARCHAR(50),
     @in_vchMwOutboundDestinationId  NVARCHAR(50),
     @in_vchSssbConversationHandle   NVARCHAR(200),
     @in_vchWhId                     NVARCHAR(10),
     @in_vchMessageType              NVARCHAR(200),
     @in_vchOrderType                NVARCHAR(200),
     @in_vchMessageId                NVARCHAR(200),
     @in_vchMessage                  NVARCHAR(MAX)'

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while setting @v_vchParamsList.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    IF @in_vchDestinationSssbService <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND destination_sssb_service LIKE @v_vchDestinationSssbService'; 
 
    IF @in_vchMwOutboundDestinationId <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND mw_outbound_destination_id LIKE @v_vchMwOutboundDestinationId';
    
    IF @in_vchSssbConversationHandle <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND sssb_conversation_handle LIKE @v_vchSssbConversationHandle';
    
    IF @in_vchWhId <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND wh_id LIKE @v_vchWhId';

    IF @in_vchMessageType <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND message_type LIKE @v_vchMessageType';

    IF @in_vchOrderType <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND order_type LIKE @v_vchOrderType';

    IF @in_vchMessageId <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND message_id LIKE @v_vchMessageId';

    IF @in_vchMessage <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND CAST(message AS NVARCHAR(MAX)) LIKE @v_vchMessage';


    SET @v_vchSqlQuery = @v_vchSqlQuery + ' ORDER BY record_created_datetime';

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while setting query clauses.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    EXEC sp_executesql
        @v_vchSqlQuery,
        @v_vchParamsList,
        @in_dStartDate                  = @v_dStartDate,
        @in_dEndDate                    = @v_dEndDate,
        @in_dStartDateTime              = @v_dStartDateTime,
        @in_dEndDateTime                = @v_dEndDateTime,
        @in_vchDestinationSssbService   = @in_vchDestinationSssbService,
        @in_vchMwOutboundDestinationId  = @in_vchMwOutboundDestinationId,
        @in_vchSssbConversationHandle   = @in_vchSssbConversationHandle,
        @in_vchWhId                     = @in_vchWhId,
        @in_vchMessageType              = @in_vchMessageType,
        @in_vchOrderType                = @in_vchOrderType,
        @in_vchMessageId                = @in_vchMessageId,
        @in_vchMessage                  = @in_vchMessage

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while running sp_executesql.';
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
