USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound_destination_header') IS NULL
BEGIN
    CREATE TABLE [dbo].[t_mw_outbound_destination_header] (
        [mw_outbound_id]                                NVARCHAR(50)        COLLATE DATABASE_DEFAULT,
        [mw_outbound_destination_id]                    NVARCHAR(50)        COLLATE DATABASE_DEFAULT,
        [key]                                           NVARCHAR(200)       COLLATE DATABASE_DEFAULT,
        [value]                                         NVARCHAR(500)       COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_outbound_destination_header]
            PRIMARY KEY ([mw_outbound_id], [mw_outbound_destination_id], [key]),
        CONSTRAINT [fk_mw_outbound_destination_header]
            FOREIGN KEY ([mw_outbound_id], [mw_outbound_destination_id])
            REFERENCES [dbo].[t_mw_outbound_destination] ([mw_outbound_id], [mw_outbound_destination_id])
    );
END
GO