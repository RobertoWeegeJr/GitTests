USE [AAD]
GO

IF OBJECT_ID('dbo.usp_mw_wcs_in_EXAMPLE_ORDER_TYPE') IS NOT NULL    
    DROP PROCEDURE [dbo].[usp_mw_wcs_in_EXAMPLE_ORDER_TYPE];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_mw_wcs_in_EXAMPLE_ORDER_TYPE] 
@in_vchmwInboundId            NVARCHAR(50),
    @in_vchMessageType            NVARCHAR(200),
    @in_vchOrderType            NVARCHAR(200),
    @in_vchMessageId            NVARCHAR(200),
    @in_xmlMessage                XML,
    @out_vchHospitalReason        NVARCHAR(200)        OUTPUT,
    @out_vchCode                uddt_output_code    OUTPUT,
    @out_vchMsg                 uddt_output_msg        OUTPUT
AS

SET NOCOUNT ON

DECLARE

    @v_vchHospitalReason        NVARCHAR(200),

    -- Error handling variables
    @v_nSysErrorNum             INTEGER,
    @v_nRowCount                INTEGER,
    @v_nReturn                  INTEGER,
    @v_vchCode                  uddt_output_code,
    @v_vchMsg                   uddt_output_msg,
    @c_vchObjName               uddt_obj_name,
    @c_nErrorLineOffSet            INTEGER,
    @v_nErrorNumber                INTEGER;
    
    -- Set Constants
    SET @c_vchObjName = N'usp_mw_wcs_in_EXAMPLE_ORDER_TYPE';
    SET @c_nErrorLineOffSet = 7;  
    
    SET NOCOUNT ON;

BEGIN TRAN

IF 1=1
BEGIN
    SET @v_vchHospitalReason = 'NOT_IMPLEMENTED'
    SET @v_vchMsg = 'usp_mw_wcs_in_EXAMPLE_ORDER_TYPE not implemented yet.';
    SET @v_vchCode = 'SUCCESS';
    ROLLBACK;
    GOTO EXIT_LABEL;
END;

COMMIT;
SET @v_vchCode = 'SUCCESS';
GOTO EXIT_LABEL;

-----------------------------------------------------------------------------------
--                            Error Handling
-----------------------------------------------------------------------------------
ERROR_HANDLER:

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
    SET @out_vchHospitalReason = @v_vchHospitalReason;
    SET @out_vchCode           = @v_vchCode;
    SET @out_vchMsg            = @v_vchMsg;
    RETURN;
GO

GRANT EXECUTE ON [dbo].[usp_mw_wcs_in_EXAMPLE_ORDER_TYPE] TO WA_USER, AAD_USER
GO
