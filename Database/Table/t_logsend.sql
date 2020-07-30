USE [AAD]
GO

ALTER TABLE [dbo].[t_logsend]

ALTER COLUMN [log_message] NVARCHAR(4000) COLLATE DATABASE_DEFAULT NOT NULL;
GO

IF OBJECT_ID('dbo.ck_logsend_log_level', 'C') IS NULL    
BEGIN
	ALTER TABLE [dbo].[t_logsend]
	ADD CONSTRAINT [ck_logsend_log_level] CHECK ([log_level] BETWEEN 1 AND 3);
END
GO

IF OBJECT_ID('dbo.[df_logsend_log_level]', 'D') IS NULL    
BEGIN
	ALTER TABLE [dbo].[t_logsend]
	ADD CONSTRAINT [df_logsend_log_level] DEFAULT 3 FOR [log_level];
END
GO

IF OBJECT_ID('dbo.[df_logsend_log_message]', 'D') IS NULL    
BEGIN
	ALTER TABLE [dbo].[t_logsend]
	ADD CONSTRAINT [df_logsend_log_message] DEFAULT N'?' FOR [log_message];
END
GO
