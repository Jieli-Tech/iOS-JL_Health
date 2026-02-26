//
//  AlertDeleteingTipsView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/19.
//

import UIKit

class AlertDeleteingTipsView: BaseView, LanguagePtl {
   
    
    private let deleteingView = UIActivityIndicatorView()
    private let tipsLabel = UILabel()
    private let centerView = UIView()
    private let bgView = UIView()
    
    override func initUI() {
        super.initUI()
        addSubview(bgView)
        addSubview(centerView)
        centerView.addSubview(deleteingView)
        centerView.addSubview(tipsLabel)
        
        self.backgroundColor = .clear
        bgView.backgroundColor = .eHex("#000000", alpha: 0.3)
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 15
        centerView.layer.masksToBounds = true
        
        deleteingView.hidesWhenStopped = true
        
        tipsLabel.textColor = .eHex("#242424")
        tipsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tipsLabel.textColor = .eHex("#242424")
        tipsLabel.textAlignment = .center
        tipsLabel.numberOfLines = 0
        tipsLabel.lineBreakMode = .byWordWrapping
        tipsLabel.adjustsFontSizeToFitWidth = true
        tipsLabel.text = LanguageCls.localizableTxt("删除表盘")
        LanguageCls.share().add(self)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        deleteingView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(deleteingView.snp.bottom)
            make.left.right.bottom.equalToSuperview().inset(20)
        }
        
    }
    
    func languageChange() {
        tipsLabel.text = LanguageCls.localizableTxt("删除表盘")
    }
    
    func startLoading() {
        deleteingView.startAnimating()
    }
    
    func stopLoading() {
        deleteingView.stopAnimating()
    }

}
