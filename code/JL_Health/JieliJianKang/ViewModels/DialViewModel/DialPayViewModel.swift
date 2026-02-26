//
//  DialPayViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/18.
//

import UIKit

class DialPayViewModel: NSObject {
    let itemsArray = BehaviorRelay<[DialMallModel]>(value: [])
    let allItemsArray = BehaviorRelay<[DialMallModel]>(value: [])
    
    private var listSize:Int = 20
    private var pageIndex:Int = 0
    private var isAllData:Bool = false
    private var observer:NSKeyValueObservation?
    private var dialId:String = ""
        

    
    override init() {
        super.init()
        if let (pid,vid) = DialBaseViewModel.shared.getPidVid() {
            DialBaseViewModel.shared.getProductInfo(pid: String(pid), vid: String(vid)) { [weak self] info in
                guard let self = self, let info = info else {return}
                self.pageIndex += 1
                if info.configData.supportDialPayment {
                    DialMarketHttp.shared.getDialMallList(info.idString, self.pageIndex, self.listSize, false) { list in
                        DispatchQueue.main.async {
                            guard let list = list else {
                                AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                                return
                            }
                            if list.records.count < self.listSize {
                                self.isAllData = true
                            }
                            var itemsArray:[DialMallModel] = []
                            for item in list.records {
                                itemsArray.append(item)
                            }
                            self.allItemsArray.accept(itemsArray)
                            
                            let max = itemsArray.count > 6 ? 6 : itemsArray.count
                            var tmpList:[DialMallModel] = []
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
    }

    deinit {
        observer?.invalidate()
        observer = nil
    }
    
    func updateCurrentWatch(){
        let currentName = BridgeHelper.dialCache().currentWatchName()
        for i in 0..<(itemsArray.value.count) {
            let item = itemsArray.value[i]
            if item.name.uppercased() == currentName {
                item.status = true
            }else{
                item.status = false
            }
        }
        for item in allItemsArray.value {
            if item.name.uppercased() == currentName {
                item.status = true
            }else{
                item.status = false
            }
        }
        itemsArray.accept(itemsArray.value)
        allItemsArray.accept(allItemsArray.value)
    }
    
    //MARK: - Methods
    func setCurrentModel(_ model:DialMallModel){
        let localDialList = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        let currentDialName = BridgeHelper.dialCache().currentWatchName()
        guard let manager = BridgeHelper.getCurrentCmdManager()?.mFlashManager else {
            JLLogManager.logLevel(.DEBUG, content: "updateCurrentWatch error: currentCmdManager is nil")
            return
        }
        if model.name.uppercased() == currentDialName {
            JLLogManager.logLevel(.DEBUG, content: "set current model error: same name")
            return
        }
        if localDialList.contains(model.name.uppercased()) {
            let watchPath = "/" + model.name
            manager.cmdWatchFlashPath(watchPath, flag: JL_DialSetting.setDial) { flag, size, path, describe in
                DispatchQueue.main.async {
                    if flag == 0 {
                        BridgeHelper.dialCache().setCurrrentWatchName(model.name.uppercased())
                    }
                }
            }
            return
        }
        
        DialBaseViewModel.shared.downloadWatch(model) { data in
            guard let data = data else {return}
            let watchPath = "/" + model.name.uppercased()
            DialManager.addFile(watchPath, content: data) { flag, progress in
                DialBaseViewModel.shared.updateStatus(flag: flag, name: model.name,version: model.version,uuid:model.uuid, progress: progress)
            }
        }
    }
 
    func loadNextPage(_ completion: @escaping () -> Void) {
        if isAllData {
            JLLogManager.logLevel(.DEBUG, content: "loadNextPage over")
            completion()
            return
        }
        pageIndex += 1
        DialMarketHttp.shared.getDialMallList(self.dialId, self.pageIndex, self.listSize, false) { list in
            DispatchQueue.main.async {
                guard let list = list else {return}
                if list.records.count < self.listSize {
                    self.isAllData = true
                }
                self.allItemsArray.accept(self.allItemsArray.value + list.records)
                completion()
            }
        }
    }
    
}
