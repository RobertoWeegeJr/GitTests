USE [AAD]
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[t_mw_inbound_integrated_message_id] TO AAD_USER, WA_USER, MW_USER;
GO