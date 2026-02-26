//
//  DialPayBottom.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/20.
//

import UIKit

class DialPayBottomView: BaseView {
    private let progressView = UIProgressView()
    private let buyBtn = UIButton()
    let buyBtnSingle = PublishSubject<Void>()

    override func initUI() {
        super.initUI()
        self.addSubview(progressView)
        self.addSubview(buyBtn)
        progressView.trackTintColor = .eHex("#E5E5E5")
        progressView.tintColor = .eHex("#805BEB")
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = 24
        progressView.progress = 1
        
        buyBtn.setTitle(LanguageCls.localizableTxt("购买"), for: .normal)
        buyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        buyBtn.setTitleColor(.white, for: .normal)
        buyBtn.backgroundColor = .clear
        buyBtn.layer.masksToBounds = true
        buyBtn.layer.cornerRadius = 24
        
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.height.equalTo(48)
        }
        
        buyBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
    override func initData() {
        super.initData()
        buyBtn.rx.tap
            .bind(to: buyBtnSingle)
            .disposed(by: disposeBag)
    }
    
    func setProgress(_ progress:Float) {
        progressView.progress = progress
        let str = LanguageCls.localizableTxt("下载中") + String(format: "%.2f%%", progress * 100)
        buyBtn.setTitle(str, for: .normal)
        buyBtn.isEnabled = false
    }
    
    func setTitle(_ title:String) {
        buyBtn.setTitle(title, for: .normal)
    }
    
    func setBuyBtnEnable(_ enable:Bool) {
        buyBtn.isEnabled = enable
    }
    
   
}
