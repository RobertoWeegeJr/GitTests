USE [AAD]
GO

DELETE FROM t_lookup
 WHERE source IN ('t_mw_inbound_failed_message', 't_mw_outbound_failed_message')

INSERT INTO t_lookup (source, sequence, locale_id, lookup_type, text, description)
VALUES
(N't_mw_inbound_failed_message',     1, N'1033', N'STATUS', N'N'                                ,N'New'),
(N't_mw_inbound_failed_message',     2, N'1033', N'STATUS', N'C'                                ,N'Closed'),
(N't_mw_inbound_failed_message',     3, N'1033', N'STATUS', N'P'                                ,N'Processing'),
(N't_mw_inbound_failed_message',     4, N'1033', N'STATUS', N'E'                                ,N'Error'),
(N't_mw_inbound_failed_message',     1, N'1033', N'REASON', N'UNKNOWN'                          ,N'Unknown'),
(N't_mw_inbound_failed_message',     2, N'1033', N'REASON', N'PROCESS_PROC_NOT_FOUND'           ,N'Process Proc Not Found'),
(N't_mw_inbound_failed_message',     3, N'1033', N'REASON', N'OPEN_TRANSACTION_AFTER_PROC'      ,N'Open Transaction After Process Proc'),
(N't_mw_inbound_failed_message',     4, N'1033', N'REASON', N'INBOUND_MIDDLEWARE_EXCEPTION'     ,N'Inbound Middleware Exception'),
(N't_mw_inbound_failed_message',     5, N'1033', N'REASON', N'XML_BUILDING'                     ,N'XML Building Error'),
(N't_mw_inbound_failed_message',     6, N'1033', N'REASON', N'XML_FORMAT_VALIDATION'            ,N'XML Format Validation Error'),

(N't_mw_inbound_failed_message',     1, N'1046', N'STATUS', N'N'                                ,N'Novo'),
(N't_mw_inbound_failed_message',     2, N'1046', N'STATUS', N'C'                                ,N'Concluído'),
(N't_mw_inbound_failed_message',     3, N'1046', N'STATUS', N'P'                                ,N'Processando'),
(N't_mw_inbound_failed_message',     4, N'1046', N'STATUS', N'E'                                ,N'Erro'),
(N't_mw_inbound_failed_message',     1, N'1046', N'REASON', N'UNKNOWN'                          ,N'Desconhecido'),
(N't_mw_inbound_failed_message',     2, N'1046', N'REASON', N'PROCESS_PROC_NOT_FOUND'           ,N'Proc de Processamento Não Cadastrada'),
(N't_mw_inbound_failed_message',     3, N'1046', N'REASON', N'OPEN_TRANSACTION_AFTER_PROC'      ,N'Transação aberta após Proc de Processamento'),
(N't_mw_inbound_failed_message',     4, N'1046', N'REASON', N'INBOUND_MIDDLEWARE_EXCEPTION'     ,N'Exceção do Middleware de Entrada'),
(N't_mw_inbound_failed_message',     5, N'1046', N'REASON', N'XML_BUILDING'                     ,N'Erro na construção do XML'),
(N't_mw_inbound_failed_message',     6, N'1046', N'REASON', N'XML_FORMAT_VALIDATION'            ,N'Erro na validação de formato do XML'),

(N't_mw_outbound_failed_message',    1, N'1033', N'STATUS', N'N'                                ,N'New'),
(N't_mw_outbound_failed_message',    2, N'1033', N'STATUS', N'C'                                ,N'Closed'),
(N't_mw_outbound_failed_message',    3, N'1033', N'STATUS', N'P'                                ,N'Processing'),
(N't_mw_outbound_failed_message',    4, N'1033', N'STATUS', N'E'                                ,N'Error'),
(N't_mw_outbound_failed_message',    1, N'1033', N'REASON', N'UNKNOWN'                          ,N'Unknown'),
(N't_mw_outbound_failed_message',    2, N'1033', N'REASON', N'DESTINATION_NOT_FOUND'            ,N'Destination Not Found'),
(N't_mw_outbound_failed_message',    3, N'1033', N'REASON', N'LOG_RESPONSE_FAILED'              ,N'Log Respose Failed'),
(N't_mw_outbound_failed_message',    4, N'1033', N'REASON', N'INVALID_RESPONSE_CODE'            ,N'Invalid Respose Code'),
(N't_mw_outbound_failed_message',    5, N'1033', N'REASON', N'INVALID_OUTBOUND_MESSAGE'         ,N'Invalid Outbound Message'),
(N't_mw_outbound_failed_message',    6, N'1033', N'REASON', N'INVALID_MESSAGE_TO_HOST'          ,N'Invalid Message To Host'),
(N't_mw_outbound_failed_message',    7, N'1033', N'REASON', N'ERROR_SENDING_MESSAGE_TO_HOST'    ,N'Error Sending Message To Host'),
(N't_mw_outbound_failed_message',    8, N'1033', N'REASON', N'ERROR_CONFIGURING_MESSAGE_TO_HOST',N'Error Configuring Message To Host'),

(N't_mw_outbound_failed_message',    1, N'1046', N'STATUS', N'N'                                ,N'Novo'),
(N't_mw_outbound_failed_message',    2, N'1046', N'STATUS', N'C'                                ,N'Concluído'),
(N't_mw_outbound_failed_message',    3, N'1046', N'STATUS', N'P'                                ,N'Processando'),
(N't_mw_outbound_failed_message',    4, N'1046', N'STATUS', N'E'                                ,N'Erro'),
(N't_mw_outbound_failed_message',    1, N'1046', N'REASON', N'UNKNOWN'                          ,N'Desconhecido'),
(N't_mw_outbound_failed_message',    2, N'1046', N'REASON', N'DESTINATION_NOT_FOUND'            ,N'Destino Não Encontrado'),
(N't_mw_outbound_failed_message',    3, N'1046', N'REASON', N'LOG_RESPONSE_FAILED'              ,N'Falhar ao Gravar o Log de Resposta'),
(N't_mw_outbound_failed_message',    4, N'1046', N'REASON', N'INVALID_RESPONSE_CODE'            ,N'Código de Resposta Inválido'),
(N't_mw_outbound_failed_message',    5, N'1046', N'REASON', N'INVALID_OUTBOUND_MESSAGE'         ,N'Mensagem de Saída Inválida'),
(N't_mw_outbound_failed_message',    6, N'1046', N'REASON', N'INVALID_MESSAGE_TO_HOST'          ,N'Mensagem para o Destino Inválida'),
(N't_mw_outbound_failed_message',    7, N'1046', N'REASON', N'ERROR_SENDING_MESSAGE_TO_HOST'    ,N'Erro Enviando Mensagem ao Destino'),
(N't_mw_outbound_failed_message',    8, N'1046', N'REASON', N'ERROR_CONFIGURING_MESSAGE_TO_HOST',N'Erro Configurando Mensagem ao Destino');

