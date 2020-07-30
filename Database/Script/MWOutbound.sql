USE [AAD]
GO

DECLARE 
    @v_vchMwOutboundId NVARCHAR(50) = N'Outbound01',
    @v_vchDescription NVARCHAR(500) = N'Outbound 01';

DELETE FROM t_mw_outbound_rules;

DELETE FROM t_mw_outbound_destination_auth
 WHERE mw_outbound_id = @v_vchMwOutboundId;

DELETE FROM t_mw_outbound_destination_header
 WHERE mw_outbound_id = @v_vchMwOutboundId;

DELETE FROM t_mw_outbound_destination
 WHERE mw_outbound_id = @v_vchMwOutboundId;

DELETE FROM t_mw_outbound_control
 WHERE mw_outbound_id = @v_vchMwOutboundId;
 
DELETE FROM t_mw_outbound
 WHERE mw_outbound_id = @v_vchMwOutboundId;

INSERT INTO t_mw_outbound (mw_outbound_id, description)
VALUES (@v_vchMwOutboundId, @v_vchDescription);

INSERT INTO t_mw_outbound_control (mw_outbound_id, control_type, value)
VALUES (@v_vchMwOutboundId, N'SSSB_OUTBOUND_QUEUE', N'q_mw_outbound_process_01'),
       (@v_vchMwOutboundId, N'SSSB_QUEUE_TIMEOUT', N'5000'),
       (@v_vchMwOutboundId, N'SSSB_MESSAGE_TYPE', N'm_mw_outbound'),
       (@v_vchMwOutboundId, N'SSSB_MESSAGE_TO_HOST_TAG', N'Host2KiSoft'),
       (@v_vchMwOutboundId, N'MAX_THREAD_QUANTITY', N'3'),
       (@v_vchMwOutboundId, N'WORKER_SLEEP_TIME', N'5000'),
       (@v_vchMwOutboundId, N'LOG_PROCEDURE', N'usp_mw_outbound_response_log'),
       (@v_vchMwOutboundId, N'FAILED_MESSAGE_INTEGRATION_PROC', N'usp_mw_outbound_add_failed_message'),
       (@v_vchMwOutboundId, N'SEND_TO_FAILED_MSG_REASON', N'OUBOUND_MIDDLEWARE_EXCEPTION');

INSERT INTO t_mw_outbound_destination (
    mw_outbound_id,
    mw_outbound_destination_id,
    description,
    uri,
    content_type,
    encoding,
    accept
) VALUES (
    @v_vchMwOutboundId,
    'WCS01',
    'WCS 01',
    'https://as1827.lojasrenner.com.br:9881/DummyWCS',
    'application/xml',
    'utf-8',
    'application/xml'
);

INSERT INTO t_mw_outbound_destination_header (
    mw_outbound_id,
    mw_outbound_destination_id,
    [key],
    value
) VALUES (
    @v_vchMwOutboundId,
    'WCS01',
    'User-Agent',
    'Koerber Outbound Middleware'
);

INSERT INTO t_mw_outbound_destination_auth (
    mw_outbound_id,
    mw_outbound_destination_id,
    type,
    value
) VALUES (
    @v_vchMwOutboundId,
    'WCS01',
    'Basic',
    'SEpXTVM6QHNmZGZlcWFIR1NXMTIz'
);

INSERT INTO t_mw_outbound_rules (
    wh_id,
    message_type,
    order_type,
    destination_sssb_service,
    mw_outbound_destination_id,
    reprocess_proc
) 
VALUES ('504',      'ArticleLocationMasterDataNew',                 'ArticleLocationMasterDataNew',                     's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'ArticleLocationMasterDataUpdate',              'ArticleLocationMasterDataUpdate',                  's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'ArticleLocationMasterDataDelete',              'ArticleLocationMasterDataDelete',                  's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'StationUpdate',                                'StationUpdate',                                    's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'GOH_BUFFER_CROSSDOCKING',                          's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'GOH_BUFFER_STORAGE',                               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'GOH_STORAGE_REORGANIZATION',                       's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'GOH_STORAGE_CROSSDOCKING',                         's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLAT_PALLET',                                      's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLAT_CROSSDOCKING',                                's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLAT_CROSSDOCKING_SHR',                            's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLAT_DECANTING',                                   's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLAT_FLOW_RACK_REPLENISHMENT',                     's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'OPEN_GOODS_IN_SINGLE',                             's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'OPEN_GOODS_IN_MIX',                                's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PICKING_TW_DECANTING',                             's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PICKING_TW_FLOW_RACK_REPLENISHMENT',               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PICKING_TW_DISPATCH',                              's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PICKING_TW_DISPATCH_SHR',                          's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'GOH_INDUCTION_ADAPTER',                            's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PICKING_TW_INDUCTION_SINGLE',                      's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PICKING_TW_INDUCTION_MIXED',                       's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLOW_RACK_PICKING',                                's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'FLOW_RACK_PICKING_SHR',                            's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'ECOM_SORTER_PALLET',                               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'ECOM_DISPATCH',                                    's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PACKING_DISPATCH',                                 's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PACKING_DISPATCH_SHR',                             's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderData',                                    'PACKING_RETURN',                                   's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'RETAIL_PICKING_TOWER',                             's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'RETAIL_PICKING_TOWER_OSR',                         's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'RETAIL_GOH',                                       's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'RETAIL_OSR',                                       's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'ECOM_GOH',                                         's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'ECOM_GOH_OSR',                                     's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'ECOM_OSR',                                         's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'FLAT_PICKING_ORDER',                               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'GOH_PICKING_ORDER',                                's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderData',                               'ECOM_PICKING_ORDER',                               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderDatas',                                   'FLAT_PICKING_ORDER',                               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'BatchOrderLinesSumOsr',                        'OSR_INDUCTION',                                    's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderArticleShortPick',                        'OrderArticleShortPick',                            's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'OrderArticleDelete',                           'OrderArticleDelete',                               's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'InventoryOrder',                               'InventoryOrder',                                   's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess'),
       ('504',      'SnapshotRequest',                              'SnapshotRequest',                                  's_mw_outbound_process_01',   'WCS01',        'usp_mw_outbound_reprocess');
