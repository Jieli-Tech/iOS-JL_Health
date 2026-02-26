//
//  AIServiceTipsView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/2/28.
//

import UIKit

class AIServiceTipsView: UIView,LanguagePtl {

    let bgView = UIView()
    let tipsLabel = UILabel()
    let tipsImgview = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgView)
        addSubview(tipsLabel)
        addSubview(tipsImgview)
        
        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.9)
        bgView.layer.cornerRadius = 25
        bgView.layer.masksToBounds = true
        
        tipsLabel.textColor = .white
        tipsLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tipsLabel.textAlignment = .center
        tipsLabel.numberOfLines = 0
        tipsLabel.adjustsFontSizeToFitWidth = true
        tipsLabel.text = LanguageCls.localizableTxt("AI云服务")
        
        tipsImgview.image = UIImage(named: "icon_ai_img_photo")
        tipsImgview.contentMode = .scaleAspectFit
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(tipsImgview.snp.right).offset(8)
            make.centerX.equalToSuperview().offset(15)
        }
        
        tipsImgview.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(tipsLabel.snp.left).offset(-8)
        }
        
        LanguageCls.share().add(self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func languageChange() {
        tipsLabel.text = LanguageCls.localizableTxt("AI云服务")
    }
    
}
