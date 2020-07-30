echo on
call SetDBCredentials.bat

echo HJMiddlewareUserAndRole
sqlcmd -S %server% -U %user% -P %password% -i "Script\HJMiddlewareUserAndRole.sql"                                         -f 65001

echo t_logsend
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_logsend.sql"                                                        -f 65001

echo usp_log_console_message                                                                                               
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_log_console_message.sql"                                      -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_log_console_message.sql"                                          -f 65001

echo t_mw_inbound
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_inbound.sql"                                                     -f 65001                                 
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_inbound.sql"                                                     -f 65001

echo t_mw_inbound_control
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_inbound_control.sql"                                             -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_inbound_control.sql"                                             -f 65001

echo t_mw_inbound_rules
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_inbound_rules.sql"                                               -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_inbound_rules.sql"                                               -f 65001

echo t_mw_inbound_log
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_inbound_log.sql"                                                 -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_inbound_log.sql"                                                 -f 65001

echo tr_mw_inbound_log
sqlcmd -S %server% -U %user% -P %password% -i "Trigger\tr_mw_inbound_log.sql"                                              -f 65001

echo t_mw_inbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_inbound_failed_message.sql"                                      -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_inbound_failed_message.sql"                                      -f 65001

echo tr_mw_inbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Trigger\tr_mw_inbound_failed_message.sql"                                   -f 65001

echo t_mw_inbound_integrated_message_id
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_inbound_integrated_message_id.sql"                               -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_inbound_integrated_message_id.sql"                               -f 65001

echo t_mw_ww_view_inbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_ww_view_inbound_failed_message.sql"                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_ww_view_inbound_failed_message.sql"                              -f 65001

echo usp_mw_inbound_add_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_inbound_add_failed_message.sql"                            -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_inbound_add_failed_message.sql"                                -f 65001

echo usp_mw_inbound_integrator_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_inbound_integrator_failed_message.sql"                     -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_inbound_integrator_failed_message.sql"                         -f 65001

echo usp_mw_qa_inbound_request_01
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_qa_inbound_request_01.sql"                                 -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_qa_inbound_request_01.sql"                                     -f 65001

echo usp_mw_qa_inbound_process_01
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_qa_inbound_process_01.sql"                                 -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_qa_inbound_process_01.sql"                                     -f 65001

echo usp_mw_inbound_validate_message_id
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_inbound_validate_message_id.sql"                           -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_inbound_validate_message_id.sql"                               -f 65001

echo usp_mw_inbound_01
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_inbound_01.sql"                                            -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_inbound_01.sql"                                                -f 65001

echo usp_mw_inbound_reprocess_01
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_inbound_reprocess_01.sql"                                  -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_inbound_reprocess_01.sql"                                      -f 65001

echo usp_mw_ww_reprocess_inbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_reprocess_inbound_failed_message.sql"                   -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_reprocess_inbound_failed_message.sql"                       -f 65001

echo usp_mw_ww_cancel_inbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_cancel_inbound_failed_message.sql"                      -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_cancel_inbound_failed_message.sql"                          -f 65001

echo usp_mw_ww_load_inbound_failed_message_view
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_load_inbound_failed_message_view.sql"                   -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_load_inbound_failed_message_view.sql"                       -f 65001

echo usp_mw_ww_report_inbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_report_inbound_failed_message.sql"                      -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_report_inbound_failed_message.sql"                          -f 65001

echo usp_mw_ww_report_inbound_log
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_report_inbound_log.sql"                                 -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_report_inbound_log.sql"                                     -f 65001

echo usp_mw_inbound_purge_received_message_id
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_inbound_purge_received_message_id.sql"                     -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_inbound_purge_received_message_id.sql"                         -f 65001

echo mw_Inbound
sqlcmd -S %server% -U %user% -P %password% -i "Service Broker\MWInbound.sql"                                               -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Script\MWInbound.sql"                                                       -f 65001

echo t_mw_outbound
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound.sql"                                                    -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound.sql"                                                    -f 65001

echo t_mw_outbound_control
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_control.sql"                                            -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_control.sql"                                            -f 65001

echo t_mw_outbound_destination
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_destination.sql"                                        -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_destination.sql"                                        -f 65001

echo t_mw_outbound_destination_header
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_destination_header.sql"                                 -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_destination_header.sql"                                 -f 65001

echo t_mw_outbound_destination_auth
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_destination_auth.sql"                                   -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_destination_auth.sql"                                   -f 65001

echo t_mw_outbound_rules
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_rules.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_rules.sql"                                              -f 65001

echo t_mw_outbound_log
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_log.sql"                                                -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_log.sql"                                                -f 65001

echo tr_mw_outbound_log
sqlcmd -S %server% -U %user% -P %password% -i "Trigger\tr_mw_outbound_log.sql"                                             -f 65001

echo t_mw_outbound_response_log
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_response_log.sql"                                       -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_response_log.sql"                                       -f 65001

echo tr_mw_outbound_response_log
sqlcmd -S %server% -U %user% -P %password% -i "Trigger\tr_mw_outbound_response_log.sql"                                    -f 65001

echo t_mw_outbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_outbound_failed_message.sql"                                     -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_outbound_failed_message.sql"                                     -f 65001

echo t_mw_ww_view_outbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Table\t_mw_ww_view_outbound_failed_message.sql"                             -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\t_mw_ww_view_outbound_failed_message.sql"                             -f 65001

echo tr_mw_outbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Trigger\tr_mw_outbound_failed_message.sql"                                  -f 65001

echo usp_mw_outbound_response_log
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_outbound_response_log.sql"                                 -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_outbound_response_log.sql"                                     -f 65001

echo usp_mw_outbound_add_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_outbound_add_failed_message.sql"                           -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_outbound_add_failed_message.sql"                               -f 65001

echo usp_mw_qa_outbound_request_01
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_qa_outbound_request_01.sql"                                -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_qa_outbound_request_01.sql"                                    -f 65001

echo usp_mw_outbound
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_outbound.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_outbound.sql"                                                  -f 65001

echo usp_mw_ww_load_outbound_failed_message_view
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_load_outbound_failed_message_view.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_load_outbound_failed_message_view.sql"                                                  -f 65001

echo usp_mw_outbound_reprocess
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_outbound_reprocess.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_outbound_reprocess.sql"                                                  -f 65001

echo usp_mw_ww_reprocess_outbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_reprocess_outbound_failed_message.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_reprocess_outbound_failed_message.sql"                                                  -f 65001

echo usp_mw_ww_cancel_outbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_cancel_outbound_failed_message.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_cancel_outbound_failed_message.sql"                                                  -f 65001

echo usp_mw_ww_report_outbound_log
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_report_outbound_log.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_report_outbound_log.sql"                                                  -f 65001

echo usp_mw_ww_report_outbound_response_log
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_report_outbound_response_log.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_report_outbound_response_log.sql"                                                  -f 65001

echo usp_mw_ww_report_outbound_failed_message
sqlcmd -S %server% -U %user% -P %password% -i "Procedure\usp_mw_ww_report_outbound_failed_message.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\usp_mw_ww_report_outbound_failed_message.sql"                                                  -f 65001

echo mw_Outbound
sqlcmd -S %server% -U %user% -P %password% -i "Service Broker\MWOutbound.sql"                                              -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Grant\q_mw_outbound_process_01.sql"                                         -f 65001
sqlcmd -S %server% -U %user% -P %password% -i "Script\MWOutbound.sql"                                                      -f 65001

echo t_transaction
sqlcmd -S %server% -U %user% -P %password% -i "Script\t_transaction.sql"                                                   -f 65001

echo t_control
sqlcmd -S %server% -U %user% -P %password% -i "Script\t_control.sql"                                                       -f 65001

echo t_lookup
sqlcmd -S %server% -U %user% -P %password% -i "Script\t_lookup.sql"                                                       -f 65001
