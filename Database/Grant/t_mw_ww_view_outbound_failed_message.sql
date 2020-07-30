USE [AAD]
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[t_mw_ww_view_outbound_failed_message] TO WA_USER, AAD_USER, MW_USER
GO
