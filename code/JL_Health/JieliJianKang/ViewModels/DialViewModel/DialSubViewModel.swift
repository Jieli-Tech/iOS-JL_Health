//
//  DialSubViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

import UIKit

@objcMembers class DialSubViewModel: NSObject, LanguagePtl {
  
    
    
    static let shared = DialSubViewModel()
    let itemsArray = BehaviorRelay<[DialSubModel]>(value: [])
    private let updateOldRowIndex = BehaviorSubject<Int>(value: 0)
    private let updateNewRowIndex = BehaviorSubject<Int>(value: 0)
    private var observer:NSKeyValueObservation?
    
    var updateOldRow:Observable<Int>{
        return updateOldRowIndex
    }
    
    var updateNewRow:Observable<Int>{
        return updateNewRowIndex
    }
    
    override init() {
        super.init()
        observer = BridgeHelper.dialCache().observe(\.currentWatch,options: [.new]) { [weak self] obj, change in
            guard let self = self else {return}
            if let _ = change.newValue {
                self.updateCurrentWatch()
            }
        }
        JL_Tools.add(JL_WATCH_FACE_LIST, action: #selector(requireDialsInfo), own: self)
        JL_Tools.add(kJL_BLE_M_ENTITY_CONNECTED, action: #selector(requireDialsInfo), own: self)
        LanguageCls.share().add(self)
    }

    deinit {
        observer?.invalidate()
        observer = nil
        JL_Tools.remove(JL_WATCH_FACE_LIST, own: self)
        JL_Tools.remove(kJL_BLE_M_ENTITY_CONNECTED, own: self)
    }

    
    @objc func requireDialsInfo(){
        let dialCacheList = BridgeHelper.dialCache().getWatchList()
        if dialCacheList.count == 0 {
            JLLogManager.logLevel(.DEBUG, content: "requireDialsInfo error: no watch list")
            return
        }
        var isCircle = false
        if BridgeHelper.dialExtentInfo().shape == 0x01{
            isCircle = true
        }
        let currentName = BridgeHelper.dialCache().currentWatchName()
        guard let (pid,vid) = DialBaseViewModel.shared.getPidVid() else {
            JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
            return
        }
        DialBaseViewModel.shared.getProductInfo(pid: String(pid), vid: String(vid)) { info in
            guard let info = info else {
                JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: info is nil")
                return
            }
            if info.configData.supportDialPayment {
                var dialList = [DialSubModel]()
                for item in dialCacheList {
                    let name = item as? String ?? ""
                    let version = BridgeHelper.dialCache().getVersionOfWatch(name)
                    let uuid = BridgeHelper.dialCache().getUuidOfWatch(name)
                    if uuid == "" {
                        JLLogManager.logLevel(.DEBUG, content: "not Ready requireDialsInfo error: uuid is nil,watch name:\(name)")
                        continue
                    }
                    let dialInfo = DialInfoModel(name: name, version: version, uuid: uuid)
                    let model = DialSubModel(isUsing: currentName == name, isCircle: isCircle, model: dialInfo)
                    JLLogManager.logLevel(.DEBUG, content: "model:\(model.model.uuid),name:\(model.model.name),version:\(model.model.version)")
                    dialList.append(model)
                }
                self.itemsArray.accept(dialList)
            }else{
                let body = DialPageBodyModel(pid: pid, vid: vid, page: 1, size: 20, versions: BridgeHelper.dialCache().getVersionList())
                DialMarketHttp.shared.getDialList(body) { record in
                    guard let record = record else {
                        JLLogManager.logLevel(.DEBUG, content: "requireDialsInfo error: record is nil")
                        AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                        return
                    }
                    var dialList = [DialSubModel]()
                    for item in record.records {
                        let name = item.name.uppercased()
                        let version = item.version
                        let uuid = item.uuid
                        if uuid == "" {
                            JLLogManager.logLevel(.DEBUG, content: "not Ready requireDialsInfo error: uuid is nil,watch name:\(name)")
                            continue
                        }
                        let info = DialInfoModel(name: name, version: version, uuid: uuid)
                        let model = DialSubModel(isUsing: currentName == item.name, isCircle: isCircle, model: info)
                        model.iconUrl = item.icon
                        if dialCacheList.contains(item.name.uppercased()){
                            dialList.append(model)
                        }
                    }
                    self.itemsArray.accept(dialList)
                }
            }
        }
        
    }
    
    
    func updateCurrentWatch(){
       let currentName = BridgeHelper.dialCache().currentWatchName()
        var oldIndex = 0
        var newIndex = 0

        for i in 0..<(itemsArray.value.count) {
            let item = itemsArray.value[i]
            if item.isUsing == true {
                oldIndex = i
            }
            if item.model.name == currentName {
                item.isUsing = true
                newIndex = i
            }else{
                item.isUsing = false
            }
        }

        updateOldRowIndex.onNext(oldIndex)
        updateNewRowIndex.onNext(newIndex)
        
    }
    
    func setCurrentWatch(_ model:DialSubModel){
        let currentName = BridgeHelper.dialCache().currentWatchName()
        if currentName == model.model.name {
            JLLogManager.logLevel(.DEBUG, content: "setCurrentWatch error: current watch is same as model")
            return
        }
        guard let manager = BridgeHelper.getCurrentCmdManager()?.mFlashManager else {
            JLLogManager.logLevel(.DEBUG, content: "updateCurrentWatch error: currentCmdManager is nil")
            return
        }
        let watchPath = "/" + model.model.name
        manager.cmdWatchFlashPath(watchPath, flag: JL_DialSetting.setDial) { flag, size, path, describe in
            DispatchQueue.main.async {
                if flag == 0 {
                    BridgeHelper.dialCache().setCurrrentWatchName(model.model.name)
                }
            }
        }
    }
    
    func getDialInfo(_ uuid:String,_ completion:@escaping (_ dialNetInfo:DialNetInfoModel?)->()) {
        guard let _ = BridgeHelper.getCurrentCmdManager()?.outputDeviceModel() else {
            completion(nil)
            JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
            return
        }
        let (pid,vid) = DialBaseViewModel.shared.getPidVid()!
        DialBaseViewModel.shared.getProductInfo(pid: String(pid), vid: String(vid)) { info in
            guard let info = info else {
                completion(nil)
                return
            }
            let isPay = info.configData.supportDialPayment
            DialMarketHttp.shared.getDialInfo(String(pid), String(vid), uuid, isPay) { dial in
                DispatchQueue.main.async {
                    completion(dial)
                }
            }
        }
        
    }
    
    func getWithoutPayIcon(watchName:String,completion:@escaping (_ iconUrl:String?)->()) {
        guard let (pid,vid) = DialBaseViewModel.shared.getPidVid() else {
            JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
            completion(nil)
            return
        }
        let body = DialPageBodyModel(pid: pid, vid: vid, page: 1, size: 20, versions: BridgeHelper.dialCache().getVersionList())
        DialMarketHttp.shared.getDialList(body) { record in
            guard let record = record else {
                JLLogManager.logLevel(.DEBUG, content: "requireDialsInfo error: record is nil")
                AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                return
            }
            for item in record.records {
                if item.name.uppercased() == watchName.uppercased() {
                    completion(item.icon)
                    return
                }
            }
            completion(nil)
        }
    }
    
    func languageChange() {
        requireDialsInfo()
    }
}
