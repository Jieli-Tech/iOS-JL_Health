//
//  DialSubCollectionViewCell.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

enum DialFreeCellBtnType {
    case using
    case notUsing
    case needDownload
    case update
    case free
}

class DialFreeModel: NSObject {
    var btnType:DialFreeCellBtnType = .notUsing
    var model:DialMallModel
    init(model:DialMallModel) {
        self.model = model
    }
}

class DialInfoModel {
    var name:String
    var version:String
    var uuid:String
    var describe:String = ""

    init(name:String,version:String,uuid:String,describe:String = "") {
        self.name = name
        self.version = version
        self.uuid = uuid
        self.describe = describe
    }
    
}

class DialSubModel {
    var isUsing:Bool
    var isCircle:Bool = false
    var model:DialInfoModel
    var iconUrl:String?
    init(isUsing:Bool,isCircle:Bool,model:DialInfoModel) {
        self.isUsing = isUsing
        self.isCircle = isCircle
        self.model = model
    }
}

class DialSubCollectionViewCell: UICollectionViewCell,LanguagePtl {
    let titleLab = UILabel()
    let statusBtn = UIButton()
    let imgv = UIImageView()
    let editBtn = UIButton()
    let editBgImgv = UIImageView()
    let deleteBtn = UIButton()
    let centerView = UIView()

    var callBackEdit:((_ model:Any)->Void)?
    var callBackStatus:((_ model:Any)->Void)?
    var callBackDelete:((_ model:Any)->Void)?
    private let disposeBag = DisposeBag()
    private var currentModel:Any?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        LanguageCls.share().add(self)
        contentView.addSubview(centerView)
        centerView.addSubview(imgv)
        centerView.addSubview(editBgImgv)
        centerView.addSubview(titleLab)
        centerView.addSubview(statusBtn)
        centerView.addSubview(editBtn)
        centerView.addSubview(deleteBtn)
        
        centerView.backgroundColor = .eHex("#FFFFFF",alpha: 0)
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imgv.image = UIImage(named: "watch_img_06")
        imgv.contentMode = .scaleAspectFit
        imgv.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        editBgImgv.snp.makeConstraints { make in
            make.edges.equalTo(imgv)
        }
        editBtn.backgroundColor = .eHex("#FFFFFF",alpha: 0)
        editBtn.setTitle(LanguageCls.localizableTxt("编辑"), for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        editBtn.setTitleColor(.white, for: .normal)
        editBtn.snp.makeConstraints { make in
            make.left.equalTo(imgv.snp.left)
            make.right.equalTo(imgv.snp.right)
            make.bottom.equalTo(imgv.snp.bottom)
            make.height.equalTo(26)
        }
        
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLab.textColor = .eHex("#242424")
        titleLab.textAlignment = .center
        titleLab.text = "WATCH"
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(imgv.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        statusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        statusBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        statusBtn.setTitle(LanguageCls.localizableTxt("正在使用"), for: .normal)
        statusBtn.backgroundColor = .eHex("#F0F1F5")
        statusBtn.layer.cornerRadius = 13
        statusBtn.layer.masksToBounds = true
        statusBtn.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(13)
            make.height.equalTo(26)
        }
        
        deleteBtn.setImage(UIImage.init(named: "product_icon_delete_nol"), for: .normal)
        deleteBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.width.equalTo(30)
        }
        deleteBtn.isHidden = true
        
        editBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.callBackEdit?(self.currentModel!)
        }.disposed(by: disposeBag)
        
        statusBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.callBackStatus?(self.currentModel!)
        }.disposed(by: disposeBag)
        
        deleteBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.callBackDelete?(self.currentModel!)
        }.disposed(by: disposeBag)
        
    }
    
    func configCell(_ vm:DialSubViewModel,_ model:DialSubModel,_ isEdit:Bool = false) {
        currentModel = model
        titleLab.text = model.model.name
        if let url = model.iconUrl {
            self.imgv.kf.setImage(with: URL(string: url),placeholder: UIImage(named: "watch_img_06"),options: [.memoryCacheAccessExtendingExpiration(.expirationTime(.days(30)))])
        }else{
            vm.getDialInfo(model.model.uuid) { dialNetInfo in
                guard let dialNetInfo = dialNetInfo else {
                    return
                }
                self.imgv.kf.setImage(with: URL(string: dialNetInfo.icon),placeholder: UIImage(named: "watch_img_06"),options: [.memoryCacheAccessExtendingExpiration(.expirationTime(.days(30)))])
            }
        }
        if !isEdit {
            editBtn.isHidden = !model.isUsing
            editBgImgv.isHidden = !model.isUsing
            if model.isCircle {
                editBgImgv.image = UIImage(named: "watch_bg_90")
            } else {
                editBgImgv.image = UIImage(named: "watch_bg_88_quadrate")
            }
        }else{
            editBtn.isHidden = true
            editBgImgv.isHidden = true
        }
        if !model.isUsing {
            statusBtn.setTitle(LanguageCls.localizableTxt("使用"), for: .normal)
        } else {
            statusBtn.setTitle(LanguageCls.localizableTxt("正在使用"), for: .normal)
        }
        deleteBtn.isHidden = !isEdit
        statusBtn.isUserInteractionEnabled = isEdit
        
    }
    
    func configVcPageModel(_ model:DialPageModel,_ isEdit:Bool = false){
        currentModel = model
        titleLab.text = model.name.uppercased()
        imgv.kf.setImage(with: URL(string: model.icon),placeholder: UIImage(named: "watch_img_06"),options: [.memoryCacheAccessExtendingExpiration(.expirationTime(.days(30)))])
        let currentName = BridgeHelper.dialCache().currentWatchName()
        let dialList = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        let shape = BridgeHelper.getDialInfoExtentManager().shape
        let isUsing = model.name.uppercased() == currentName ? true : false
        if !isEdit {
            editBtn.isHidden = !isUsing
            editBgImgv.isHidden = !isUsing
            if shape == 0 || shape == 0x01 {
                editBgImgv.image = UIImage(named: "watch_bg_90")
            } else if shape == 0x02 || shape == 0x03 {
                editBgImgv.image = UIImage(named: "watch_bg_88_quadrate")
            } else {
                editBgImgv.image = UIImage(named: "watch_bg_90")
            }
        }else{
            editBtn.isHidden = true
            editBgImgv.isHidden = true
        }
        if !isUsing {
            if dialList.contains(model.name.uppercased()) {
                statusBtn.setTitle(LanguageCls.localizableTxt("使用"), for: .normal)
            } else {
                statusBtn.setTitle(LanguageCls.localizableTxt("下载"), for: .normal)
            }
        } else {
            statusBtn.setTitle(LanguageCls.localizableTxt("正在使用"), for: .normal)
        }
        deleteBtn.isHidden = !isEdit
        statusBtn.isUserInteractionEnabled = !isEdit
    }
    
    /// 免费表盘
    func configFreeCell(_ model:DialFreeModel) {
        currentModel = model
        editBtn.isHidden = true
        editBgImgv.isHidden = true
        deleteBtn.isHidden = true
        titleLab.text = model.model.name.uppercased()
        imgv.kf.setImage(with: URL(string: model.model.icon),placeholder: UIImage(named: "watch_img_06"),options: [.memoryCacheAccessExtendingExpiration(.expirationTime(.days(30)))])
        statusBtn.backgroundColor = .eHex("#F0F1F5")
        
        statusBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        if model.btnType == .notUsing {
            statusBtn.setTitle(LanguageCls.localizableTxt("使用"), for: .normal)
        } else if model.btnType == .using {
            statusBtn.setTitle(LanguageCls.localizableTxt("正在使用"), for: .normal)
        } else if model.btnType == .needDownload {
            statusBtn.setTitle(LanguageCls.localizableTxt("下载"), for: .normal)
        } else if model.btnType == .update {
            statusBtn.setTitle(LanguageCls.localizableTxt("更新"), for: .normal)
            statusBtn.backgroundColor = .eHex("#7EC97D")
            statusBtn.setTitleColor(.white, for: .normal)
        }else if model.btnType == .free {
            statusBtn.setTitle(LanguageCls.localizableTxt("免费"), for: .normal)
        }
    }
    
    ///历史购买表盘
    func configPayHistoryCell(_ model:DialPayHistoryModel) {
        currentModel = model
        editBtn.isHidden = true
        editBgImgv.isHidden = true
        deleteBtn.isHidden = true
        titleLab.text = model.name.uppercased()
        imgv.kf.setImage(with: URL(string: model.icon),placeholder: UIImage(named: "watch_img_06"),options: [.memoryCacheAccessExtendingExpiration(.expirationTime(.days(30)))])
        statusBtn.backgroundColor = .eHex("#F0F1F5")
        statusBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        let currentDial = BridgeHelper.dialCache().currentWatchName()
        let dialList = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        if currentDial == model.name.uppercased() {
            statusBtn.setTitle(LanguageCls.localizableTxt("正在使用"), for: .normal)
        }else if dialList.contains(model.name.uppercased()) {
            statusBtn.setTitle(LanguageCls.localizableTxt("使用"), for: .normal)
        } else {
            statusBtn.setTitle(LanguageCls.localizableTxt("下载"), for: .normal)
        }
    }
    
    /// 支付表盘
    func configPayCell(_ model:DialMallModel) {
        currentModel = model
        editBtn.isHidden = true
        editBgImgv.isHidden = true
        deleteBtn.isHidden = true
        titleLab.text = model.name.uppercased()
        imgv.kf.setImage(with: URL(string: model.icon),placeholder: UIImage(named: "watch_img_06"),options: [.memoryCacheAccessExtendingExpiration(.expirationTime(.days(30)))])
        let currentWatch = BridgeHelper.dialCache().currentWatchName()
        statusBtn.backgroundColor = .eHex("#F0F1F5")
        statusBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
       
        let devDialList = BridgeHelper.dialCache().getWatchList() as! [String]
        if devDialList.contains(model.name.uppercased()) {
            statusBtn.setTitle(LanguageCls.localizableTxt("使用"), for:.normal)
            if currentWatch == model.name.uppercased() {
                statusBtn.setTitle(LanguageCls.localizableTxt("正在使用"), for: .normal)
            }
        }else{
            if model.status {
                statusBtn.setTitle(LanguageCls.localizableTxt("下载"), for:.normal)
            }else{
                if model.price == 0 {
                    statusBtn.setTitle(LanguageCls.localizableTxt("免费"), for:.normal)
                }else{
                    let price = LanguageCls.localizableTxt("杰币") + " " + String(model.price / 100)
                    statusBtn.setTitle(price, for:.normal)
                }
            }
        }
    }
    
    func languageChange() {
        editBtn.setTitle(LanguageCls.localizableTxt("编辑"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
