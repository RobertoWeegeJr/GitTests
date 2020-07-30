USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_ww_cancel_outbound_failed_message') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_ww_cancel_outbound_failed_message];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_ww_cancel_outbound_failed_message]
    @in_vchWwUserId            NVARCHAR(200),
    @in_vchViewId              NVARCHAR(200),
    @out_vchMsg                uddt_output_msg        OUTPUT,
    @ww_result                 uddt_output_code    OUTPUT

AS

SET NOCOUNT ON;

DECLARE

    @v_dStartDate               DATETIME,
    @v_dEndDate                 DATETIME,
    @v_vchTranGroupID           NVARCHAR(30),

    -- Error handling variables
    @v_nSysErrorNum             INTEGER,
    @v_vchCode                  uddt_output_code,
    @v_vchMsg                   uddt_output_msg,
    @c_vchObjName               uddt_obj_name,
    @c_nErrorLineOffSet         INTEGER,
    @v_nErrorNumber             INTEGER;

DECLARE @t_cancelled_messages TABLE (
    mw_outbound_failed_message_id       BIGINT,
    wh_id                               NVARCHAR(10),
    mw_outbound_id                      NVARCHAR(50),
    message_type                        NVARCHAR(200),
    order_type                          NVARCHAR(200),
    message_id                          NVARCHAR(200)
);

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_ww_cancel_outbound_failed_message';
    SET @c_nErrorLineOffSet = 7;
    SET @ww_result = N'FAIL';

    SET @v_dStartDate = GETDATE();

BEGIN TRANSACTION

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

    UPDATE ofm
       SET ofm.status = 'X'
    OUTPUT INSERTED.mw_outbound_failed_message_id
          ,INSERTED.wh_id
          ,INSERTED.mw_outbound_id
          ,INSERTED.message_type
          ,INSERTED.order_type
          ,INSERTED.message_id
      INTO @t_cancelled_messages
      FROM t_mw_outbound_failed_message ofm
     INNER JOIN t_mw_ww_view_outbound_failed_message vow
        ON vow.mw_outbound_failed_message_id = ofm.mw_outbound_failed_message_id
     WHERE ofm.status IN ('N', 'E')
       AND vow.selected = 1
       AND vow.view_id = @in_vchViewId;

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while updating t_mw_outbound_failed_message.';
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
        generic_text1,      --mw_outbound_id
        generic_text2,      --message_type
        generic_text3,      --order_type
        generic_text4       --message_id
    )
    SELECT @v_vchTranGroupID
          ,trn.tran_type
          ,trn.description
          ,CAST(@v_dStartDate AS DATE)                        AS start_tran_date
          ,CAST(@v_dStartDate AS TIME)                        AS start_tran_time
          ,CAST(@v_dEndDate AS DATE)                          AS end_tran_date
          ,CAST(@v_dEndDate AS TIME)                          AS end_tran_time
          ,DATEDIFF(ss, @v_dStartDate, @v_dEndDate)           AS elapsed_time
          ,RIGHT(@in_vchWwUserId, 10)                         AS employee_id
          ,cmg.mw_outbound_failed_message_id                  AS control_number
          ,cmg.wh_id
          ,cmg.mw_outbound_id                                 AS generic_text1
          ,cmg.message_type                                   AS generic_text2
          ,cmg.order_type                                     AS generic_text3
          ,cmg.message_id                                     AS generic_text4
      FROM @t_cancelled_messages cmg
      LEFT JOIN t_transaction trn
             ON trn.system_id = 'WA'
            AND trn.tran_type = '733';

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_tran_log_holding.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

SET @v_vchCode = 'SUCCESS';
SET @ww_result = N'PASS';
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
