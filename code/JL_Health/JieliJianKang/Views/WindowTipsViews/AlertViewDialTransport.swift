//
//  AlertViewDialTransport.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit

class AlertViewDialTransport: BaseView,LanguagePtl {
    private let bgView = UIView()
    private let centerView = UIView()
    private let tipsLabel = UILabel()
    private let progressView = UIProgressView()
    private let detailLabel = UILabel()
    private let statusImgv = UIImageView()
    private let failedLabel = UILabel()
    private let lineView = UIView()
    private let closeBtn = UIButton()
    
    var title: String {
        get {
            tipsLabel.text ?? ""
        }
        set {
            tipsLabel.text = newValue
        }
    }
    
    override func initUI() {
        super.initUI()

        self.addSubview(bgView)
        self.addSubview(centerView)
        centerView.addSubview(tipsLabel)
        centerView.addSubview(progressView)
        centerView.addSubview(detailLabel)
        
        centerView.addSubview(statusImgv)
        centerView.addSubview(failedLabel)
        centerView.addSubview(lineView)
        centerView.addSubview(closeBtn)
        
        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.2)
        
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 15
        centerView.layer.masksToBounds = true
        
        tipsLabel.textColor = .eHex("#242424")
        tipsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tipsLabel.textColor = .eHex("#242424")
        tipsLabel.textAlignment = .center
        tipsLabel.numberOfLines = 0
        tipsLabel.lineBreakMode = .byWordWrapping
        tipsLabel.adjustsFontSizeToFitWidth = true
        
        progressView.progress = 0.0
        progressView.trackTintColor = .eHex("#D8D8D8")
        progressView.tintColor = .eHex("#558CFF")
        
        detailLabel.textColor = .eHex("#242424")
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.text = LanguageCls.localizableTxt("升级过程中，请保持蓝牙和网络打开状态")
        
        statusImgv.image = UIImage(named: "icon_success_nol")
        statusImgv.contentMode = .scaleAspectFit
        statusImgv.isHidden = true
        
        failedLabel.textColor = .eHex("#242424")
        failedLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        failedLabel.textAlignment = .center
        failedLabel.numberOfLines = 0
        failedLabel.text = LanguageCls.localizableTxt("升级失败")
        failedLabel.isHidden = true
        
        lineView.backgroundColor = .eHex("#F7F7F7")
        lineView.isHidden = true
        
        closeBtn.setTitle(LanguageCls.localizableTxt("确认"), for: .normal)
        closeBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        closeBtn.isHidden = true
        
        
        closeBtn.setImage(UIImage(named: "icon_close_nol"), for: .normal)
        
        LanguageCls.share().add(self)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        centerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(12)
        }

        tipsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(28)
            make.height.equalTo(3)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        statusImgv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(30)
            make.width.height.equalTo(50)
        }
        
        failedLabel.snp.makeConstraints { make in
            make.top.equalTo(statusImgv.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(lineView.snp.top).offset(-5)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(closeBtn.snp.top)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    override func initData() {
        super.initData()
        closeBtn.rx.tap.subscribe(){ [weak self] _ in
            guard let `self` = self else { return }
            self.setProgress(LanguageCls.localizableTxt("正在升级"), 0)
            progressView.isHidden = false
            tipsLabel.isHidden = false
            detailLabel.isHidden = false
            statusImgv.isHidden = true
            lineView.isHidden = true
            closeBtn.isHidden = true
            failedLabel.isHidden = true
            AlertViewOnWindows.removeDialTransport()
        }.disposed(by: disposeBag)
    }

    deinit {
        LanguageCls.share().remove(self)
    }
    
    func languageChange() {
        detailLabel.text = LanguageCls.localizableTxt("升级过程中，请保持蓝牙和网络打开状态")
    }
    
    func setProgress(_ title: String,_ progress: Float) {
        progressView.isHidden = false
        tipsLabel.isHidden = false
        detailLabel.isHidden = false
        statusImgv.isHidden = true
        failedLabel.isHidden = true
        lineView.isHidden = true
        closeBtn.isHidden = true
        
        progressView.setProgress(progress, animated: true)
        tipsLabel.text = title + "..." + " \(Int(progress * 100))%"
    }
    
    func setSuccess() {
        progressView.isHidden = true
        tipsLabel.isHidden = true
        detailLabel.isHidden = true
        statusImgv.isHidden = false
        lineView.isHidden = false
        closeBtn.isHidden = false
        failedLabel.isHidden = true
        statusImgv.image = UIImage(named: "icon_success_nol")
    }
    
    func setFail(_ reason: String?) {
        progressView.isHidden = true
        tipsLabel.isHidden = true
        detailLabel.isHidden = true
        statusImgv.isHidden = false
        lineView.isHidden = false
        closeBtn.isHidden = false
        failedLabel.isHidden = true
        statusImgv.image = UIImage(named: "icon_fail_nol")
        if let reason = reason {
            failedLabel.text = reason
            failedLabel.isHidden = false
        }
    }
    
    
    
}
