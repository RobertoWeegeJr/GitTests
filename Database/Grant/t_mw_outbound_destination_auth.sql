USE [AAD]
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[t_mw_outbound_destination_auth] TO AAD_USER, WA_USER, MW_USER;
GO