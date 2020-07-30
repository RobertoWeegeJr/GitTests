USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_inbound_purge_received_message_id') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_mw_inbound_purge_received_message_id];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_inbound_purge_received_message_id]
AS

SET NOCOUNT ON;

DECLARE

    @v_dNow                         DATETIME2,
    @v_vchMessageId                 NVARCHAR(200),
    @v_nSecondsLimit                INTEGER,

    -- Error handling variables
    @v_nSysErrorNum                 INTEGER,
    @v_vchCode                      uddt_output_code,
    @v_vchMsg                       uddt_output_msg,
    @c_vchObjName                   uddt_obj_name,
    @c_nErrorLineOffSet             INTEGER,
    @v_nErrorNumber                 INTEGER;
   
    -- Set Constants   
    SET @c_vchObjName = N'usp_mw_inbound_purge_received_message_id';
    SET @c_nErrorLineOffSet = 7;
    SET @v_dNow = SYSDATETIME();

BEGIN TRY

    SELECT @v_nSecondsLimit = next_value
      FROM t_control
     WHERE control_type = 'MW_PURGE_IN_MSG_ID_RETENTION'
    
    IF @@ROWCOUNT <= 0
        THROW 50000, 'Control t_control.MW_PURGE_IN_MSG_ID_RETENTION not found.', 1;
    
END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred while selecting t_control.';
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

BEGIN TRY

    DECLARE c_message_ids_to_delete CURSOR FOR
     SELECT message_id
       FROM t_mw_inbound_integrated_message_id
      WHERE DATEDIFF(second, record_created_datetime, @v_dNow) > @v_nSecondsLimit;

	OPEN c_message_ids_to_delete;
  
	FETCH NEXT FROM c_message_ids_to_delete   
	 INTO @v_vchMessageId;

END TRY
BEGIN CATCH
    SET @v_nSysErrorNum = ERROR_NUMBER();
    SET @v_vchCode = ERROR_LINE();
    SET @v_vchMsg = N'An error occurred opening c_message_ids_to_delete.';    
    SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
    GOTO ERROR_HANDLER;
END CATCH

WHILE @@FETCH_STATUS = 0  
BEGIN  

    BEGIN TRY

        DELETE t_mw_inbound_integrated_message_id 
         WHERE message_id = @v_vchMessageId
           AND DATEDIFF(second, record_created_datetime, @v_dNow) > @v_nSecondsLimit;
        
    END TRY
    BEGIN CATCH
        SET @v_nSysErrorNum = ERROR_NUMBER();
        SET @v_vchCode = ERROR_LINE();
        SET @v_vchMsg = N'An error occurred while deleting t_mw_inbound_integrated_message_id data.';
        SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
        GOTO ERROR_HANDLER;
    END CATCH

	BEGIN TRY

		FETCH NEXT FROM c_message_ids_to_delete   
         INTO @v_vchMessageId;

	END TRY
	BEGIN CATCH
		SET @v_nSysErrorNum = ERROR_NUMBER();
		SET @v_vchCode = ERROR_LINE();
		SET @v_vchMsg = N'An error occurred fetching next from c_message_ids_to_delete.';    
		SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
		GOTO ERROR_HANDLER;
	END CATCH

END   

BEGIN TRY

	CLOSE c_message_ids_to_delete;  
	DEALLOCATE c_message_ids_to_delete;  

END TRY
BEGIN CATCH
	SET @v_nSysErrorNum = ERROR_NUMBER();
	SET @v_vchCode = ERROR_LINE();
	SET @v_vchMsg = N'An error occurred closing c_message_ids_to_delete.';    
	SET @v_vchMsg = @v_vchMsg + N' SQL Error = ' + ERROR_MESSAGE();
	GOTO ERROR_HANDLER;
END CATCH

GOTO EXIT_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

    IF CURSOR_STATUS('global','c_message_ids_to_delete') >= -1 BEGIN
		IF CURSOR_STATUS('global','c_message_ids_to_delete') > -1 BEGIN
			CLOSE c_message_ids_to_delete
		END
		DEALLOCATE c_message_ids_to_delete
	END

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
