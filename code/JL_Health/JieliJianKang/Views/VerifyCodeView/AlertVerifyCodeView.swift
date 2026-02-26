//
//  AlertVerifyCodeView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/5.
//

import UIKit
import Kingfisher
import Toast_Swift


struct VerifyCodeModel {
    var code:String
    var value:String
    var base64:String
    var type:String
    var updateTime:String
}

class AlertVerifyCodeView: BaseView,LanguagePtl {
    
    typealias verifyCodeCallBack = (_ code:String,_ value:String,_ err:Error?)->()
    
    private let bgView = UIView()
    private let contentView = UIView()
    private let titleLab = UILabel()
    private let inputContent = UIView()
    private let inputTF = UITextField()
    private let getVerifyCodeBtn = UIButton()
    private let verifyCodeImgv = UIImageView()
    private let line1 = UIView()
    private let line2 = UIView()
    private let confirmBtn = UIButton()
    private let cancelBtn = UIButton()
    
    private var tmpModel:VerifyCodeModel?
    private var callBack:verifyCodeCallBack?
    
    
    override func initUI() {
        super.initUI()
        self.addSubview(bgView)
        bgView.addSubview(contentView)
        contentView.addSubview(titleLab)
        contentView.addSubview(inputContent)
        inputContent.addSubview(inputTF)
        inputContent.addSubview(verifyCodeImgv)
        contentView.addSubview(getVerifyCodeBtn)
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(confirmBtn)
        contentView.addSubview(cancelBtn)
        LanguageCls.share().add(self)
        
        backgroundColor = UIColor.clear
        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.3)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.backgroundColor = UIColor.eHex("#FFFFFF")
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(-50)
            make.height.equalTo(220)
        }
        
        titleLab.textColor = .eHex("#242424")
        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.textAlignment = .center
        titleLab.numberOfLines = 0
        titleLab.text = LanguageCls.localizableTxt("Image Captcha")
        
        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(28)
        }
        
        inputContent.backgroundColor = .eHex("#FFFFFF")
        inputContent.layer.cornerRadius = 4
        inputContent.layer.masksToBounds = true
        inputContent.layer.borderColor = UIColor.eHex("#CECECE").cgColor
        inputContent.layer.borderWidth = 1
        
        inputContent.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
            make.height.equalTo(48)
        }
        
        inputTF.textColor = .eHex("#242424")
        inputTF.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        inputTF.placeholder = LanguageCls.localizableTxt("Please enter the correct captcha.")
        inputTF.keyboardType = .default
        inputTF.borderStyle = .none
        inputTF.returnKeyType = .done
        inputTF.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(verifyCodeImgv.snp.left)
        }
        
        
        verifyCodeImgv.contentMode = .scaleAspectFit
        verifyCodeImgv.snp.makeConstraints { make in
            make.left.equalTo(inputTF.snp.right)
            make.right.bottom.top.equalToSuperview()
            make.width.equalTo(100)
        }
        
        getVerifyCodeBtn.setTitle(LanguageCls.localizableTxt("Can't see it? Try another."), for: .normal)
        getVerifyCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        getVerifyCodeBtn.setTitleColor(UIColor.eHex("#4B4B4B"), for: .normal)
        
        getVerifyCodeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.top.equalTo(inputContent.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        cancelBtn.setTitle(LanguageCls.localizableTxt("取消"), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        cancelBtn.setTitleColor(.eHex("#4B4B4B"), for: .normal)
        
        cancelBtn.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.width.equalTo(confirmBtn.snp.width)
            make.right.equalTo(confirmBtn.snp.left)
            make.height.equalTo(50)
        }
        
        confirmBtn.setTitle(LanguageCls.localizableTxt("确认"), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        confirmBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        
        confirmBtn.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn.snp.width)
            make.height.equalTo(50)
            make.left.equalTo(cancelBtn.snp.right)
        }
        
        line1.backgroundColor = .eHex("#F7F7F7")
        line2.backgroundColor = .eHex("#F7F7F7")
        line1.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(cancelBtn.snp.top)
        }
        line2.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(50)
        }
        
    }
    
    override func initData() {
        super.initData()
        
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideViewInputKeyboard)))
        cancelBtn.rx.tap.subscribe() { [weak self] _ in
            self?.hideView()
            self?.callBack?("", "", nil);
        }
        .disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe() { [weak self] _ in
            self?.verifyCodeRequest()
        }
        .disposed(by: disposeBag)
        
        getVerifyCodeBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            makeRequest(callBack: self.callBack!)
        }.disposed(by: disposeBag)
        
        inputTF.rx.controlEvent([.editingDidEndOnExit]).subscribe(){ [weak self] _ in
            self?.inputTF.resignFirstResponder()
            self?.verifyCodeRequest()
        }.disposed(by: disposeBag)
        
    }
    

    
    func makeRequest(callBack:@escaping(verifyCodeCallBack)){
        self.callBack = callBack
        User_Http.shareInstance().requestCapcha { [weak self](result) in
            guard let self = self else {return}
            if let dict = result as? [String:Any] {
                if let code = dict["code"] as? Int, code == 0 {
                    if let params = dict["data"] as? [String:String] {
                        self.tmpModel = VerifyCodeModel(code: params["code"] ?? "", value: params["value"] ?? "", base64: params["base64"] ?? "", type: params["type"] ?? "", updateTime: params["updateTime"] ?? "")
                        let imageSource = Base64ImageDataProvider(base64String: self.tmpModel?.base64 ?? "", cacheKey: self.tmpModel?.code ?? "")
                        DispatchQueue.main.async {
                            self.inputTF.text = ""
                            self.verifyCodeImgv.kf.setImage(with: imageSource)
                            self.inputTF.becomeFirstResponder()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.makeToast(LanguageCls.localizableTxt("There was a problem loading the image verification code, please try again later"), duration: 1.5, position: .center)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.makeToast(LanguageCls.localizableTxt("There was a problem loading the image verification code, please try again later"), duration: 1.5, position: .center)
                }
            }
        }
    }
    
    func languageChange() {
        titleLab.text = LanguageCls.localizableTxt("Image Captcha")
        getVerifyCodeBtn.setTitle(LanguageCls.localizableTxt("Can't see it? Try another."), for: .normal)
        confirmBtn.setTitle(LanguageCls.localizableTxt("确认"), for: .normal)
        cancelBtn.setTitle(LanguageCls.localizableTxt("取消"), for: .normal)
    }
    
    @objc private func hideView() {
        AlertViewOnWindows.removeVerifyCodeTips()
        inputTF.resignFirstResponder()
    }
    
    @objc private func hideViewInputKeyboard() {
        inputTF.resignFirstResponder()
    }
    private func verifyCodeRequest() {
        let inputValue = inputTF.text ?? ""
        if inputValue.count == 0 {
            return
        }
        guard let code = tmpModel?.code else {
            return
        }
        User_Http.shareInstance().checkCapcha(code, value: inputValue) { [weak self](status) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                if status {
                    self.hideView()
                    self.callBack?(code, inputValue, nil)
                }else{
                    self.makeToast(LanguageCls.localizableTxt("Please enter the correct captcha."), duration: 1.5, position: .center)
                }
            }
        }
      
    }
    
}
