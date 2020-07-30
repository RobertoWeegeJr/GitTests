USE [AAD]
GO

IF OBJECT_ID('dbo.usp_log_console_message2') IS NOT NULL	
	DROP PROCEDURE [dbo].[usp_log_console_message2];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_log_console_message2] 
	@in_nLogLevel				INT,
	@in_vchMessage				NVARCHAR(MAX)
AS

SET NOCOUNT ON;

DECLARE

	-- Error handling variables
    @v_nSysErrorNum             INTEGER,
    @v_vchCode                  uddt_output_code,
    @v_vchMsg                   uddt_output_msg,
	@c_vchObjName               uddt_obj_name,
    @c_nErrorLineOffSet		    INTEGER,
	@v_nErrorNumber				INTEGER;
	
    -- Set Constants
    SET @c_vchObjName = N'usp_log_console_message2';
    SET @c_nErrorLineOffSet = 7;  

BEGIN TRY
	
	IF (@in_nLogLevel IS NOT NULL) BEGIN
	
		IF (@in_vchMessage IS NOT NULL) BEGIN
			INSERT INTO t_logsend (log_level, log_message)
			VALUES (@in_nLogLevel, @in_vchMessage);
		END ELSE BEGIN
			INSERT INTO t_logsend (log_level, log_message)
			VALUES (@in_nLogLevel, DEFAULT);
		END
	
	END ELSE BEGIN

		IF (@in_vchMessage IS NOT NULL) BEGIN
			INSERT INTO t_logsend (log_level, log_message)
			VALUES (DEFAULT, @in_vchMessage);
		END ELSE BEGIN
			INSERT INTO t_logsend (log_level, log_message)
			VALUES (DEFAULT, DEFAULT);
		END

	END

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
	SET @v_vchMsg = N'An error occurred while inserting t_logsend data.';
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