//
//  OTAViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/9.
//

import UIKit

class OTAViewController: BaseViewController {
  
    let selectFileBtn = UIButton()
    let initializeBtn = UIButton()
    let startOtaBtn = UIButton()
    let stopOtaBtn = UIButton()
    let rebootBtn = UIButton()
    let fileLab = UILabel()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    let progressLab = UILabel()
    let fileListView = FileLoadView()
    
    // MARK: - OTA 相关
    var otaManager: JL_OTAManager?
    var otaFilePath = ""
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        otaManager = BleManager.shared.currentCmdMgr?.mOTAManager
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChange(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "OTA"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        
        self.view.addSubview(selectFileBtn)
        self.view.addSubview(initializeBtn)
        self.view.addSubview(startOtaBtn)
        self.view.addSubview(stopOtaBtn)
        self.view.addSubview(rebootBtn)
        self.view.addSubview(fileLab)
        self.view.addSubview(statusLab)
        self.view.addSubview(progressView)
        self.view.addSubview(progressLab)
        self.view.addSubview(fileListView)
        
        selectFileBtn.setTitle("Select OTA file", for: .normal)
        selectFileBtn.setTitleColor(UIColor.black, for: .normal)
        selectFileBtn.backgroundColor = UIColor.eHex("ff4d00")
        selectFileBtn.setTitleColor(UIColor.white, for: .normal)
        selectFileBtn.layer.cornerRadius = 8
        selectFileBtn.clipsToBounds = true
        
        initializeBtn.setTitle("initialize", for: .normal)
        initializeBtn.setTitleColor(UIColor.black, for: .normal)
        initializeBtn.backgroundColor = UIColor.eHex("9fcd00")
        initializeBtn.setTitleColor(UIColor.white, for: .normal)
        initializeBtn.layer.cornerRadius = 8
        initializeBtn.clipsToBounds = true
        
        startOtaBtn.setTitle("start OTA", for: .normal)
        startOtaBtn.setTitleColor(UIColor.black, for: .normal)
        startOtaBtn.backgroundColor = UIColor.eHex("00ffcd")
        startOtaBtn.setTitleColor(UIColor.white, for: .normal)
        startOtaBtn.layer.cornerRadius = 8
        startOtaBtn.clipsToBounds = true
        
        stopOtaBtn.setTitle("stop OTA", for: .normal)
        stopOtaBtn.setTitleColor(UIColor.black, for: .normal)
        stopOtaBtn.backgroundColor = UIColor.eHex("00ffcd")
        stopOtaBtn.setTitleColor(UIColor.white, for: .normal)
        stopOtaBtn.layer.cornerRadius = 8
        stopOtaBtn.clipsToBounds = true
        
        rebootBtn.setTitle("reboot", for: .normal)
        rebootBtn.setTitleColor(UIColor.black, for: .normal)
        rebootBtn.backgroundColor = UIColor.eHex("00b2ff")
        rebootBtn.setTitleColor(UIColor.white, for: .normal)
        rebootBtn.layer.cornerRadius = 8
        rebootBtn.clipsToBounds = true
        
        fileLab.text = "No file selected"
        fileLab.textAlignment = .center
        fileLab.textColor = UIColor.eHex("002200")
        fileLab.font = UIFont.boldSystemFont(ofSize: 16)
        
        statusLab.text = "OTA not started yet"
        statusLab.textAlignment = .left
        statusLab.textColor = UIColor.eHex("002200")
        statusLab.font = UIFont.boldSystemFont(ofSize: 16)
        
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.eHex("#cc4a1c")
        progressView.trackTintColor = UIColor.eHex("d8d8d8")
        
        progressLab.text = "0%"
        progressLab.textAlignment = .center
        progressLab.textColor = UIColor.eHex("#002200")
        progressLab.font = UIFont.boldSystemFont(ofSize: 16)
        
        fileListView.isHidden = true
        
        selectFileBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        fileLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(selectFileBtn.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        initializeBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(fileLab.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        statusLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(initializeBtn.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(progressLab.snp.left)
            make.top.equalTo(statusLab.snp.bottom).offset(10)
        }
        progressLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.width.equalTo(70)
            make.centerY.equalTo(progressView.snp.centerY)
        }
        
        startOtaBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(progressView.snp.bottom).offset(30)
            make.height.equalTo(40)
        }
        
        stopOtaBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(startOtaBtn.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        rebootBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(stopOtaBtn.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        fileListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
        
        
    }
    
    override func disconnectStatusChange(_ notification: Notification) {
    }
    
    override func initData() {
        super.initData()
        self.navigationView.leftBtn.rx.tap.subscribe { [weak self]_ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        selectFileBtn.rx.tap.subscribe { [weak self]_ in
            self?.fileListView.isHidden = false
            self?.fileListView.showFiles(_R.path.otas)
        }.disposed(by: disposeBag)
        
        fileListView.handleBlock = { [weak self] (file) in
            self?.fileLab.text = (file as NSString).lastPathComponent
            self?.otaFilePath = file
        }
        
        initializeBtn.rx.tap.subscribe { [weak self]_ in
            self?.otaManager?.cmdTargetFeature()
        }.disposed(by: disposeBag)
        
        startOtaBtn.rx.tap.subscribe { [weak self]_ in
            guard let self = self else { return }
            guard let dt = try?Data(contentsOf: URL(fileURLWithPath: self.otaFilePath)) else {return}
            self.otaManager?.cmdOTAData(dt, result: { result, progress in
                self.handleOtaResult(result, progress)
            })
        }.disposed(by: disposeBag)
        
        stopOtaBtn.rx.tap.subscribe { [weak self]_ in
            guard let self = self else { return }
            
            self.otaManager?.cmdOTACancelResult()
            
        }.disposed(by: disposeBag)
        
        rebootBtn.rx.tap.subscribe { [weak self]_ in
            self?.otaManager?.cmdRebootDevice()
        }.disposed(by: disposeBag)
        
    }
    
    
    //MARK: - 响应升级过程中的回调内容
    func handleOtaResult(_ status:JL_OTAResult,_ progress:Float){
        switch status {
        case .success:
            self.view.makeToast("OTA Success!",position: .center)
            self.statusLab.text = "OTA Success!"
        case .fail:
            self.view.makeToast("OTA fail",position: .center)
        case .dataIsNull:
            self.view.makeToast("OTA data nil",position: .center)
        case .commandFail:
            self.view.makeToast("OTA Command fail",position: .center)
        case .seekFail:
            self.view.makeToast("OTA addressing failed",position: .center)
        case .infoFail:
            self.view.makeToast("Failed to obtain information",position: .center)
        case .lowPower:
            self.view.makeToast("device low power",position: .center)
        case .enterFail:
            self.view.makeToast("Entry failed",position: .center)
        case .upgrading:
            self.statusLab.text = "Upgrading (Phase 2)"
            self.progressLab.text = "\(Int(progress * 100))%"
            self.progressView.progress = progress
        case .reconnect:
            //TODO: 开发者需要根据设备 uuid 去回连设备，手表系列不采取此方法回连，具体更全面的 OTA 升级例子可参考：https://doc.zh-jieli.com/Apps/iOS/ota/zh-cn/master/index.html
            self.view.makeToast("reconnect",position: .center)
            break
        case .reboot:
            self.view.makeToast("Restarting",position: .center)
            self.statusLab.text = "Restarting"
            otaManager?.cmdRebootForceDevice()
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: DispatchWorkItem(block: { [weak self] in
                self?.statusLab.text = "Restart successful"
                self?.navigationController?.popViewController(animated: true)
            }))
        case .preparing:
            self.statusLab.text = "Upgrading (Phase 1)"
            self.progressLab.text = "\(Int(progress * 100))%"
            self.progressView.progress = progress
        case .prepared:
            self.statusLab.text = "Ready to complete"
            self.view.makeToast("Ready to complete",position: .center)
        case .failVerification:
            self.view.makeToast("Verification failed",position: .center)
        case .failCompletely:
            self.view.makeToast("OTA fail",position: .center)
        case .failKey:
            self.view.makeToast("Key Verification failed",position: .center)
        case .failErrorFile:
            self.view.makeToast("Wrong OTA file",position: .center)
        case .failUboot:
            self.view.makeToast("u-boot Verification failed",position: .center)
        case .failLenght:
            self.view.makeToast("OTA file len error",position: .center)
        case .failFlash:
            self.view.makeToast("OTA write fail",position: .center)
        case .failCmdTimeout:
            self.view.makeToast("command timeout",position: .center)
        case .failSameVersion:
            self.view.makeToast("OTA fail（same file）",position: .center)
        case .failTWSDisconnect:
            self.view.makeToast("OTA fail（TWS not all connected）",position: .center)
        case .failNotInBin:
            self.view.makeToast("OTA fail（not in file bin）",position: .center)
        case .reconnectWithMacAddr:
            //TODO: 开发者需要根据设备 mac addr 去回连设备
            self.view.makeToast("reconnect",position: .center)
            BleManager.shared.reConnectWithMac(otaManager?.bleAddr ?? "")
            //这里若使用 JLSDK 的蓝牙连接，则 SDK 内部处理了回连内容，开发者只需要执行 mBleMutil 类的搜索设备方法即可
        case .unknown:
            self.view.makeToast("unKnow",position: .center)
        @unknown default:
            break
        }
    }
    
    //MARK: - 重连
    @objc func connectStatusChange(_ notification:Notification){
        
        if((BleManager.shared.currentEntity) != nil){
            
            if !SettingInfo.getCustomerBleConnect(){
                BleManager.shared.mutilUpdateEntity(notification.object as! CBPeripheral)
            }
            otaManager = BleManager.shared.currentCmdMgr?.mOTAManager
            navigationView.leftBtn.setTitle("Connected", for: .normal)
            self.view.makeToast("initial...",duration: 5,position: .center)
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: DispatchWorkItem(block: { [weak self] in
                BleManager.shared.currentCmdMgr?.cmdTargetFeatureResult({ (st, sn, dt) in
                    guard let manager = self?.otaManager else {return}
                    if manager.otaStatus == .force,let path = self?.otaFilePath{
                        
                        //继续完成 OTA 升级
                        guard let dt = try?Data(contentsOf: URL(fileURLWithPath: path)) else {return}
                        manager.cmdOTAData(dt, result: { result, progress in
                            self?.handleOtaResult(result, progress)
                        })
                        
                    }
                })
            }))
            
        }
    }
    

}
