//
//  DialVcViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/22.
//

import UIKit

class DialVcViewModel: NSObject {
    let allItemsArray = BehaviorRelay<[DialPageModel]>(value: [])
    private var page = 0
    private let size = 20
    private var isOver = false
    private var observer:NSKeyValueObservation?

    override init() {
        super.init()
        observer = BridgeHelper.dialCache().observe(\.currentWatch, changeHandler: { obj, value in
            self.updateCurrentWatch()
        })
        JL_Tools.add(JL_WATCH_FACE_LIST, action: #selector(updateCurrentWatch), own: self)
        loadNextPage {
        }
    }

    deinit {
        observer?.invalidate()
        observer = nil
        JL_Tools.remove(JL_WATCH_FACE_LIST, own: self)
    }
    
    @objc private func updateCurrentWatch(){
        allItemsArray.accept(allItemsArray.value)
    }
    
    func setCurrentWatch(_ model:DialPageModel) {
        let currentName = BridgeHelper.dialCache().currentWatchName()
        if model.name.uppercased() == currentName {
            JLLogManager.logLevel(.DEBUG, content: "current watch is: \(currentName) same as: \(model.name)")
            return
        }
        let dialList = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        if dialList.contains(model.name.uppercased()) {
            DialBaseViewModel.shared.chooseWatchOnDevice(model.name)
        } else {
            guard let (pid,vid) = DialBaseViewModel.shared.getPidVid() else {
                JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
                return
            }
            DialMarketHttp.shared.requireDownloadDialInfoFree(model.uuid, pid, vid) { downloadModel in
                guard let downloadModel = downloadModel else {
                    JLLogManager.logLevel(.DEBUG, content: "requireDownloadDialInfoFree error: downloadModel is nil")
                    return
                }
                DialBaseViewModel.shared.downloadWithoutPay(downloadModel) { data in
                    guard let data = data else {
                        JLLogManager.logLevel(.DEBUG, content: "downloadWithoutPay error: data is nil")
                        AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("网络有点问题"),position: .center)
                        return
                    }
                    let name = "/" + model.name.uppercased()
                    DialManager.addFile(name, content: data) { type, progress in
                        DialBaseViewModel.shared.updateStatus(flag: type, name: model.name, version: model.version, uuid: model.uuid, progress: progress)
                    }
                }
            }
        }
    }
    
    func loadNextPage(_ completion:@escaping ()->Void) {
        if isOver {
            JLLogManager.logLevel(.DEBUG, content: "loadNextPage over")
            self.allItemsArray.accept(self.allItemsArray.value)
            completion()
            return
        }
        guard let (pid,vid) = DialBaseViewModel.shared.getPidVid() else {
            JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
            completion()
            return
        }
        let versions = BridgeHelper.dialCache().getVersionList()
        page += 1
        let body = DialPageBodyModel(pid: pid, vid: vid, page: page, size: size, versions: versions)
        DialMarketHttp.shared.getDialList(body) { record in
            if let record = record {
                if record.records.count < self.size {
                    self.isOver = true
                }
                self.allItemsArray.accept(self.allItemsArray.value + record.records)
                completion()
            }
        }
    }
    
    func clear() {
        page = 0
        isOver = false
        allItemsArray.accept([])
    }
}
