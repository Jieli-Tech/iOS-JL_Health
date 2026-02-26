//
//  DialHistoryViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/20.
//

import UIKit

class DialHistoryViewModel: NSObject {
    
    let allItemsArray = BehaviorRelay<[DialPayHistoryModel]>(value: [])
    private var page = 0
    private let size = 20
    private var isOver = false
    private var dialId:String = ""
    private var observer:NSKeyValueObservation?

    override init() {
        super.init()
        let (pid,vid) = DialBaseViewModel.shared.getPidVid() ?? (0,0)
        if pid == 0 && vid == 0 {
            JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
            return
        }
        DialBaseViewModel.shared.getProductInfo(pid: String(pid), vid: String(vid)) { [weak self] info in
            guard let self = self,let info = info else {
                return
            }
            self.dialId = info.idString
            loadNextPage(){
                
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
    
    func loadNextPage(_ completion:@escaping ()->Void) {
        if isOver {
            JLLogManager.logLevel(.DEBUG, content: "loadNextPage over")
            self.allItemsArray.accept(self.allItemsArray.value)
            completion()
            return
        }
        page += 1
        DialMarketHttp.shared.checkBuyHistory(self.dialId, page, size) { models in
            guard let models = models else {return}
            if models.records.count < self.size {
                self.isOver = true
            }
            self.allItemsArray.accept(self.allItemsArray.value + models.records)
            completion()
        }
    }
    
    /// 设置当前选中的dial
    /// - Parameter model: dial
    func setCurrentDial(_ model:DialPayHistoryModel){
        let currentDial = BridgeHelper.dialCache().currentWatchName()
        let dialList = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        
        if model.name.uppercased() == currentDial {
            JLLogManager.logLevel(.DEBUG, content: "setCurrentDial error: current dial is same as model")
            return
        }
        
        guard let manager = BridgeHelper.getCurrentCmdManager()?.mFlashManager else {
            JLLogManager.logLevel(.DEBUG, content: "updateCurrentWatch error: currentCmdManager is nil")
            return
        }
        if dialList.contains(model.name.uppercased()) {
            manager.cmdWatchFlashPath("/" + model.name.uppercased(), flag: .setDial) { flag, size, path, describe in
                DispatchQueue.main.async {
                    if flag == 0 {
                        BridgeHelper.dialCache().setCurrrentWatchName(model.name.uppercased())
                    }
                }
            }
        }else{
            DialMarketHttp.shared.requireDownloadDialInfo(model.id) { info in
                guard let info = info else {return}
                AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"),  0.0)
                DialMarketHttp.shared.downloadWatch(info.url) { data, progress, isDone in
                    AlertViewOnWindows.showDialTransport()
                    AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), progress)
                    JLLogManager.logLevel(.DEBUG, content: "downloadWatch: \(info.url) progress: \(progress) done: \(isDone)")
                    if isDone {
                        AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), 1.0)
                        if data == nil {
                            JLLogManager.logLevel(.DEBUG, content: "downloadWatch error: data is nil")
                            AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("下载失败"))
                            return
                        }
                        DispatchQueue.main.async {
                            DialManager.addFile("/" + model.name.uppercased(), content: data!) { flag, progress in
                                DialBaseViewModel.shared.updateStatus(flag: flag, name: model.name,version: model.version,uuid: model.uuid, progress: progress)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateCurrentWatch(){
        allItemsArray.accept(allItemsArray.value)
    }
}
