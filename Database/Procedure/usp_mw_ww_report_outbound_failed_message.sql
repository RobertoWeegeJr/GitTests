USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_ww_report_outbound_failed_message') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_ww_report_outbound_failed_message];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_ww_report_outbound_failed_message]
    @in_nWwUserLocaleId        INT,
    @in_vchStartDateTime       NVARCHAR(100),
    @in_vchEndDateTime         NVARCHAR(100),
    @in_vchMwOutboundId        NVARCHAR(50),
    @in_vchWhId                NVARCHAR(10),
    @in_vchMessageType         NVARCHAR(200),
    @in_vchOrderType           NVARCHAR(200),
    @in_vchMessageId           NVARCHAR(200),
    @in_vchMessage             NVARCHAR(MAX),
    @in_chStatus               NCHAR(1),
    @in_vchReason              NVARCHAR(200),
    @in_vchDetails             NVARCHAR(MAX)
AS

SET NOCOUNT ON;

DECLARE

    @v_vchViewId                NVARCHAR(200),
    @v_dStartDate               DATE,
    @v_dEndDate                 DATE,
    @v_dStartDateTime           DATETIME2,
    @v_dEndDateTime             DATETIME2,

    @v_vchSqlQuery              NVARCHAR(MAX),
    @v_vchParamsList            NVARCHAR(MAX),

    -- Error handling variables
    @v_nSysErrorNum             INTEGER,
    @v_vchCode                  uddt_output_code,
    @v_vchMsg                   uddt_output_msg,
    @c_vchObjName               uddt_obj_name,
    @c_nErrorLineOffSet         INTEGER,
    @v_nErrorNumber             INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_ww_report_outbound_failed_message';
    SET @c_nErrorLineOffSet = 7;

BEGIN TRY

    SET @v_dStartDateTime = dbo.usf_format_date_to_glb_locale(@in_nWwUserLocaleId, @in_vchStartDateTime);
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

    SET @v_dEndDateTime = dbo.usf_format_date_to_glb_locale(@in_nWwUserLocaleId, @in_vchEndDateTime);
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
        @v_nWwUserLocaleId              INT             = @in_nWwUserLocaleId,
        @v_dStartDate                   DATE            = @in_dStartDate,
        @v_dEndDate                     DATE            = @in_dEndDate,
        @v_dStartDateTime               DATETIME2       = @in_dStartDateTime,
        @v_dEndDateTime                 DATETIME2       = @in_dEndDateTime,
        @v_vchMwOutboundId              NVARCHAR(50)    = @in_vchMwOutboundId,
        @v_vchWhId                      NVARCHAR(10)    = @in_vchWhId,
        @v_vchMessageType               NVARCHAR(200)   = @in_vchMessageType,
        @v_vchOrderType                 NVARCHAR(200)   = @in_vchOrderType,
        @v_vchMessageId                 NVARCHAR(200)   = @in_vchMessageId,
        @v_vchMessage                   NVARCHAR(MAX)   = @in_vchMessage,
        @v_chStatus                     NCHAR(1)        = @in_chStatus,
        @v_vchReason                    NVARCHAR(200)   = @in_vchReason,
        @v_vchDetails                   NVARCHAR(MAX)   = @in_vchDetails;

    SELECT ofm.mw_outbound_failed_message_id
          ,ofm.record_created_date
          ,ofm.record_created_datetime
          ,ofm.mw_outbound_id
          ,ofm.wh_id
          ,ofm.message_type
          ,ofm.order_type
          ,ofm.message_id
          ,ISNULL(lkp.description, ofm.status) AS status
          ,ISNULL(lkp2.description, ofm.reason) AS reason
          ,ofm.details
          ,ofm.message
      FROM t_mw_outbound_failed_message ofm
      LEFT JOIN t_lookup lkp
        ON lkp.source = ''t_mw_outbound_failed_message''
       AND lkp.lookup_type = ''STATUS''
       AND lkp.locale_id = @v_nWwUserLocaleId
       AND lkp.text = ofm.status
      LEFT JOIN t_lookup lkp2
        ON lkp2.source = ''t_mw_outbound_failed_message''
       AND lkp2.lookup_type = ''REASON''
       AND lkp2.locale_id = @v_nWwUserLocaleId
       AND lkp2.text = ofm.reason
     WHERE ofm.record_created_date BETWEEN @v_dStartDate AND @v_dEndDate
       AND ofm.record_created_datetime BETWEEN @v_dStartDateTime AND @v_dEndDateTime';

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
    '@in_nWwUserLocaleId              INT,
     @in_dStartDate                   DATE,
     @in_dEndDate                     DATE,
     @in_dStartDateTime               DATETIME2,
     @in_dEndDateTime                 DATETIME2,
     @in_vchMwOutboundId              NVARCHAR(50),
     @in_vchWhId                      NVARCHAR(10),
     @in_vchMessageType               NVARCHAR(200),
     @in_vchOrderType                 NVARCHAR(200),
     @in_vchMessageId                 NVARCHAR(200),
     @in_vchMessage                   NVARCHAR(MAX),
     @in_chStatus                     NCHAR(1),
     @in_vchReason                    NVARCHAR(200),
     @in_vchDetails                   NVARCHAR(MAX)';

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while setting @v_vchParamsList.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    IF @in_vchMwOutboundId <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.mw_outbound_id LIKE @v_vchMwOutboundId';

    IF @in_vchWhId <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.wh_id LIKE @v_vchWhId';

    IF @in_vchMessageType <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.message_type LIKE @v_vchMessageType';

    IF @in_vchOrderType <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.order_type LIKE @v_vchOrderType';

    IF @in_vchMessageId <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.message_id LIKE @v_vchMessageId';

    IF @in_vchMessage <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND CAST(ofm.message AS NVARCHAR(MAX)) LIKE @v_vchMessage';

    IF @in_chStatus <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.status LIKE @v_chStatus';

    IF @in_vchReason <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.reason LIKE @v_vchReason';

    IF @in_vchDetails <> '%'
        SET @v_vchSqlQuery = @v_vchSqlQuery + ' AND ofm.details LIKE @v_vchDetails';

    SET @v_vchSqlQuery = @v_vchSqlQuery + ' ORDER BY ofm.record_created_datetime';

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
        @in_nWwUserLocaleId             = @in_nWwUserLocaleId,
        @in_dStartDate                  = @v_dStartDate,
        @in_dEndDate                    = @v_dEndDate,
        @in_dStartDateTime              = @v_dStartDateTime,
        @in_dEndDateTime                = @v_dEndDateTime,
        @in_vchMwOutboundId             = @in_vchMwOutboundId,
        @in_vchWhId                     = @in_vchWhId,
        @in_vchMessageType              = @in_vchMessageType,
        @in_vchOrderType                = @in_vchOrderType,
        @in_vchMessageId                = @in_vchMessageId,
        @in_vchMessage                  = @in_vchMessage,
        @in_chStatus                    = @in_chStatus,
        @in_vchReason                   = @in_vchReason,
        @in_vchDetails                  = @in_vchDetails

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

