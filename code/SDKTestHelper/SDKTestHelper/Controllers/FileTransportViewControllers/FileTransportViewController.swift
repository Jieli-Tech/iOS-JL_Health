//
//  FileTransportViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class FileTransportViewController: BaseViewController {

    let subFuncTable = UITableView()
    let itemsArray = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "File Transport"
        navigationView.rightBtn.isHidden = false
        navigationView.leftBtn.setTitle("Back", for: .normal)
        
        subFuncTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FUNCCell")
        subFuncTable.rowHeight = 60
        subFuncTable.separatorStyle = .none
        view.addSubview(subFuncTable)
        
        subFuncTable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
         
        itemsArray.bind(to: subFuncTable.rx.items(cellIdentifier: "FUNCCell", cellType: FuncSelectCell.self)) { (row, element, cell) in
            cell.titleLab.text = element
        }.disposed(by: disposeBag)
        
        
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        itemsArray.accept(["File",
                           "Sync Contacts",
                           "Watch Dial",
                           "Small File",
                           "File Browser",
                           "Gif to Device"])
        subFuncTable.rx.itemSelected.subscribe { [weak self](index) in
            guard let self = self else {return}
            switch index.element?.row {
            case 0:
                makeSelectHandle { [weak self] in
                    let vc = TransportFileViewController()
                    vc.canNotPushBack = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }
            case 1:
                self.navigationController?.pushViewController(ContactViewController(), animated: true)
            case 2:
                makeSelectHandle { [weak self] in
                    let vc = DialTpViewController()
                    vc.canNotPushBack = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case 3:
                self.navigationController?.pushViewController(SmallFileViewController(), animated: true)
            case 4:
                makeSelectHandle { [weak self] in
                    let vc = FilesBrowseViewController()
                    vc.canNotPushBack = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case 5:
                let vc = Gif2DeviceViewController()
                vc.canNotPushBack = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
                
            }
            self.subFuncTable.reloadData()
        }.disposed(by: disposeBag)
    }
    
    
    func makeSelectHandle(_ block:@escaping ()->()){
        BleManager.shared.currentEntity?.mCmdManager.cmdGetSystemInfo(.COMMON){ st, sn, dt in
            if let dev = BleManager.shared.currentEntity?.mCmdManager.getDeviceModel(){
                let alert = UIAlertController(title: "Selete File Handle", 
                                              message: nil,
                                              preferredStyle: .actionSheet)
                for it in dev.cardInfo.cardArray{
                    if let value = it as? Int{
                        let action = UIAlertAction(title: JL_CardType(rawValue: UInt8(value))! .beString(), style: .default) { (ac) in
                            switch ac.title {
                            case "SD_0":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.SD_0)
                            case "SD_1":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.SD_1)
                            case "USB":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.USB)
                            case "lineIn":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.lineIn)
                            case "FLASH":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.FLASH)
                            case "FLASH2":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.FLASH2)
                            case "FLASH3":
                                BleManager.shared.currentEntity?.mCmdManager.mFileManager.setCurrentFileHandleType(.FLASH3)
                            default:
                                break
                            }
                            block()
                        }
                        alert.addAction(action)
                    }
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
                
        }
    }
    

}
