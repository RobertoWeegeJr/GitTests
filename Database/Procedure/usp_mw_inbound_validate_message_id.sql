USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_inbound_validate_message_id') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_inbound_validate_message_id];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_inbound_validate_message_id]
    @in_vchMessageId              NVARCHAR(200),
    @out_vchValidationCode        NVARCHAR(200)     OUTPUT,
    @out_vchValidationMessage     NVARCHAR(MAX)     OUTPUT
AS

SET NOCOUNT ON;

DECLARE

    @v_vchValidationCode            NVARCHAR(200),
    @v_vchValidationMessage         NVARCHAR(MAX),
    @v_nCounter                     INTEGER,

    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;

    -- Set Constants
    SET @c_vchObjName = N'usp_mw_inbound_validate_message_id';
    SET @c_nErrorLineOffSet = 7;

    SET @v_vchValidationCode = 'UNKNOWN';
    SET @v_vchValidationMessage = 'Unknown Error';

BEGIN TRANSACTION

BEGIN TRY

    MERGE t_mw_inbound_integrated_message_id imi
    USING (SELECT @in_vchMessageId AS message_id) AS mid
       ON mid.message_id = imi.message_id
     WHEN NOT MATCHED THEN
          INSERT (message_id)
          VALUES (mid.message_id);
    
    SET @v_nCounter = @@ROWCOUNT;
    
END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while inserting into t_mw_inbound_integrated_message_id.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

IF @v_nCounter <= 0 
BEGIN 

    SET @v_vchValidationCode = 'MESSAGE_ID_ALREADY_INTEGRATED';
    SET @v_vchValidationMessage = 'Message ID already integrated.';

    BEGIN TRY

        MERGE t_mw_inbound_integrated_message_id imi
        USING (SELECT @in_vchMessageId AS message_id) AS mid
           ON mid.message_id = imi.message_id
         WHEN NOT MATCHED THEN
              INSERT (message_id)
              VALUES (mid.message_id)
         WHEN MATCHED THEN
              UPDATE SET imi.record_created_datetime = GETDATE();

    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occurred while merging t_mw_inbound_integrated_message_id.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

END ELSE BEGIN    
  
    SET @v_vchValidationCode = NULL;
    SET @v_vchValidationMessage = NULL;
  
END

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
