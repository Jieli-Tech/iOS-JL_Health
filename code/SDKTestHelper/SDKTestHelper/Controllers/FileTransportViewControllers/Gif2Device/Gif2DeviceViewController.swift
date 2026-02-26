//
//  Gif2RgbViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2024/1/18.
//

import UIKit
import JLBmpConvertKit

class Gif2DeviceViewController: BaseViewController {
    
    let subTable = UITableView()
    let confirmBtn = UIButton()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    let sendBtn = UIButton()
    private let items = BehaviorRelay<[String]>(value: [])
    private var targetFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func initUI() {
        super.initUI()
        
        navigationView.title = "Gif to Device"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        view.addSubview(subTable)
        view.addSubview(confirmBtn)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(sendBtn)
        
        if let list = _R.path.gif2Rgb.listFile(){
            self.items.accept(list)
        }
        if self.items.value.count == 0{
            self.view.makeToast("Need to import the file into: [Document/gif2rgb] folder",duration: 3,position: .center)
        }
        
        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 35
        subTable.tableFooterView = UIView()
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "tagCell")
        
        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell")){ index,item,cell in
            cell.textLabel?.text = (item as NSString).lastPathComponent
        }.disposed(by: disposeBag)
        
        subTable.rx.modelSelected(String.self).subscribe { [weak self](model) in
            guard let `self` = self else{return}
            targetFile = model
        }.disposed(by: disposeBag)
        
        confirmBtn.setTitle("Start create rgb", for: .normal)
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
        
        sendBtn.setTitle("Send rgb bin", for: .normal)
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

            if targetFile.count > 0{
                self.statusLab.text = "Creating..."
                
                if let dt = try?Data(contentsOf: URL(fileURLWithPath: targetFile)){
                    JLGifBin.makeData(toBin: dt, level: 1) {
                        status,
                        targeteData in
                        DispatchQueue.main.async {
                            self.statusLab.text = "Create success"
                        }
                    }
                }
            }
        }.disposed(by: disposeBag)
         
        
    }

    
}
