USE [AAD]
GO
 
DELETE FROM t_transaction
WHERE tran_type in ('730', 
'731', '732', '733')

MERGE t_transaction trn
USING (
       SELECT 'WA'                                              AS system_id
              ,'730'                                            AS tran_type
              ,'MW - Reprocesamento de Mensagem de Entrada'     AS description
              ,'NO'                                             AS send_to_adv_link
              ,'NONE'                                           AS inventory_action
      ) ins ON ins.system_id = trn.system_id
           AND ins.tran_type = trn.tran_type
           AND ins.description = trn.description
           AND ins.send_to_adv_link = trn.send_to_adv_link
           AND ins.inventory_action = trn.inventory_action
WHEN NOT MATCHED THEN
     INSERT (system_id, tran_type, description, send_to_adv_link, inventory_action)
     VALUES (ins.system_id, ins.tran_type, ins.description, ins.send_to_adv_link, ins.inventory_action);

MERGE t_transaction trn
USING (
        SELECT 'WA'                                             AS system_id
              ,'731'                                            AS tran_type
              ,'MW - Cancelamento de Mensagem de Entrada'       AS description
              ,'NO'                                             AS send_to_adv_link
              ,'NONE'                                           AS inventory_action
      ) ins ON ins.system_id = trn.system_id
           AND ins.tran_type = trn.tran_type
           AND ins.description = trn.description
           AND ins.send_to_adv_link = trn.send_to_adv_link
           AND ins.inventory_action = trn.inventory_action
WHEN NOT MATCHED THEN
     INSERT (system_id, tran_type, description, send_to_adv_link, inventory_action)
     VALUES (ins.system_id, ins.tran_type, ins.description, ins.send_to_adv_link, ins.inventory_action);

MERGE t_transaction trn
USING (
        SELECT 'WA'                                             AS system_id
              ,'732'                                            AS tran_type
              ,'MW - Reprocesamento de Mensagem de Saída'       AS description
              ,'NO'                                             AS send_to_adv_link
              ,'NONE'                                           AS inventory_action
      ) ins ON ins.system_id = trn.system_id
           AND ins.tran_type = trn.tran_type
           AND ins.description = trn.description
           AND ins.send_to_adv_link = trn.send_to_adv_link
           AND ins.inventory_action = trn.inventory_action
WHEN NOT MATCHED THEN
     INSERT (system_id, tran_type, description, send_to_adv_link, inventory_action)
     VALUES (ins.system_id, ins.tran_type, ins.description, ins.send_to_adv_link, ins.inventory_action);

MERGE t_transaction trn
USING (
        SELECT 'WA'                                             AS system_id
              ,'733'                                            AS tran_type
              ,'MW - Cancelamento de Mensagem de Saída'         AS description
              ,'NO'                                             AS send_to_adv_link
              ,'NONE'                                           AS inventory_action
      ) ins ON ins.system_id = trn.system_id
           AND ins.tran_type = trn.tran_type
           AND ins.description = trn.description
           AND ins.send_to_adv_link = trn.send_to_adv_link
           AND ins.inventory_action = trn.inventory_action
WHEN NOT MATCHED THEN
     INSERT (system_id, tran_type, description, send_to_adv_link, inventory_action)
     VALUES (ins.system_id, ins.tran_type, ins.description, ins.send_to_adv_link, ins.inventory_action);