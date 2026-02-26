//
//  SmallFileViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/8.
//

import UIKit

class SmallFileViewController: BaseViewController {
    
    let opLab = UILabel()
    let subTable = UITableView()
    let subItemArray = BehaviorRelay<[String]>(value:[])
    
    let listLab = UILabel()
    let fileListTable = UITableView()
    let fileItemArray = BehaviorRelay<[JLModel_SmallFile]>(value:[])
    let fileBtn = UIButton()
    let progressView = UIProgressView()
    let progressLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Small File"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        
        view.addSubview(opLab)
        view.addSubview(subTable)
        view.addSubview(listLab)
        view.addSubview(fileListTable)
        view.addSubview(fileBtn)
        view.addSubview(progressView)
        view.addSubview(progressLabel)
        
        opLab.text = "operation type"
        subTable.register(FuncSelectCell.self,
                          forCellReuseIdentifier: "smallFileCell")
        subTable.rowHeight = 50
        subTable.separatorStyle = .none
        
        listLab.text = "File List"
        fileListTable.rowHeight = 50
        fileListTable.separatorStyle = .none
        fileListTable.register(FuncSelectCell.self,
                               forCellReuseIdentifier: "smallFileListCell")
        
        fileBtn.setTitle("Downloaded", for: .normal)
        fileBtn.layer.cornerRadius = 8
        fileBtn.layer.masksToBounds = true
        fileBtn.backgroundColor = UIColor.lightGray
        fileBtn.setTitleColor(UIColor.black, for: .normal)
        
        progressLabel.text = "0%"
        progressLabel.textAlignment = .center
        progressView.progressTintColor = UIColor.red
        progressView.trackTintColor = UIColor.lightGray
        
        opLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(navigationView.snp.bottom).offset(5)
        }
        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(opLab.snp.bottom)
            make.height.equalTo(60)
        }
        
        listLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(subTable.snp.bottom).offset(5)
        }
        
        fileListTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(300)
            make.top.equalTo(listLab.snp.bottom).offset(5)
        }
        fileBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(35)
            make.top.equalTo(fileListTable.snp.bottom).offset(5)
        }
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(fileBtn.snp.bottom).offset(15)
            make.right.equalTo(progressLabel.snp.left).offset(-4)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressView.snp.centerY)
            make.right.equalToSuperview().inset(16)
            make.width.equalTo(50)
        }
        
        
        
    }
    
    override func initData() {
        super.initData()
        
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        subItemArray.bind(to: subTable.rx
            .items(cellIdentifier: "smallFileCell",cellType: FuncSelectCell.self)) {
                index, item, cell in
                cell.titleLab.text = item
            }.disposed(by: disposeBag)
        subItemArray.accept(["Directory Browse"])
        
        fileItemArray.bind(to: fileListTable.rx
            .items(cellIdentifier: "smallFileListCell",
                   cellType: FuncSelectCell.self)) { index, item, cell in
            
            cell.titleLab.text = String(format:"type:%@,id:%02X,size:%d",
                                          item.file_type.desc,
                                          item.file_id,
                                          item.file_size)
            
        }.disposed(by: disposeBag)
        
        subTable.rx.modelSelected(String.self).subscribe { [weak self](item) in
            let alert = UIAlertController(title: "File Type",
                                          message: "Fill in the file type:\n0x01 = Contacts\n0x02 = Exercise records\n0x03 = Heart rate data\n0x04 = Blood oxygen data\n0x05 = Sleep data\n0x06 = Message data\n0x07 = Weather data\n0x08 = Call records\n0x09 = Step count Data\n0xFF = weight data",
                                          preferredStyle: .alert)
            alert.addTextField { txfd in
                txfd.autocorrectionType = .no
                txfd.keyboardType = .asciiCapable
                txfd.returnKeyType = .done
                txfd.placeholder = "Fill in the file type: 0x01..."
                txfd.text = "0x01"
            }
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel))
            alert.addAction(UIAlertAction(title: "Confirm",
                                          style: .default,handler: { [weak self](_) in
                
                if let str = alert.textFields?.first?.text{
                    if let value = str.hexToBytes.first{
                        BleManager.shared.currentCmdMgr?.mSmallFileManager.cmdSmallFileQueryType(JL_SmallFileType(rawValue: value) ?? .callLog,result: { list in
                            DispatchQueue.main.async {
                                self?.fileItemArray.accept(list ?? [])
                            }
                        })
                    }
                }
                
            }))
            self?.present(alert, animated: true)
            self?.subTable.reloadData()
        }.disposed(by: disposeBag)
        
        fileListTable.rx.modelSelected(JLModel_SmallFile.self)
            .subscribe { [weak self](item) in
                
                let alert = UIAlertController(title: "Download File？",
                                              message: "After downloading, you can go to [Downloaded] to view it.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel",
                                              style: .cancel))
                alert.addAction(UIAlertAction(title: "Confirm",
                                              style: .default,
                                              handler: { [weak self](_) in
                    self?.downloadFile(item)
                }))
                self?.present(alert, animated: true)
                
            }.disposed(by: disposeBag)
        
        fileListTable.rx.modelDeleted(JLModel_SmallFile.self).subscribe { [weak self](item) in
            
            let alert = UIAlertController(title: "Delete file？",
                                          message: "After deletion, you need to re-run [Directory Browse] to refresh the content.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Confirm",
                                          style: .default,
                                          handler: { [weak self](_) in
                BleManager.shared.currentCmdMgr?.mSmallFileManager
                    .cmdSmallFileDelete(item,
                                        result: { op in
                        if op == .suceess{
                            if var newArray = self?.fileItemArray.value{
                                newArray.removeAll(where: {$0.file_id == item.file_id})
                                DispatchQueue.main.async {
                                    self?.fileItemArray.accept(newArray)
                                    self?.view.makeToast("Delete success")
                                }
                                
                            }
                        }
                    })
            }))
            self?.present(alert, animated: true)
        }.disposed(by: disposeBag)
        
        fileBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.pushViewController(SmallFileDetailViewController(), 
                                                           animated: true)
        }).disposed(by: disposeBag)
    }
    
    
    private func downloadFile(_ item:JLModel_SmallFile){
        
        let str = String(format:"%@_%02X_(size:%d)",
                         item.file_type.desc,
                         item.file_id,
                         item.file_size)
        let filePath = _R.path.smallFiles+"/"+str
        
        JL_Tools.removePath(filePath)
        self.fileListTable.reloadData()
        FileManager.default.createFile(atPath: filePath, contents: nil)
        
        BleManager.shared.currentCmdMgr?.mSmallFileManager
            .cmdSmallFileRead(item,
                              result: { [weak self](op, progress, dt) in
            DispatchQueue.main.async {
                switch op{
                case .fail:
                    self?.view.makeToast("Read fail")
                case .doing:
                    self?.view.makeToast("Reading...")
                    JL_Tools.write(dt ?? Data(), endFile: filePath)
                    self?.progressView.progress = Float(progress)
                    self?.progressLabel.text = "\(Int(progress * 100))%"
                case .suceess:
                    self?.view.makeToast("Read success")
                    JL_Tools.write(dt ?? Data(), endFile: filePath)
                    self?.progressView.progress = Float(progress)
                    self?.progressLabel.text = "\(Int(progress * 100))%"
                case .unknown:
                    self?.view.makeToast("Read failed")
                case .excess:
                    self?.view.makeToast("Read failed")
                case .crcError:
                    self?.view.makeToast("Read failed by crc")
                case .timeout:
                    self?.view.makeToast("Read failed by timeout")
                @unknown default:
                    break
                }
            }
        })
    }
    
    
}

fileprivate extension JL_SmallFileType{
    var desc:String{
        switch self {
        case .contacts:
            return "Contacts"
        case .motionRecord:
            return "Motion"
        case .heartRate:
            return "HeartRate"
        case .spoData:
            return "SPO2"
        case .sleepData:
            return "Sleep Data"
        case .massage:
            return "Massage"
        case .weather:
            return "Weather"
        case .callLog:
            return "Call Log"
        case .stepCount:
            return "Step Count"
        case .weight:
            return "Weight"
        @unknown default:
            return ""
        }
    }
}

fileprivate extension String{
    var hexToBytes:[UInt8]{
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap{ _ in
            let end = index(after: start)
            defer {start = index(after: end)}
            return UInt8(self[start...end],radix: 16)
        }
    }
}
