USE [AAD]
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[t_mw_outbound] TO AAD_USER, WA_USER, MW_USER;
GO