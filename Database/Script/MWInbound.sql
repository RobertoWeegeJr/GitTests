USE [AAD]
GO

DECLARE 
    @v_vchMwInboundId NVARCHAR(50) = N'Inbound01',
    @v_vchDescription NVARCHAR(500) = N'Inbound 01';

DELETE FROM t_mw_inbound_rules
 WHERE mw_inbound_id = @v_vchMwInboundId;

DELETE FROM t_mw_inbound_control
 WHERE mw_inbound_id = @v_vchMwInboundId;
 
DELETE FROM t_mw_inbound
 WHERE mw_inbound_id = @v_vchMwInboundId;

INSERT INTO t_mw_inbound (mw_inbound_id, description)
VALUES (@v_vchMwInboundId, @v_vchDescription);

INSERT INTO t_mw_inbound_control (mw_inbound_id, control_type, value)
VALUES (@v_vchMwInboundId, N'DEFAULT_INTEGRATION_PROC', N'usp_mw_inbound_01'),
       (@v_vchMwInboundId, N'ENABLE_SEND_TO_FAILED_MSG_FOR_FAILS', N'TRUE'),
       (@v_vchMwInboundId, N'FAILED_MESSAGE_INTEGRATION_PROC', N'usp_mw_inbound_integrator_failed_message'),
       (@v_vchMwInboundId, N'SEND_TO_FAILED_MSG_REASON', N'INBOUND_MIDDLEWARE_EXCEPTION');
       
DECLARE @v_xmlXsdStockChanged XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="StockChanged">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="StorageUnit">
                                <xs:complexType>
                                    <xs:attribute name="storageUnitCode" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="20"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="slotNumber" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="1"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="ArticleNumberPackSize">
                                <xs:complexType>
                                    <xs:attribute name="articleNumber">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="30"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="packSize">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="4"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="InventoryOrderNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="Time">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="UserID">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="10"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="Difference">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="7"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                        </xs:all>
						<xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
			<xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdSnapshotSaved XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="SnapshotSaved">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="StationName">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="RequestType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="2"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="FileName">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="45"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="8"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdInventoryOrderResult XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="InventoryOrderResult">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="InventoryStatus">
                                <xs:complexType>
                                    <xs:all>
                                        <xs:element name="Status">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="2"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:all>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="StockLines">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="Line" minOccurs="1" maxOccurs="unbounded">
                                            <xs:complexType>
                                                <xs:attribute name="stationName" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="20"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="articleNumber" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="30"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="packSize" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="4"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="quantity" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="4"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="loadUnitCode">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="20"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="status" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="2"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="userID" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="10"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="processingTime" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="19"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                            </xs:complexType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="inventoryOrderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdGohInboundCounting XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="GohInboundCounting">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="LoadUnitCode">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="StationName">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="Quantity">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="7"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdBatchStartPicking XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="BatchStartPicking">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="BatchNumber">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="OrderStartArea">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="15"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdReturnBatchOrderLinesSumOsr XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="ReturnBatchOrderLinesSumOsr">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="BatchNumber">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="StationName">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="OrderLinesForSumOfArticles">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="Line" minOccurs="1" maxOccurs="unbounded">
                                            <xs:complexType>
                                                <xs:attribute name="lineReference" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="20"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="articleNumber" use="required"> 
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="30"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="packSize" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="4"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="quantity" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="7"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="processingTime" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="19"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                            </xs:complexType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdOrderData_IE_OG XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="ReturnMessageForOrderData">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadCarrier" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="30"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadUnitCode">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="DispatchRampNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="5"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EnteredTargetStations" minOccurs="0">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="TargetStationName" minOccurs="1" maxOccurs="unbounded">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="20"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="StartTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EndTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LastReading" minOccurs="0">
                                <xs:complexType>
                                    <xs:attribute name="stationNameLastReading" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="20"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="status" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="1"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderStatus">
                                <xs:complexType>
                                    <xs:all>
                                        <xs:element name="Status">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="2"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:all>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                        <xs:attribute name="sheetNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="3"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="ReturnMessageForOrderData">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadUnitCode">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="DispatchRampNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="5"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EnteredTargetStations" minOccurs="0">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="TargetStationName" minOccurs="1" maxOccurs="unbounded">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="20"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="StartTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EndTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LastReading" minOccurs="0">
                                <xs:complexType>
                                    <xs:attribute name="stationNameLastReading" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="20"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="status" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="1"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderStatus">
                                <xs:complexType>
                                    <xs:all>
                                        <xs:element name="Status">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="2"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:all>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                        <xs:attribute name="sheetNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="3"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="ReturnMessageForOrderData">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadCarrier" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="30"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadUnitCode">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="Weight">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="5"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="DispatchRampNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="5"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EnteredTargetStations" minOccurs="0">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="TargetStationName" minOccurs="1" maxOccurs="unbounded">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="20"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="StartTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EndTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LastReading" minOccurs="0">
                                <xs:complexType>
                                    <xs:attribute name="stationNameLastReading" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="20"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="status" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="1"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderStatus" minOccurs="0">
                                <xs:complexType>
                                    <xs:all>
                                        <xs:element name="Status">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="2"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:all>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                        <xs:attribute name="sheetNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="3"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdOrderData_OA_OB_OC XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="ReturnMessageForOrderData">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="BatchNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadUnitCode">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="DispatchRampNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="5"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EnteredTargetStations" minOccurs="0">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="TargetStationName" minOccurs="1" maxOccurs="unbounded">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="20"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="StartTime" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EndTime" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LastReading" minOccurs="0">
                                <xs:complexType>
                                    <xs:attribute name="stationNameLastReading" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="20"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="status" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="1"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderStatus" minOccurs="0">
                                <xs:complexType>
                                    <xs:all>
                                        <xs:element name="Status">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="2"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:all>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderLinesPickedStandard" minOccurs="0">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="Line" minOccurs="1" maxOccurs="unbounded">
                                            <xs:complexType>
                                                <xs:attribute name="lineReference" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="20"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="articleNumber" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="30"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="packSize" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="4"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="quantity" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="7"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="status" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="2"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="processingTime" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="19"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                            </xs:complexType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                        <xs:attribute name="sheetNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="3"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>',
    @v_xmlXsdOrderData_OL_OM_ON XML = 
'<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xs:element name="WMSMiddleware">
        <xs:complexType>
            <xs:all>
                <xs:element name="ReturnMessageForOrderData">
                    <xs:complexType>
                        <xs:all>
                            <xs:element name="OrderType">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="40"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LoadUnitCode" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="20"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="DispatchRampNumber" minOccurs="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="5"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EnteredTargetStations" minOccurs="0">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="TargetStationName" minOccurs="1" maxOccurs="unbounded">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="20"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="StartTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="EndTime">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                        <xs:maxLength value="19"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>
                            <xs:element name="LastReading" minOccurs="0">
                                <xs:complexType>
                                    <xs:attribute name="stationNameLastReading" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="20"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                    <xs:attribute name="status" use="required">
                                        <xs:simpleType>
                                            <xs:restriction base="xs:string">
                                                <xs:maxLength value="1"/>
                                            </xs:restriction>
                                        </xs:simpleType>
                                    </xs:attribute>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderStatus" minOccurs="0">
                                <xs:complexType>
                                    <xs:all>
                                        <xs:element name="Status">
                                            <xs:simpleType>
                                                <xs:restriction base="xs:string">
                                                    <xs:maxLength value="2"/>
                                                </xs:restriction>
                                            </xs:simpleType>
                                        </xs:element>
                                    </xs:all>
                                </xs:complexType>
                            </xs:element>
                            <xs:element name="OrderLinesPickedExtended">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="Line" minOccurs="1" maxOccurs="unbounded">
                                            <xs:complexType>
                                                <xs:attribute name="lineReference" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="20"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="articleNumber" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="30"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="packSize" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="4"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="quantity" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="7"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="status" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="2"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="userID" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="10"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                                <xs:attribute name="processingTime" use="required">
                                                    <xs:simpleType>
                                                        <xs:restriction base="xs:string">
                                                            <xs:maxLength value="19"/>
                                                        </xs:restriction>
                                                    </xs:simpleType>
                                                </xs:attribute>
                                            </xs:complexType>
                                        </xs:element>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                        </xs:all>
                        <xs:attribute name="orderNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="20"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                        <xs:attribute name="sheetNumber" use="required">
                            <xs:simpleType>
                                <xs:restriction base="xs:string">
                                    <xs:maxLength value="3"/>
                                </xs:restriction>
                            </xs:simpleType>
                        </xs:attribute>
                    </xs:complexType>
                </xs:element>
            </xs:all>
            <xs:attribute name="messageID" use="required">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
                        <xs:maxLength value="200"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:attribute>
        </xs:complexType>
    </xs:element>
</xs:schema>';

INSERT INTO t_mw_inbound_rules (
    mw_inbound_id        ,
    message_type         , 
    order_type           ,
    xml_schema_definition,
    integration_proc     ,
    reintegration_proc   ,
    process_proc         
) VALUES 
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'GOH_BUFFER_CROSSDOCKING',                  @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'GOH_BUFFER_STORAGE',                       @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'GOH_STORAGE_REORGANIZATION',               @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'GOH_STORAGE_CROSSDOCKING',                 @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLAT_DECANTING',                           @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLAT_FLOW_RACK_REPLENISHMENT',             @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'OPEN_GOODS_IN_SINGLE',                     @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'OPEN_GOODS_IN_MIX',                        @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PICKING_TW_DECANTING',                     @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PICKING_TW_FLOW_RACK_REPLENISHMENT',       @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'ECOM_SORTER_PALLET',                       @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PACKING_RETURN',                           @v_xmlXsdOrderData_IA_IB_IC_ID_IH_II_IJ_IL_IM_IN_OJ_OF,     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
 
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLAT_PALLET',                              @v_xmlXsdOrderData_IE_OG,                                   N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'ECOM_DISPATCH',                            @v_xmlXsdOrderData_IE_OG,                                   N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
 
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLAT_CROSSDOCKING',                        @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLAT_CROSSDOCKING_SHR',                    @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PICKING_TW_DISPATCH',                      @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PICKING_TW_DISPATCH_SHR',                  @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLOW_RACK_PICKING',                        @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLOW_RACK_PICKING_SHR',                    @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PACKING_DISPATCH',                         @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PACKING_DISPATCH_SHR',                     @v_xmlXsdOrderData_IF_IG_IO_IP_OD_OE_OH_OI,                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
 
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'GOH_INDUCTION_ADAPTER',                    @v_xmlXsdOrderData_OA_OB_OC,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PICKING_TW_INDUCTION_SINGLE',              @v_xmlXsdOrderData_OA_OB_OC,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'PICKING_TW_INDUCTION_MIXED',               @v_xmlXsdOrderData_OA_OB_OC,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
 
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'FLAT_PICKING_ORDER',                       @v_xmlXsdOrderData_OL_OM_ON,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'GOH_PICKING_ORDER',                        @v_xmlXsdOrderData_OL_OM_ON,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'ReturnMessageForOrderData',    N'ECOM_PICKING_ORDER',                       @v_xmlXsdOrderData_OL_OM_ON,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
 
(@v_vchMwInboundId, N'ReturnBatchOrderLinesSumOsr',  N'OSR_INDUCTION',                            @v_xmlXsdReturnBatchOrderLinesSumOsr,                       N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'BatchStartPicking',            N'BATCHSTART',                               @v_xmlXsdBatchStartPicking,                                 N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'GohInboundCounting',           N'GOH_COUNTING',                             @v_xmlXsdGohInboundCounting,                                N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'InventoryOrderResult',         N'INVENTORY',                                @v_xmlXsdInventoryOrderResult,                              N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'SnapshotSaved',                N'STORAGE_SNAPSHOT',                         @v_xmlXsdSnapshotSaved,                                     N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL),
(@v_vchMwInboundId, N'StockChanged',                 N'STOCK_CORRECTION',                         @v_xmlXsdStockChanged,                                      N'usp_mw_inbound_01', N'usp_mw_inbound_reprocess_01', NULL);
