//
//  PackageResViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2024/1/18.
//

import UIKit
import JLWtsToCfgLib
import JL_BLEKit


class TipsVoiceModel{
    var nickName:String = ""
    var file: String = ""
    var path: String = ""
    var type: Bool = false
    init(name: String,file:String,path: String, type: Bool) {
        self.nickName = name;
        self.file = file
        self.path = path
        self.type = type
    }
}

class PackageResViewController: BaseViewController {
    let subTable = UITableView()
    let confirmBtn = UIButton()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    let sendBtn = UIButton()
    var info:JLVoiceReplaceInfo!

    let voiceManager = JLVoicePackageManager.share()
    
    private let items = BehaviorRelay<[TipsVoiceModel]>(value: [])

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Prompt tone replacement"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        view.addSubview(subTable)
        view.addSubview(confirmBtn)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(sendBtn)
        
        
        if let list = _R.path.tipsVoice.listFile(){
            var items = [TipsVoiceModel]()
            for item in list{
                if item.hasSuffix(".wts"){
                    let model = TipsVoiceModel(name:(item as NSString).lastPathComponent.replacingOccurrences(of: ".wts", with: ""),file: (item as NSString).lastPathComponent, path: item, type: true)
                    items.append(model)
                }
            }
            self.items.accept(items)
        }
        if self.items.value.count == 0{
            self.view.makeToast("PCM 2 WTS Record Finish",duration: 3,position: .center)
        }
        

        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 60
        subTable.tableFooterView = UIView()
        subTable.register(PackageCell.self, forCellReuseIdentifier: "tagCell")
        subTable.separatorStyle = .none
        
        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell",cellType: PackageCell.self)){ [weak self](index,item,cell) in
            guard let `self` = self else{return}
            cell.makeModel(item)
            if item.type {
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            cell.handleModelEdit = { cellItem in
                self.handleTouchCellEdt(model: cellItem)
            }
        }.disposed(by: disposeBag)
        
        
        subTable.rx.modelSelected(TipsVoiceModel.self).subscribe { [weak self](model) in
            guard let `self` = self else{return}
            model.type.toggle()
            self.subTable.reloadData()
        }.disposed(by: disposeBag)
        
        confirmBtn.setTitle("Start Package tone.cfg", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.backgroundColor = UIColor.random()
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.layer.masksToBounds = true
        
        statusLab.textColor = .darkText
        statusLab.textAlignment = .center
        statusLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLab.adjustsFontSizeToFitWidth = true
        
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.eHex("#cc4a1c")
        progressView.trackTintColor = UIColor.eHex("d8d8d8")
        
        sendBtn.setTitle("Send tone.cfg", for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.backgroundColor = UIColor.random()
        sendBtn.layer.cornerRadius = 10
        sendBtn.layer.masksToBounds = true
        

        
        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(12)
            make.height.equalTo(200)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(subTable.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        
        statusLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(confirmBtn.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(statusLab.snp.bottom).offset(12)
        }
        
        sendBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(progressView.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        
  
    }
    

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        self.confirmBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            var paths = [String]()
            var names = [String]()
            for item in self.items.value{
                if item.type{
                    paths.append(item.path)
                    names.append(item.nickName)
                }
            }
            if paths.count > 0{
                self.statusLab.text = "Creating..."
                let dt = JLVoicePackageManager.makePks(paths, fileNames: names,info: info)
                self.statusLab.text = "Create success"
                let filePath = _R.path.document+"/tone.cfg"
                try?FileManager.default.removeItem(atPath: filePath)
                FileManager.default.createFile(atPath: filePath, contents: dt)
            }
        }.disposed(by: disposeBag)
 
        sendBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            guard let cmdMgr = BleManager.shared.currentCmdMgr else{return}
            let filePath = _R.path.document+"/tone.cfg"
            let url = URL(fileURLWithPath: filePath)
            guard let dt = try?Data(contentsOf:url) else{return}
            let model = cmdMgr.getDeviceModel()
            
            self.voiceManager.voicesReplacePushDataRequest(cmdMgr, devHandle:model.cardInfo.flashHandle , tonePath: filePath, isReborn: true) { transportStatus, progress in
                switch transportStatus{
                case .transferStart:
                    print("start transfer")
                    break
                case .transferDownload:
                    print("transiting")
                    self.progressView.progress = progress
                    self.statusLab.text = "\(progress*100)%"
                case .transferEnd:
                    print("Transfer complete")
                    self.view.makeToast("Transfer complete",position: .center)
                case .transferOutOfRange:
                    print("Out of range")
                    self.view.makeToast("Out of range",position: .center)
                    break
                case .transferFail:
                    print("transfer fail")
                    self.view.makeToast("transfer fail",position: .center)
                    break
                case .crcError:
                    print("CRC error")
                    self.view.makeToast("CRC error",position: .center)
                    break
                case .outOfMemory:
                    print("out of memory")
                    self.view.makeToast("out of memory",position: .center)
                    break
                case .transferCancel:
                    print("transfer cancel")
                    break
                case .transferNoResponse:
                    print("transfer no response")
                    break
                @unknown default:
                    break
                }
            }
        }.disposed(by: disposeBag)

        
    }
    
    
    private func handleTouchCellEdt(model:TipsVoiceModel){
        let alert = UIAlertController(title: "Rename", 
                                      message: "Rename the index name of the beep",
                                      preferredStyle: .alert)
        alert.addTextField { txfd in
            txfd.placeholder = "input"
            txfd.text = model.nickName
            txfd.clearButtonMode = .whileEditing
            txfd.keyboardType = .default
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", 
                                      style: .cancel))
        
        let confirmAction = UIAlertAction(title: "Confirm",
                                          style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first {
                
                if let enteredText = textField.text, !enteredText.isEmpty {
                    
                    print("Entered text: \(enteredText)")
                    model.nickName = enteredText
                    
                    self?.subTable.reloadData()
                    self?.view.makeToast("Successfully modified")
                    
                } else {
                    
                    self?.view.makeToast("Input text cannot be empty")
                }
            }
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true)
    }

}

fileprivate class PackageCell:UITableViewCell{
    let mainLab = UILabel()
    let subLab = UILabel()
    let editBtn = UIButton()
    var handleModelEdit:((_ model:TipsVoiceModel)->())?
    private var model:TipsVoiceModel?
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainLab)
        contentView.addSubview(subLab)
        contentView.addSubview(editBtn)
        
        mainLab.font = UIFont.systemFont(ofSize: 14)
        mainLab.textColor = UIColor.darkText
        subLab.font = UIFont.systemFont(ofSize: 12)
        subLab.textColor = UIColor.darkText
        
        editBtn.setTitle("Edit", for: .normal)
        editBtn.setTitleColor(.white, for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        editBtn.setTitleColor(.lightGray, for: .highlighted)
        editBtn.layer.cornerRadius = 20
        editBtn.layer.masksToBounds = true
        editBtn.backgroundColor = UIColor.random()
        
        
        mainLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(20)
            make.left.equalTo(editBtn.snp.right)
        }
        
        subLab.snp.makeConstraints { make in
            make.top.equalTo(mainLab.snp.bottom)
            make.height.equalTo(20)
            make.left.equalTo(editBtn.snp.right)
        }
        
        editBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
        }
        
        editBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            if let model = self.model {
                handleModelEdit?(model)
            }
        }.disposed(by: disposeBag)
    }
    
    func makeModel(_ md:TipsVoiceModel){
        self.mainLab.text = "File Name:"+md.file
        self.subLab.text = "nickName:"+md.nickName
        self.model = md
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

