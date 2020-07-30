USE AAD;

IF (SELECT 1 FROM sys.services 
     WHERE name = 's_mw_outbound_request_01') IS NOT NULL    
    DROP SERVICE [s_mw_outbound_request_01];
GO

IF OBJECT_ID('dbo.q_mw_outbound_request_01') IS NOT NULL    
    DROP QUEUE [dbo].[q_mw_outbound_request_01];
GO

IF (SELECT 1 FROM sys.services 
     WHERE name = 's_mw_outbound_process_01') IS NOT NULL    
    DROP SERVICE [s_mw_outbound_process_01];
GO

IF OBJECT_ID('dbo.q_mw_outbound_process_01') IS NOT NULL    
    DROP QUEUE [dbo].[q_mw_outbound_process_01];
GO

IF (SELECT 1 FROM sys.conversation_priorities
     WHERE name = 'p_mw_outbound_default') IS NOT NULL    
    DROP BROKER PRIORITY [p_mw_outbound_default];
GO

IF (SELECT 1 FROM sys.conversation_priorities
     WHERE name = 'p_mw_outbound_reprocess') IS NOT NULL
    DROP BROKER PRIORITY [p_mw_outbound_reprocess];
GO

IF (SELECT 1 FROM sys.service_contracts 
     WHERE name = 'c_mw_outbound_default') IS NOT NULL    
    DROP CONTRACT [c_mw_outbound_default];
GO

IF (SELECT 1 FROM sys.service_contracts 
     WHERE name = 'c_mw_outbound_reprocess') IS NOT NULL    
    DROP CONTRACT [c_mw_outbound_reprocess];
GO

IF (SELECT 1 FROM sys.service_message_types 
     WHERE name = 'm_mw_outbound') IS NOT NULL    
    DROP MESSAGE TYPE [m_mw_outbound];
GO

CREATE MESSAGE TYPE [m_mw_outbound]
VALIDATION = WELL_FORMED_XML
GO

CREATE CONTRACT [c_mw_outbound_default] (
    [m_mw_outbound] SENT BY INITIATOR
)
GO

CREATE CONTRACT [c_mw_outbound_reprocess] (
    [m_mw_outbound] SENT BY INITIATOR
)
GO

CREATE BROKER PRIORITY [p_mw_outbound_default] FOR CONVERSATION
SET (
    CONTRACT_NAME = [c_mw_outbound_default],
    PRIORITY_LEVEL = 5
)

CREATE BROKER PRIORITY [p_mw_outbound_reprocess] FOR CONVERSATION
SET (
    CONTRACT_NAME = [c_mw_outbound_reprocess],
    PRIORITY_LEVEL = 7
)

CREATE QUEUE [dbo].[q_mw_outbound_request_01]
WITH STATUS = ON , 
    RETENTION = OFF, 
    ACTIVATION (  
        STATUS = ON, 
        PROCEDURE_NAME = [dbo].[usp_mw_qa_outbound_request_01] , 
        MAX_QUEUE_READERS = 5, 
        EXECUTE AS N'dbo'  
    ), 
    POISON_MESSAGE_HANDLING (
        STATUS = ON
    ) 
GO

CREATE SERVICE [s_mw_outbound_request_01]
    ON QUEUE [dbo].[q_mw_outbound_request_01] ([c_mw_outbound_default], [c_mw_outbound_reprocess]); 
GO

CREATE QUEUE [dbo].[q_mw_outbound_process_01]
WITH STATUS = ON , 
    RETENTION = OFF , 
    POISON_MESSAGE_HANDLING (
        STATUS = ON
    ) 
GO

CREATE SERVICE [s_mw_outbound_process_01]
    ON QUEUE [dbo].[q_mw_outbound_process_01] ([c_mw_outbound_default], [c_mw_outbound_reprocess]); 
GO
