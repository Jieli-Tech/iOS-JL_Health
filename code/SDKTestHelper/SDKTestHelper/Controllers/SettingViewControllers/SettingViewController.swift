//
//  SettingViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/30.
//

import UIKit

class SettingViewController: BaseViewController {

    let subtable = UITableView()
    var itemArray:[String] = ["Customize BLE Connection","Authentication pairing"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Setting"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        
        subtable.backgroundColor = UIColor.eHex("#F5F5F5")
        subtable.register(SettingViewCell.self, forCellReuseIdentifier: "SettingViewCell")
        subtable.delegate = self
        subtable.dataSource = self
        view.addSubview(subtable)
        subtable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    

}

extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingViewCell", for: indexPath) as! SettingViewCell
        cell.label.text = itemArray[indexPath.row]
        cell.switchBtn.tag = indexPath.row
        if indexPath.row == 0{
            cell.switchBtn.isOn = SettingInfo.getCustomerBleConnect()
        }
        if indexPath.row == 1{
            cell.switchBtn.isOn = SettingInfo.getPairEnable()
        }
        cell.handler = { [weak self](btn) in
            self?.handleBtn(switchBtn: btn)
        }
        return cell
    }
    
    func handleBtn(switchBtn:UISwitch){
        switch switchBtn.tag {
        case 0:
            SettingInfo.saveCustomerBleConnect(switchBtn.isOn)
        case 1:
            SettingInfo.savePairEnable(switchBtn.isOn)
        default:
            break
        }
    }
}



class SettingViewCell: UITableViewCell {

    let label = UILabel()
    let switchBtn = UISwitch()
    var handler: ((UISwitch) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(switchBtn)
        
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        switchBtn.addTarget(self, action: #selector(switchBtnClick), for: .valueChanged)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        switchBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func switchBtnClick(){
        handler?(switchBtn)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
