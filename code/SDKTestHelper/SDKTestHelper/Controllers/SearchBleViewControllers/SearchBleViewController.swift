//
//  SearchBleVc.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/25.
//

import UIKit

class SearchBleViewController: BaseViewController{
    
    
    let textField = UITextField()
    let tableView = UITableView()
    let textLab = UILabel()
    var itemsArray:[JL_EntityM] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BleManager.shared.startSearchBle()
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChange(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusFailed(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Scan Device"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        navigationView.rightBtn.isHidden = false
        navigationView.rightBtn.setTitle("Search", for: .normal)
        
        textLab.text = "Filter prefix"
        textLab.font = .systemFont(ofSize: 15)
        textLab.textColor = .black
        view.addSubview(textLab)
        
        textField.placeholder = "Please enter the filter prefix"
        textField.font = .systemFont(ofSize: 15)
        textField.keyboardType = .default
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        view.addSubview(textField)
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BleCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        view.addSubview(tableView)
        
        textLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.right.equalTo(textField.snp.left).offset(-10)
            make.height.equalTo(30)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(textLab.snp.right).offset(10)
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        
    }
    
    
    
    override func initData() {
        super.initData()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchList(_:)), name: NSNotification.Name(kJL_BLE_M_FOUND), object: nil)
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        navigationView.rightBtn.rx.tap.subscribe { (_) in
            BleManager.shared.startSearchBle()
        }.disposed(by: disposeBag)
        
        
    }
    
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BleManager.shared.stopSearchBle()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kJL_BLE_M_FOUND), object: nil)
    }
    
    @objc func handleSearchList(_ notification:Notification){
        fillter()
    }
    
    private func fillter(){
        let arr:[JL_EntityM] = BleManager.shared.blesArray
        itemsArray = arr.filter { item in
            let name = item.mPeripheral.name ?? ""
            ECPrintInfo(item.mPeripheral, self, "\(#function)", #line)
            let str = (textField.text == "" ? name : textField.text!)
            return name.contains(str)
        }
        tableView.reloadData()
    }
    
    @objc private func connectStatusChange(_ note:NSNotification){

        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc private func connectStatusFailed(_ note:NSNotification){
        self.view.makeToast("Connect failed",position: .center)
    }

}

extension SearchBleViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        fillter()
        return true
    }
}


extension SearchBleViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BleCell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].mPeripheral.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = itemsArray[indexPath.row]
        BleManager.shared.connectEntity(item)
    }
}
