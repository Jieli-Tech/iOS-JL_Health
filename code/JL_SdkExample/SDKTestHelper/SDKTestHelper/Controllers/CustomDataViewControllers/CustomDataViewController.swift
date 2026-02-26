//
//  CustomDataVC.swift
//  WatchTest
//
//  Created by 杰理科技 on 2023/11/24.
//

import UIKit

class CustomDataViewController: BaseViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var mManager :JL_ManagerM?
    var mCustomManager: JL_CustomManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*--- 引用自定义数据类 ---*/
        mManager       = BleManager.shared.currentCmdMgr
        mCustomManager = BleManager.shared.currentCmdMgr?.mCustomManager

        
        JL_Tools.add(kJL_MANAGER_CUSTOM_DATA, action: #selector(noteCustumCmdData(_:)), own: self)
        JL_Tools.add(kJL_MANAGER_CUSTOM_DATA_RSP, action: #selector(noteCustumRspData(_:)), own: self)
    }

    @IBAction func onSendBtn(_ sender: Any) {
        /*--- 发送测试数据 ---*/
        let data = JL_Tools.hex(toData: "00010203040506070809") as Data
        let txt = "Send data: \(JL_Tools.dataChange(toString: data))"
        showOnTextView("\(txt)\n")
        
        mCustomManager?.cmdCustomData(data)
    }
    
    @objc func noteCustumCmdData(_ note:NSNotification){
        let dict = note.object as! Dictionary<String, Any>
        let data = dict[kJL_MANAGER_KEY_OBJECT] as! Data
        
        let txt = "Get data(CMD): \(JL_Tools.dataChange(toString: data))"
        showOnTextView("\(txt)\n")
    }
    
    @objc func noteCustumRspData(_ note:NSNotification){
        let dict = note.object as! Dictionary<String, Any>
        let data = dict[kJL_MANAGER_KEY_OBJECT] as? Data ?? Data()
        
        let txt = "Get data(RSP): \(JL_Tools.dataChange(toString: data))"
        showOnTextView("\(txt)\n")
    }
    
    func showOnTextView(_ txt:String){
        print(txt)
        let str = textView.text + txt
        textView.text = str
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.customerCommand()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        sendBtn.layer.cornerRadius = 8.0

    }
    
    override func initData() {
        super.initData()
        self.navigationView.leftBtn.rx.tap.subscribe { [weak self]_ in
            JL_Tools.remove(kJL_MANAGER_CUSTOM_DATA, own: self!)
            JL_Tools.remove(kJL_MANAGER_CUSTOM_DATA_RSP, own: self!)

            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

}
