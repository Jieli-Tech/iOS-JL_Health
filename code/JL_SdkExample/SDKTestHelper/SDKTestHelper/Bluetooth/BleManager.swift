//
//  BleManager.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/26.
//

import UIKit
import JL_OTALib
import JL_HashPair
import JL_AdvParse

class TestObj:NSObject,NSCopying{
    func copy(with zone: NSZone? = nil) -> Any {
        let t = TestObj()
        t.name = self.name
        return t
    }
    var name:String = ""
}
class BleManager: NSObject {
    static let shared = BleManager()
    
    private var _currentEntity:JL_EntityM?
    private var mBleMultiple:JL_BLEMultiple = JL_BLEMultiple()
    private let assist:JL_Assist = JL_Assist()
    private var devices:[JL_EntityM] = []
    private var handleCbp:CBPeripheral?
    private var pMac:String?
    private var testPthread = ECThreadHelper()
    
    var blesArray:[JL_EntityM] {
        get{
            if SettingInfo.getCustomerBleConnect(){
                return devices
            }else{
                return mBleMultiple.blePeripheralArr as! [JL_EntityM]
            }
        }
    }
    
    var currentEntity:JL_EntityM? {
        get{
            if SettingInfo.getCustomerBleConnect(){
                assist.mCmdManager.mEntity
            }else{
                _currentEntity
            }
        }
        set{
            _currentEntity = newValue
        }
    }
    
    var currentCmdMgr:JL_ManagerM? {
        get{
            if SettingInfo.getCustomerBleConnect(){
                assist.mCmdManager
            }else{
                currentEntity?.mCmdManager
            }
        }
    }
    
    
    
    
    
    lazy var centerManager:CBCentralManager = {
        CBCentralManager(delegate: self, queue: .main)
    }()
    
    override init() {
        super.init()
        
        JL_Tools.setLog(true, isMore: false, level: .DEBUG)
        JLAdvParse.setLog(true, isMore: false, level: .INFO)
        JLHashHandler.setLog(true, isMore: false, level: .INFO)
//        JL_OTAManager.setLog(true, isMore: false, level: .INFO)
        
        mBleMultiple.ble_FILTER_ENABLE = true
        mBleMultiple.ble_TIMEOUT = 7
        setPairEnable(true)
        

    }
    
    func setPairEnable(_ status:Bool){
        SettingInfo.savePairEnable(status)
        mBleMultiple.ble_PAIR_ENABLE = status
        assist.mNeedPaired = status
    }
    
    
    func startSearchBle(){
        if SettingInfo.getCustomerBleConnect(){
            devices.removeAll()
            centerManager.scanForPeripherals(withServices: nil, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
        }else{
            mBleMultiple.scanStart()
        }
    }
    func stopSearchBle(){
        if SettingInfo.getCustomerBleConnect(){
            centerManager.stopScan()
        }else{
            mBleMultiple.scanStop()
        }
    }
    
    func mutilUpdateEntity(_ cbp:CBPeripheral){
        if let items = mBleMultiple.bleConnectedArr as? [JL_EntityM]{
            if let entity = items.first(where: {$0.mUUID == cbp.identifier.uuidString}){
                _currentEntity = entity
            }
        }
    }
    
    func connectEntity(_ entity:JL_EntityM){
        stopSearchBle()
        
        if SettingInfo.getCustomerBleConnect(){
            centerManager.connect(entity.mPeripheral, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
        }else{
            mBleMultiple.connectEntity(entity) { st in
                switch st {
                case .bleOFF:
                    JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
                case .connectFail:
                    JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
                case .connecting:
                    break
                case .connectRepeat:
                    break
                case .connectTimeout:
                    JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
                case .connectRefuse:
                    JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
                case .pairFail:
                    JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
                case .pairTimeout:
                    JL_Tools.post(kJL_CONNECT_FAILED, object: entity.mPeripheral)
                case .paired:
                    BleManager.shared.currentEntity = entity
                    SettingInfo.setToHistory(entity.mUUID)
                    break
                case .masterChanging:
                    break
                case .disconnectOk:
                    break
                case .null:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    
    func reConnectWithMac(_ mac:String){
        self.pMac = mac
        self.startSearchBle()
    }
    
    func disconnectEntity(){
        if SettingInfo.getCustomerBleConnect(){
            centerManager.cancelPeripheralConnection(BleManager.shared.handleCbp!)
        }else{
            mBleMultiple.disconnectEntity(BleManager.shared.currentEntity!) { st in
            }
        }
    }
    
    func connectByHistory(){
        if let uuid = SettingInfo.getToHistory(){
            if let entity = BleManager.shared.mBleMultiple.makeEntity(withUUID: uuid){
                if SettingInfo.getCustomerBleConnect(){
                    
                    startSearchBle()
                }else{
                    connectEntity(entity)
                }
            }
        }
    }
    
    
}

extension BleManager:CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            startSearchBle()
        }
        assist.assistUpdate(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if devices.contains(where: {$0.mUUID == peripheral.identifier.uuidString}){
        }else{
            let newEntity = JL_EntityM()
            newEntity.mUUID = peripheral.identifier.uuidString
            newEntity.setBlePeripheral(peripheral)
            if (peripheral.name != nil) {
                if devices.contains(where: {$0.mPeripheral.name == peripheral.name}){
                }else{
                    devices.append(newEntity)
                }
            }
        }
        if pMac !=  nil {
            if let blead = advertisementData["kCBAdvDataManufacturerData"] as? Data{
                if JL_BLEAction.otaBleMacAddress(pMac!, isEqualToCBAdvDataManufacturerData: blead) {
                    self.stopSearchBle()
                    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: DispatchWorkItem(block: {
                        self.centerManager.connect(peripheral, options: [CBConnectPeripheralOptionEnableTransportBridgingKey: true])
                        self.pMac = nil
                    }))
                }
            }
        }
        JL_Tools.post(kJL_BLE_M_FOUND, object: self.blesArray)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        assist.assistDisconnectPeripheral(peripheral)
        assist.mCmdManager.mEntity = nil
        handleCbp = nil
        self.currentEntity = nil
        JL_Tools.post(kJL_BLE_M_ENTITY_DISCONNECTED, object: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        JL_Tools.post(kJL_CONNECT_FAILED, object: peripheral)
    }
    
    
    
}

extension BleManager:CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        assist.assistDiscoverCharacteristics(for: service, peripheral: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        assist.assistUpdate(characteristic, peripheral: peripheral) { isPaired in
            if isPaired {
                SettingInfo.setToHistory(peripheral.identifier.uuidString)
                self.handleCbp = peripheral
                let entity = JL_EntityM()
                entity.setBlePeripheral(self.handleCbp!)
                self.assist.mCmdManager.mEntity = entity
                JL_Tools.post(kJL_BLE_M_ENTITY_CONNECTED, object: peripheral)
            }else{
                self.centerManager.cancelPeripheralConnection(peripheral)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        assist.assistUpdateValue(for: characteristic)
        
       
        
    }
    
    
    
}




