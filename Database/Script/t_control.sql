USE [AAD]
GO

DELETE FROM t_control 
 WHERE control_type = 'MW_PURGE_IN_MSG_ID_RETENTION'

INSERT INTO t_control (control_type, description, next_value)
VALUES ('MW_PURGE_IN_MSG_ID_RETENTION', 'MW Purge Inbound Message ID Retention', 300)