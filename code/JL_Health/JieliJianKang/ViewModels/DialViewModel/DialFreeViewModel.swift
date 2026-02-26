//
//  DialFreeViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit

class DialFreeViewModel: NSObject {
    let itemsArray = BehaviorRelay<[DialFreeModel]>(value: [])
    let allItemsArray = BehaviorRelay<[DialFreeModel]>(value: [])
    
    private var listSize:Int = 20
    private var pageIndex:Int = 0
    private var isAllData:Bool = false
    private var observer:NSKeyValueObservation?
    
    
    override init() {
        super.init()
        if let devInfo = BridgeHelper.getCurrentCmdManager()?.outputDeviceModel() {
            let data = JL_Tools.hex(toData: devInfo.pidvid)
            let vid = JL_Tools.data(toInt: data.subf(0, t: 2))
            let pid = JL_Tools.data(toInt: data.subf(2, t: 2))
            DialBaseViewModel.shared.getProductInfo(pid: String(pid), vid: String(vid)) { [weak self] info in
                guard let self = self else { return }
                guard let info = info else {
                    return
                }
                self.pageIndex += 1
                if info.configData.supportDialPayment {
                    DialMarketHttp.shared.getDialMallList(info.idString, self.pageIndex, self.listSize, true) { list in
                        DispatchQueue.main.async {
                            guard let list = list else {
                                AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                                return
                            }
                            if list.records.count < self.listSize {
                                self.isAllData = true
                            }
                            var itemsArray:[DialFreeModel] = []
                            for item in list.records {
                                let model = DialFreeModel(model: item)
                                model.btnType = self.getType(item)
                                itemsArray.append(model)
                            }
                            self.allItemsArray.accept(itemsArray)
                            
                            let max = itemsArray.count > 6 ? 6 : itemsArray.count
                            var tmpList:[DialFreeModel] = []
                            for i in 0..<max {
                                tmpList.append(itemsArray[i])
                            }
                            self.itemsArray.accept(tmpList)
                        }
                    }
                }
            }
        }
        observer = BridgeHelper.dialCache().observe(\.currentWatch, changeHandler: { obj, value in
            self.updateCurrentWatch()
        })
        JL_Tools.add(JL_WATCH_FACE_LIST, action: #selector(updateCurrentWatch), own: self)
    }
    deinit {
        observer?.invalidate()
        observer = nil
        JL_Tools.remove(JL_WATCH_FACE_LIST, own: self)
    }
    

    
    
    //MARK: - Methods
    @objc func updateCurrentWatch(){
        let currentName = BridgeHelper.dialCache().currentWatchName()
        for i in 0..<(itemsArray.value.count) {
            let item = itemsArray.value[i]
            if item.model.name.uppercased() == currentName {
                item.btnType = self.getType(item.model)
            }else{
                item.btnType = self.getType(item.model)
            }
        }
        
        for i in 0..<(allItemsArray.value.count) {
            let item = allItemsArray.value[i]
            if item.model.name.uppercased() == currentName {
                item.btnType = self.getType(item.model)
            }else{
                item.btnType = self.getType(item.model)
            }
        }
        itemsArray.accept(itemsArray.value)
        allItemsArray.accept(allItemsArray.value)
    }
    
    func getNextPage(_ completion:@escaping ()->()) {
        if isAllData {
            completion()
            return
        }
        if let devInfo = BridgeHelper.getCurrentCmdManager()?.outputDeviceModel() {
            let data = JL_Tools.hex(toData: devInfo.pidvid)
            let vid = JL_Tools.data(toInt: data.subf(0, t: 2))
            let pid = JL_Tools.data(toInt: data.subf(2, t: 2))
            
            DialBaseViewModel.shared.getProductInfo(pid: String(pid), vid: String(vid)) { [weak self] info in
                guard let self = self, let info = info else {
                    DispatchQueue.main.async {
                        completion()
                    }
                    return
                }
                self.pageIndex += 1
                DialMarketHttp.shared.getDialMallList(info.idString, self.pageIndex, self.listSize, true) { list in
                    DispatchQueue.main.async {
                        guard let list = list else {
                            self.isAllData = true
                            completion()
                            return
                        }
                        if list.records.count < self.listSize {
                            self.isAllData = true
                        }
                        var itemsArray:[DialFreeModel] = []
                        for item in list.records {
                            let model = DialFreeModel(model: item)
                            model.btnType = self.getType(item)
                            itemsArray.append(model)
                        }
                        completion()
                        self.allItemsArray.accept(itemsArray)
                    }
                }
            }
        }else{
            completion()
        }
    }
    
    func setCurrentWatch(_ model:DialFreeModel){
        let currentName = BridgeHelper.dialCache().currentWatchName()
        if currentName == model.model.name.uppercased() {
            JLLogManager.logLevel(.DEBUG, content: "setCurrentWatch error: current watch is same as model")
            return
        }
        if model.btnType == .needDownload || model.btnType == .update {
            DialBaseViewModel.shared.downloadWatch(model.model) { (data) in
                guard let data = data else {
                    AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                    return
                }
                let watchPath = "/" + model.model.name.uppercased()
                if model.btnType == .needDownload {
                    DialManager.addFile(watchPath, content: data) { flag, progress in
                        DialBaseViewModel.shared.updateStatus(flag: flag, name: model.model.name,version: model.model.version,uuid: model.model.uuid, progress: progress)
                    }
                }
                if model.btnType == .update {
                    DialManager.repaceFile(watchPath, content: data) { flag, progress in
                        DialBaseViewModel.shared.updateStatus(flag: flag, name: model.model.name,version: model.model.version,uuid: model.model.uuid, progress: progress)
                    }
                }
            }
            return
        }
        
        DialBaseViewModel.shared.chooseWatchOnDevice(model.model.name)
    }
    
    
    //MARK: - Private
    private func getType(_ model:DialMallModel) -> DialFreeCellBtnType {
        let cacheList = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        let currentName = BridgeHelper.dialCache().currentWatchName()
        if currentName == model.name.uppercased() {
            return .using
        }else{
            if cacheList.contains(model.name.uppercased()) {
                let version = BridgeHelper.dialCache().getVersionOfWatch(model.name.uppercased())
                if version == model.version.uppercased() {
                    return .notUsing
                }else{
                    return .update
                }
            }else{
                if model.status {
                    return .needDownload
                } else {
                    return .free
                }
            }
        }
    }

}
