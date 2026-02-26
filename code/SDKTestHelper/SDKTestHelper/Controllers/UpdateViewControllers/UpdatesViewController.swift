//
//  UpdatesViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/19.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class UpdatesViewController: BaseViewController {

    let subFuncTable = UITableView()
    let itemsArray = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Update"
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
        itemsArray.accept(["OTA",
                           "4G OTA"])
        subFuncTable.rx.itemSelected.subscribe { [weak self](index) in
            guard let self = self else {return}
            switch index.element?.row {
            case 0:
                let vc = OTAViewController()
                vc.canNotPushBack = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = OTA4GViewController()
                vc.canNotPushBack = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
                
            }
            self.subFuncTable.reloadData()
        }.disposed(by: disposeBag)
    }

}
