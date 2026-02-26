//
//  Ota4GView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/1/9.
//

import UIKit
import SnapKit
import ZipZap
import Toast_Swift
import SwiftyAttributes



@objcMembers class Ota4GView: UIView {
    
    
    let otaUpdateTips = Ota4GUpdateTipsView(frame: .zero)
    let otaStatusView = Ota4GFinishView(frame: .zero)
    let otaProgressView = Ota4GUpdateProgressView(frame: .zero)
    var targetDict:NSDictionary?
    var nowVersion:String = ""
    var cmdManager:JL_ManagerM?
    var viewController:UIViewController?
    var handleFinish:(()->())?
    var handleCancel:(()->())?
    
    private let bgView = UIView()
    private var updateFilePath = ""
    private var tapgest = UITapGestureRecognizer()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.3
        addSubview(bgView)
        addSubview(otaUpdateTips)
        addSubview(otaProgressView)
        addSubview(otaStatusView)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        otaUpdateTips.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(196)
        }
        
        otaProgressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(148)
        }
        
        otaStatusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(196)
        }
        
        otaStatusView.isHidden = true
        otaProgressView.isHidden = true
        
        initData1()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func initData1(){
        JL4GUpgradeManager.share().delegate = self
        tapgest = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        
        otaUpdateTips.cancelBtn.addTarget(self, action: #selector(handleCancelBtn), for: .touchUpInside)
        
        otaUpdateTips.confirmBtn.addTarget(self, action: #selector(handleConfirmBtn), for: .touchUpInside)
            
        otaStatusView.confirmBtn.addTarget(self, action: #selector(handleStatusConfrimBtn), for: .touchUpInside)
        
        self.addNote()
    }
    
    private func addNote(){
        JL_Tools.add("UI_JL_DEVICE_CHANGE", action: #selector(handleNote(note:)), own: self)
    }
    
    @objc func handleCancelBtn(){
        handleCancel?()
        self.isHidden = true
    }
    
    @objc func handleNote(note:NSNotification){
        let type = (note.object as! NSNumber).intValue
        if type == 0 || type == 1 || type == 4{
            self.otaStatusView.isHidden = true
            self.otaUpdateTips.isHidden = false
            self.otaProgressView.isHidden = true
            self.isHidden = true
        }
    }

    @objc func handleConfirmBtn(){
        self.otaUpdateTips.isHidden = true
        self.otaProgressView.isHidden = false
        //            let updatePath1 = JL_Tools.create(on:.documentDirectory, middlePath: "/4GModel", file: "4G.zip")
        //            self.unzipFile(updatePath1)
        if let urlStr = self.targetDict?["url"] as? String{
            if var pt = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first{
                pt += "/4GModel"
                try?FileManager.default.removeItem(atPath: pt)
            }
            let updatePath = JL_Tools.create(on:.documentDirectory, middlePath: "/4GModel", file: "4G.zip")
            JL_Tools.removePath(updatePath)
            User_Http.shareInstance().downloadUrl(urlStr, path: updatePath) { progress, result in
                DispatchQueue.main.async {
                    if result == .download{
                        self.otaProgressView.progressLab.text = LanguageCls.localizableTxt("下载固件")
                        self.otaProgressView.progressView.progress = progress
                    }
                    if result == .success{
                        self.unzipFile(updatePath)
                    }
                    if result == .fail{
                        self.otaProgressView.progressLab.text = LanguageCls.localizableTxt("下载失败!")
                        self.otaProgressView.progress = 0
                    }
                }
            }
        }
    }
    
    @objc func handleStatusConfrimBtn(){
        self.otaStatusView.isHidden = true
        self.otaUpdateTips.isHidden = false
        self.otaProgressView.isHidden = true
        self.isHidden = true
        self.handleFinish?()
    }
    
    private func unzipFile(_ zipFilePath:String){
        
        // 替换为你要解压缩到的目标文件夹路径
        let destinationFolderPath = zipFilePath.replacingOccurrences(of: "/4G.zip", with: "/4G")
        try?FileManager.default.removeItem(atPath: destinationFolderPath)
        try?FileManager.default.createDirectory(atPath: destinationFolderPath, withIntermediateDirectories: true)
        FatfsObject.unzipFile(atPath: zipFilePath, toDestination: destinationFolderPath)
        listFilesInDirectory(atPath: destinationFolderPath)
    }
    
    private func listFilesInDirectory(atPath path: String) {
        let fileManager = FileManager.default
        do {
            // 获取指定路径下的所有文件和文件夹
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            for item in contents {
                let itemPath = (path as NSString).appendingPathComponent(item)
                
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 处理文件夹
                        JLLogManager.logLevel(.DEBUG, content: "文件夹：\(itemPath)")
                        // 递归遍历文件夹
                        listFilesInDirectory(atPath: itemPath)
                    } else {
                        // 处理文件
                        if itemPath.hasSuffix(".json"){
                            guard let dt = try?Data(contentsOf: URL(fileURLWithPath: itemPath)) else{
                                return
                            }
                            guard let dict = try?JSONSerialization.jsonObject(with: dt, options: .mutableContainers) as? NSDictionary,let arr = dict["map"] as? Array<Dictionary<String,String>> else {
                                return
                            }
                            var p:String? = nil
                            for updateDict in arr{
                                if updateDict["version"] == nowVersion{
                                    p = (path as NSString).appendingPathComponent(updateDict["pakage"]!)
                                    break
                                }
                            }
                            if let p = p{
                                self.startUpdate(p)
                            }else{
                                self.viewController?.view.makeToast("未找到固件",position: .center)
                            }
                        }
                    }
                }
            }
        } catch {
            JLLogManager.logLevel(.DEBUG, content: "Error: \(error.localizedDescription)")
        }
    }
    
    private func startUpdate(_ path:String){
        otaUpdateTips.isHidden = true
        guard let dt = try?Data(contentsOf: URL(fileURLWithPath: path)),let mgr = cmdManager else{
            return
        }
        JL4GUpgradeManager.share().cmdStartUpgrade4G(mgr, data: dt)
    }
    
}

extension Ota4GView:JL4GUpgradeDelegate{
    func jl4GUpgradeResult(_ mgr: JL4GUpgradeManager, status: JL4GUpgradeStatus, progress: Float, code: UInt8, error: Error?) {
        switch status {
        case .finish:
            if code != 0x00{
                self.otaProgressView.progressLab.text = "升级失败"+(error?.localizedDescription ?? "")
            }else{
                self.otaProgressView.isHidden = true
                self.otaStatusView.isHidden = false
            }
            self.addGestureRecognizer(tapgest)
            break
        case .start:
            self.otaProgressView.progressLab.text = LanguageCls.localizableTxt("开始升级")
            break
        case .transporting:
            otaProgressView.progress = progress
        case .deviceProcessing:
            otaProgressView.progress = 0.99
            break
        @unknown default:
            break
        }
    }
    
    func jl4GGetDeviceInfo(_ g4Model: JLPublic4GModel) {
         //TODO: 打印 4G 模块升级信息，业务未做拓展，此回调暂未使用
        g4Model.logProperties()
    }
    
    @objc func tapAction(){
        self.isHidden = true
        self.removeGestureRecognizer(tapgest)
        self.otaStatusView.isHidden = true
        self.otaUpdateTips.isHidden = false
        self.otaProgressView.isHidden = true
    }
}


@objcMembers class Ota4GUpdateTipsView:UIView{
    var titleLab = UILabel()
    var contentLab = UILabel()
    var lineView = UIView()
    var lineView1 = UIView()
    var cancelBtn = UIButton()
    var confirmBtn = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLab)
        addSubview(contentLab)
        addSubview(lineView)
        addSubview(cancelBtn)
        addSubview(confirmBtn)
        addSubview(lineView1)
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        titleLab.textColor = UIColor.eHex("#242424")
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textAlignment = .center
        
        contentLab.font = UIFont.systemFont(ofSize: 15)
        contentLab.numberOfLines = 0
        contentLab.textColor = UIColor.eHex("#242424")
        
        lineView.backgroundColor = UIColor.eHex("#F7F7F7")
        lineView1.backgroundColor = UIColor.eHex("#F7F7F7")
        
        cancelBtn.setTitle(LanguageCls.localizableTxt("取消"), for: .normal)
        cancelBtn.setTitleColor(UIColor.eHex("#558CFF"), for: .normal)
        cancelBtn.setTitleColor(.lightGray, for: .highlighted)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        confirmBtn.setTitle(LanguageCls.localizableTxt("升级"), for: .normal)
        confirmBtn.setTitleColor(UIColor.eHex("#558CFF"), for: .normal)
        confirmBtn.setTitleColor(.lightGray, for: .highlighted)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        
        contentLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(lineView.snp.top).offset(10)
        }
        
        lineView.snp.makeConstraints { make in
            make.bottom.equalTo(confirmBtn.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        lineView1.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalTo(cancelBtn.snp.right)
            make.width.equalTo(1)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(confirmBtn.snp.width)
            make.right.equalTo(confirmBtn.snp.left)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(cancelBtn.snp.right)
            make.width.equalTo(cancelBtn.snp.width)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    
    }
    
    
    func updateView(title: String, content: String){
        titleLab.text = title
        let attributedText = content.attributedString
        let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        contentLab.attributedText = attributedText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objcMembers class Ota4GUpdateProgressView:UIView{
    let progressLab = UILabel()
    let progressView = UIProgressView()
    let tipsLab = UILabel()
    private var _progress: Float = 0
    var progress: Float {
        get{
            _progress
        }
        set{
            _progress = newValue
            self.progressLab.text = LanguageCls.localizableTxt("升级进度") + " \(Int(_progress * 100))%"
            self.progressView.progress = _progress
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true
        addSubview(progressLab)
        addSubview(progressView)
        addSubview(tipsLab)
        
        progressLab.font = UIFont.systemFont(ofSize: 16)
        progressLab.textColor = UIColor.eHex("#242424")
        progressLab.textAlignment = .center
        progressLab.adjustsFontSizeToFitWidth = true
        
        progressView.progress = 0
        progressView.progressTintColor = UIColor.eHex("#558CFF")
        progressView.trackTintColor = UIColor.eHex("#D8D8D8")
        
        tipsLab.text = LanguageCls.localizableTxt("升级过程中，请保持蓝牙和网络打开状态")
        tipsLab.textAlignment = .center
        tipsLab.adjustsFontSizeToFitWidth = true
        tipsLab.font = UIFont.systemFont(ofSize: 14)
        tipsLab.textColor = UIColor.eHex("#919191")
        
        progressLab.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(32)
            make.height.equalTo(24)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(28)
            make.height.equalTo(3)
            make.centerY.equalToSuperview()
        }
        
        tipsLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(progressView.snp.bottom).offset(16)
        }
        

        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



@objcMembers class Ota4GFinishView:UIView{
    private let centerImgv = UIImageView()
    private let finishLab = UILabel()
    private let lineView = UIView()
    let confirmBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        addSubview(centerImgv)
        addSubview(finishLab)
        addSubview(lineView)
        addSubview(confirmBtn)
        
        centerImgv.image = UIImage(named: "icon_success_nol")
        
        finishLab.text = LanguageCls.localizableTxt("升级完成")
        finishLab.font = UIFont.systemFont(ofSize: 16)
        finishLab.textColor = UIColor.eHex("#242424")
        finishLab.textAlignment = .center
        
        lineView.backgroundColor = UIColor.eHex("#F7F7F7")
        
        confirmBtn.setTitle(LanguageCls.localizableTxt("确定"), for: .normal)
        confirmBtn.setTitleColor(UIColor.eHex("#558CFF"), for: .normal)
        confirmBtn.setTitleColor(.lightGray, for: .highlighted)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        centerImgv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
            make.top.equalToSuperview().inset(24)
        }
        
        finishLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(centerImgv.snp.bottom).offset(12)
            make.height.equalTo(24)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top)
            make.height.equalTo(1)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



public extension UIColor{
    
    class func eHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        var color:Int64 = 0
        scanner.scanHexInt64(&color)
        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
