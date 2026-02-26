//
//  DeviceSubViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/26.
//

import UIKit

@objcMembers class DeviceSubViewModel: NSObject {
    static let shared = DeviceSubViewModel()
    private let disposeBag = DisposeBag()
    private var userIdentify = ""
    private var deviceList = [UserDeviceModel]()
    var updateListCallBack:((_ list:[UserDeviceModel])->())?
    
    override init() {
        super.init()
        userIdentify = User_Http.shareInstance().userPfInfo.identify
        addNote()
        
        if userIdentify.count == 0 {
            User_Http.shareInstance().requestGetUserConfigInfo { [weak self] user in
                guard let self = self else {return}
                self.userIdentify = User_Http.shareInstance().userPfInfo.identify
                DispatchQueue.main.async {
                    self.queryDbDevices()
                    self.queryServerDevices()
                }
            }
            return
        } else {
            queryDbDevices()
        }
        queryServerDevices()
    }
    
    func queryDbDevices(){
        JLDeviceSqliteManager.share().checkout(by: userIdentify) { [weak self] list in
            guard let self = self else {return}
            self.deviceList = list
            if Thread.current.isMainThread {
                self.updateListCallBack?(self.deviceList)
            } else {
                DispatchQueue.main.async {
                    self.updateListCallBack?(self.deviceList)
                }
            }
        }
    }
    
    func reconnectLast(){
        if (BridgeHelper.isConnecting()) {
            JLLogManager.logLevel(.DEBUG, content: "isConnecting")
            return
        }
        if self.deviceList.count > 0 {
            let model = self.deviceList[0]
            if let entity = BridgeHelper.getCurrentMultiple().makeEntity(withUUID: model.uuidStr){
                BridgeHelper.connect(entity)
            }else{
                BridgeHelper.connectMac(model.mac);
            }
            return
        }
        userIdentify = User_Http.shareInstance().userPfInfo.identify
        if userIdentify.count == 0 {
            User_Http.shareInstance().requestGetUserConfigInfo { [weak self] user in
                guard let self = self else {return}
                self.userIdentify = User_Http.shareInstance().userPfInfo.identify
                DispatchQueue.main.async {
                    JLDeviceSqliteManager.share().checkout(by: self.userIdentify) { [weak self] list in
                        guard let _ = self else {return}
                        if list.count > 0 {
                            let model = list[0]
                            if let entity = BridgeHelper.getCurrentMultiple().makeEntity(withUUID: model.uuidStr){
                                BridgeHelper.connect(entity)
                            }else{
                                BridgeHelper.connectMac(model.mac);
                            }
                        }
                    }
                }
            }
            return
        }
        JLDeviceSqliteManager.share().checkout(by: userIdentify) { [weak self] list in
            guard let _ = self else {return}
            if list.count > 0 {
                let model = list[0]
                if let entity = BridgeHelper.getCurrentMultiple().makeEntity(withUUID: model.uuidStr){
                    BridgeHelper.connect(entity)
                }else{
                    BridgeHelper.connectMac(model.mac);
                }
            }
        }
    }
    
    private func addNote(){
        JL_Tools.add("UI_JL_DEVICE_CHANGE", action: #selector(updateDeviceList(_:)), own: self)
        JL_Tools.add("JL_BATTERY", action: #selector(shouldUpdateBattery), own: self)
        JL_Tools.add("UI_DELETE_DEVICE_MODEL", action: #selector(noteDeleteModel(_:)), own: self)
        JL_Tools.add(kJL_BLE_M_ON, action: #selector(reconnectLast), own: self)
    }


  
    
    private func queryServerDevices(){
        DeviceHttp.checkList { resp in
            guard let list = resp else {
                AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                return
            }
            JLLogManager.logLevel(.DEBUG, content: "DeviceHttp.checkList \(list.count)")
            for item in list {
                JLDeviceSqliteManager.share().update(item.beUdm(), time: item.updateTime)
                item.logProperties()
            }
            self.queryDbDevices()
        }
    }

    @objc private func updateDeviceList(_ note:Notification){
        guard let type = note.object as? NSNumber else {return}
        // 2 为已连接的新设备
        if type.int32Value == 2 {
            guard let (pid,vid) = DialBaseViewModel.shared.getPidVid(),let devModel = BridgeHelper.getCurrentCmdManager()?.outputDeviceModel() ,let currentEntity = BridgeHelper.getCurrentEntity() else { return  }
            let model = UserDeviceModel()
            model.devName = currentEntity.mItem
            model.pid = String(format: "%02X",pid)
            model.vid = String(format: "%02X",vid)
            model.uuidStr = currentEntity.mPeripheral.identifier.uuidString
            model.mac = devModel.btAddr
            model.userID = self.userIdentify
            model.advData = currentEntity.mAdvData
            model.type = "手表"
            model.deviceID = ""
            model.androidConfig = ""
            model.explain = ""
            if (model.uuidStr.count == 0 || model.mac.count == 0) {
                JLLogManager.logLevel(.ERROR, content: "updateDeviceList error: uuidStr or mac is nil")
                return
            }
            /*--- OTA通过广播包回连的方式，会生成零时UUID和ble地址用于iphone回连，
                  所以不用存储处于OTA的设备model，因为升级完成后会使用原来的UUID连接。 ---*/
            if currentEntity.mSpecialType == .reconnect {
                model.bleAddr = currentEntity.mBleAddr
                model.mac = currentEntity.mBleAddr
                model.isTemporary = true
                if self.deviceList.count > 0 {
                    self.deviceList.insert(model, at: 0)
                }else{
                    self.deviceList.append(model)
                }
                DispatchQueue.main.async {
                    self.updateListCallBack?(self.deviceList)
                }
                return
            }
            
            JLDeviceSqliteManager.share().checkout(by: model.userID) { list in
                let isExist = list.contains { item in
                    if item.userID == model.userID ,item.mac == model.mac ,item.deviceID.count > 0 {
                        return true
                    }else{
                        return false
                    }
                }
                if !isExist {
                    DeviceHttp.bind { resp in
                        if resp.code == 0 {
                            guard let dict = try?JSONSerialization.jsonObject(with: resp.data, options: .mutableLeaves) as? [String:Any] else {
                                JLLogManager.logLevel(.ERROR, content: "updateDeviceList error: bind error")
                                return
                            }
                            model.deviceID = dict["id"] as? String ?? ""
                            model.androidConfig = dict["androidConfig"] as? String ?? ""
                            model.explain = dict["explain"] as? String ?? ""
                            JLDeviceSqliteManager.share().update(model)
                        
                        }else{
                            JLLogManager.logLevel(.WARN, content: "服务器绑定失败，设备已被其他人绑定")
                            JLDeviceSqliteManager.share().update(model)
                        }
                    }
                }else{
                    guard let md = list.first else {
                        JLLogManager.logLevel(.ERROR, content: "updateDeviceList error: list.first is nil")
                        return
                    }
                    md.devName = currentEntity.mItem
                    md.pid = String(format: "%02X",pid)
                    md.vid = String(format: "%02X",vid)
                    md.uuidStr = currentEntity.mPeripheral.identifier.uuidString
                    md.mac = devModel.bleAddr
                    md.advData = currentEntity.mAdvData
                    md.userID = self.userIdentify
                    JLLogManager.logLevel(.DEBUG, content: "updateDeviceList: \(model)")
                    DeviceHttp .updateConfig(md.beDeviceHttpBody(), result: { resp in
                        if resp.code == 0 {
                            JLLogManager.logLevel(.DEBUG, content: "Server update device success")
                        }else{
                            JLLogManager.logLevel(.ERROR, content: "Server update device error")
                        }
                        JLDeviceSqliteManager.share().update(model)
                    })
                }
            }
            JLDeviceSqliteManager.share().update(model)
            self.deviceList.removeAll(where: {$0.mac == model.mac})
            if self.deviceList.count > 0 {
                self.deviceList.insert(model, at: 0)
            }else{
                self.deviceList.append(model)
            }
            DispatchQueue.main.async {
                self.updateListCallBack?(self.deviceList)
            }
        }else{
            self.updateListCallBack?(self.deviceList)
        }
    }
    
    @objc private func shouldUpdateBattery(){
        self.updateListCallBack?(self.deviceList)
    }
    
    @objc private func noteDeleteModel(_ note:Notification){
        guard let model = note.object as? UserDeviceModel else {
            return
        }
        self.deviceList.removeAll(where: {$0.mac == model.mac})
        self.updateListCallBack?(self.deviceList)
    }
    

}
