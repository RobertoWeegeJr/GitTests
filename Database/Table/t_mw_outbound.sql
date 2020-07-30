USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound') IS NULL
BEGIN
    CREATE TABLE [dbo].[t_mw_outbound] (
        [mw_outbound_id]             NVARCHAR(50)     COLLATE DATABASE_DEFAULT,
        [description]                NVARCHAR(500)    COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_outbound]
            PRIMARY KEY ([mw_outbound_id])
    );
END
GO