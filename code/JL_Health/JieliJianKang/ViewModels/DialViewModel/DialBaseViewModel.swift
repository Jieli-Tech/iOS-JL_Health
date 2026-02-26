//
//  DialBaseViewModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit

@objcMembers class DialBaseViewModel: NSObject {
    static let shared = DialBaseViewModel()
    private let disposeBag = DisposeBag()
    private let productInfo = BehaviorSubject<ProductInfoModel?>(value: nil)

    var productInfoOb:Observable<ProductInfoModel?>{
        return productInfo
    }
    
    /// 获取产品信息
    /// - Parameters:
    ///   - pid: pid
    ///   - vid: vid
    ///   - completion: 回调
    func getProductInfo(pid:String,vid:String,completion:@escaping (ProductInfoModel?)->()) {
        if let info = try? productInfo.value() {
            if info.pid == Int(pid) && info.vid == Int(vid) {
                completion(info)
                return
            }else{
                DialMarketHttp.shared.getProductInfo(pid, vid) { info in
                    self.productInfo.onNext(info)
                    DispatchQueue.main.async {
                        completion(info)
                    }
                }
            }
        }else{
            DialMarketHttp.shared.getProductInfo(pid, vid) { info in
                self.productInfo.onNext(info)
                DispatchQueue.main.async {
                    completion(info)
                }
            }
        }
    }
    
    func getPidVid() -> (Int,Int)? {
        guard let devInfo = BridgeHelper.getCurrentCmdManager()?.outputDeviceModel() else {
            JLLogManager.logLevel(.DEBUG, content: "getDialInfo error: currentCmdManager is nil")
            return nil
        }
        let data = JL_Tools.hex(toData: devInfo.pidvid)
        let vid = JL_Tools.data(toInt: data.subf(0, t: 2))
        let pid = JL_Tools.data(toInt: data.subf(2, t: 2))
        return (pid,vid)
    }
    
    func isSupportPay(_ completion:@escaping (_ isSupport:Bool)->()) {
        guard let (pid,vid) = self.getPidVid() else {
            JLLogManager.logLevel(.ERROR, content: "getPidVid error: currentCmdManager is nil")
            completion(false)
            return
        }
        self.getProductInfo(pid: String(pid), vid: String(vid)) { product in
            completion(product?.configData.supportDialPayment ?? false)
        }
    }
    
    /// 选择设备中已存在的表盘作为当前表盘
    /// - Parameter name: 表盘名称
    func chooseWatchOnDevice(_ name:String){
        guard let manager = BridgeHelper.getCurrentCmdManager()?.mFlashManager else {
            JLLogManager.logLevel(.DEBUG, content: "updateCurrentWatch error: currentCmdManager is nil")
            return
        }
        let watchPath = "/" + name.uppercased()
        manager.cmdWatchFlashPath(watchPath, flag: JL_DialSetting.setDial) { flag, size, path, describe in
            DispatchQueue.main.async {
                if flag == 0 {
                    BridgeHelper.dialCache().setCurrrentWatchName(name.uppercased())
                }
            }
        }
    }
    
    func downloadWithoutPay(_ model:DialFreeDownloadModel,_ completion:@escaping (_ data:Data?)->()) {
        model.logProperties()
        AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"),  0.0)
        AlertViewOnWindows.showDialTransport()
        DialMarketHttp.shared.downloadWatch(model.url) { data, progress, isDone in
            DispatchQueue.main.async {
                AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), progress)
                JLLogManager.logLevel(.DEBUG, content: "downloadWatch: \(model.url) progress: \(progress) done: \(isDone)")
                if isDone {
                    if data == nil {
                        AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("下载失败"))
                    }else{
                        AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), 1.0)
                    }
                    completion(data)
                }
            }
        }
    }
    
    func downloadWatch(_ model:DialMallModel,_ completion:@escaping (_ data:Data?)->()) {
        model.logProperties()
        if model.status == false {
            AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"),  0.0)
            AlertViewOnWindows.showDialTransport()
            DialMarketHttp.shared.payFreeDial(model.id) { status in
                print(status)
                DialMarketHttp.shared.requireDownloadDialInfo(model.id) { info in
                    guard let info = info else {
                        AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("下载失败"))
                        return
                    }
                    DialMarketHttp.shared.downloadWatch(info.url) { data, progress, isDone in
                        AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), progress)
                        JLLogManager.logLevel(.DEBUG, content: "downloadWatch: \(info.url) progress: \(progress) done: \(isDone)")
                        if isDone {
                            if data == nil {
                                AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("下载失败"))
                            } else {
                                AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), 1.0)
                            }
                            DispatchQueue.main.async {
                                completion(data)
                            }
                        }
                    }
                }
            }
        }else{
            AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"),  0.0)
            AlertViewOnWindows.showDialTransport()
            DialMarketHttp.shared.requireDownloadDialInfo(model.id) { info in
                guard let info = info else {
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("下载失败"))
                    return
                }
                DialMarketHttp.shared.downloadWatch(info.url) { data, progress, isDone in
                    AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), progress)
                    JLLogManager.logLevel(.DEBUG, content: "downloadWatch: \(info.url) progress: \(progress) done: \(isDone)")
                    if isDone {
                        if data == nil {
                            AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("下载失败"))
                        } else {
                            AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在下载"), 1.0)
                        }
                        DispatchQueue.main.async {
                            completion(data)
                        }
                    }
                }
            }
        }
    }
    
    func updateStatus(flag:DialOperateType,name:String,version:String,uuid:String,progress:Float) {
        DispatchQueue.main.async {
            switch flag {
                case .noSpace:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("空间不足"))
                case .doing:
                    AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在传输中"), progress)
                case .fail:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("传输失败"))
                case .success:
                    AlertViewOnWindows.getDialTransport().setSuccess()
                    BridgeHelper.getCurrentCmdManager()?.mFlashManager.cmdWatchFlashPath("/" + name.uppercased(), flag: .setDial) { flag, size, path, describe in
                        if flag == 0 {
                            BridgeHelper.dialCache().setCurrrentWatchName(name.uppercased())
                            BridgeHelper.dialCache().addWatchListObject(name.uppercased())
                            BridgeHelper.dialCache().addVersion(version, toWatch: name.uppercased())
                            BridgeHelper.dialCache().setUuidOfWatch(name.uppercased(), uuid: uuid)
                        }
                    }
                case .unnecessary:
                    break
                case .resetFial:
                    break
                case .normal:
                    break
                case .cmdFail:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("文件传输失败"))
                @unknown default:
                    break
            }
        }
    }
    
    func deleteWatch(_ name:String,_ completion:@escaping ()->()) {
        let watchPath = "/" + name.uppercased()
        let watchList = BridgeHelper.dialCache().getWatchList()
        if watchList.count <= 2 {
            JLLogManager.logLevel(.DEBUG, content: "deleteWatch error: no enough watch")
            AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("至少保留两个手表"),position: .center)
            completion()
            return
        }
        self.resetDialBackgroud(name) { status in
            //删除表盘
            DialManager.deleteFile(watchPath) { type, flag in
                if type == .success {
                    BridgeHelper.dialCache().removeWatchListObject(name.uppercased())
                    JLLogManager.logLevel(.DEBUG, content: "delete watch success: \(watchPath)")
                    completion()
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "delete watch error: \(flag)")
                    completion()
                    return
                }
            }
        }
    }
    
    func resetDialBackgroud(_ name:String,_ completion:@escaping (Bool)->()) {
        guard let manager = BridgeHelper.getCurrentCmdManager()?.mFlashManager else {
            JLLogManager.logLevel(.DEBUG, content: "updateCurrentWatch error: currentCmdManager is nil")
            completion(false)
            return
        }
        manager.cmdWatchFlashPath("/" + name.uppercased(), flag: .getDialName) { flag, size, path, describe in
            JLLogManager.logLevel(.DEBUG, content: "flag:\(flag),size:\(size),path:\(String(describing: path)),describe:\(String(describing: describe))")
            if flag == 0 {
                if let path = (path as? NSString)?.lastPathComponent {
                    JLLogManager.logLevel(.DEBUG, content: "check out watch background name: \(path)")
                    if path == "null" {
                        JLLogManager.logLevel(.DEBUG, content: "check out watch background name error: getDialName error")
                        completion(true)
                        return
                    }
                    manager.cmdWatchFlashPath("/null", flag: .activateCustomDial) { flag1, _, _, _ in
                    }
                    DialManager.deleteFile("/" + path.uppercased()) { type, progress in
                        if type == .success {
                            JLLogManager.logLevel(.DEBUG, content: "delete watch background image success: \(path)")
                            completion(true)
                        }else{
                            JLLogManager.logLevel(.ERROR, content: "delete watch background image error: \(path)")
                            completion(false)
                        }
                    }
                }
            }else{
                JLLogManager.logLevel(.ERROR, content: "check out watch background name error: getDialName error")
                completion(false)
            }
        }
    }
        
    override init() {
        super.init()
        JL_Tools.add(kJL_MANAGER_WATCH_FACE, action: #selector(noteWatchFace(_:)), own: self)
        JL_Tools.add(kJL_BLE_M_ENTITY_DISCONNECTED, action: #selector(disconnected), own: self)
    }
    deinit {
        JL_Tools.remove(kJL_MANAGER_WATCH_FACE, own: self)
        JL_Tools.remove(kJL_BLE_M_ENTITY_DISCONNECTED, own: self)
    }
    
    //MARK: - Notification
    @objc func noteWatchFace(_ noti:Notification) {
        JLLogManager.logLevel(.DEBUG, content: "noteWatchFace: \(noti)")
        let dict = noti.object as? [String:Any] ?? [:]
        let name = (dict[kJL_MANAGER_KEY_OBJECT] as? String ?? "").replacingOccurrences(of: "/", with: "")
        BridgeHelper.dialCache().setCurrrentWatchName(name.uppercased())
    }
    @objc func disconnected(_ noti:Notification) {
        JLLogManager.logLevel(.DEBUG, content: "disconnected: \(noti)")
        if AlertViewOnWindows.getDialTransport().isHidden == false {
            AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("断开连接"))
        }
    }
}
