USE [AAD]
GO

IF OBJECT_ID('dbo.t_mw_outbound_destination') IS NULL    
BEGIN
    CREATE TABLE [dbo].[t_mw_outbound_destination] (
        [mw_outbound_id]                            NVARCHAR(50)    COLLATE DATABASE_DEFAULT,
        [mw_outbound_destination_id]                NVARCHAR(50)    COLLATE DATABASE_DEFAULT,
        [description]                               NVARCHAR(500)   COLLATE DATABASE_DEFAULT,
        [uri]                                       NVARCHAR(200)   COLLATE DATABASE_DEFAULT,
        [content_type]                              NVARCHAR(50)    COLLATE DATABASE_DEFAULT,
        [encoding]                                  NVARCHAR(50)    COLLATE DATABASE_DEFAULT,
        [accept]                                    NVARCHAR(50)    COLLATE DATABASE_DEFAULT,
        CONSTRAINT [pk_mw_outbound_destination]    
            PRIMARY KEY ([mw_outbound_id], [mw_outbound_destination_id]),
        CONSTRAINT [fk_mw_outbound_destination]
            FOREIGN KEY ([mw_outbound_id])
            REFERENCES [dbo].[t_mw_outbound] ([mw_outbound_id])
    );    
END
GO