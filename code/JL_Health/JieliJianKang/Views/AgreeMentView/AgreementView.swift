//
//  AgreementView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/11/19.
//

import UIKit
import SwiftyAttributes


@objcMembers class AgreementView: BaseView {
    
    static let kAgreeMent = "statement"
    private let agreeMentBtn = UIButton()
    private let agreeMentLabel = UILabel()
    weak var parentViewController: UIViewController?
    
    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        addSubview(agreeMentBtn)
        addSubview(agreeMentLabel)
        
        agreeMentBtn.setImage(UIImage(named: "icon_music_unsel"), for: .normal)
        
        let text = LanguageCls.localizableTxt("I have read and agree to the")
        let text2 = LanguageCls.localizableTxt("User Agreement")
        let text3 = LanguageCls.localizableTxt("and")
        let text4 = LanguageCls.localizableTxt("Privacy Policy")
        let attr = text.withFont(UIFont.systemFont(ofSize: 12, weight: .medium)).withTextColor(.eHex("#000000", alpha: 0.3))
        + text2.withFont(UIFont.systemFont(ofSize: 12, weight: .medium)).withTextColor(.eHex("#805BEB")).withUnderlineColor(.eHex("#805BEB")).withUnderlineStyle(.single)
        + text3.withFont(UIFont.systemFont(ofSize: 12, weight: .medium)).withTextColor(.eHex("#000000", alpha: 0.3))
        + text4.withFont(UIFont.systemFont(ofSize: 12, weight: .medium)).withTextColor(.eHex("#805BEB")).withUnderlineColor(.eHex("#805BEB")).withUnderlineStyle(.single)
        
        agreeMentLabel.attributedText = attr
        agreeMentLabel.numberOfLines = 0
        agreeMentLabel.textAlignment = .center
        
        agreeMentBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
            make.right.equalTo(agreeMentLabel.snp.left).offset(-5)
        }
        
        agreeMentLabel.snp.makeConstraints { make in
            make.left.equalTo(agreeMentBtn.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(10)
        }
        
        print(text2,text4)
        agreeMentLabel.yb_addAttributeTapAction(with: [text2,text4]) { [weak self] lab, text, range, index in
            guard let self = self,let vc = self.parentViewController else {return}
            if index == 0 {
                let userProfileVc = UserProfileVC()
                userProfileVc.modalPresentationStyle = .fullScreen
                vc.present(userProfileVc, animated: true)
            }else{
                let privacyPolicyVC = PrivacyPolicyVC()
                privacyPolicyVC.modalPresentationStyle = .fullScreen
                vc.present(privacyPolicyVC, animated: true)
            }
        }
        if let _ = JL_Tools.getUserByKey(AgreementView.kAgreeMent) {
            agreeMentBtn.setImage(UIImage(named: "icon_music_sel"), for: .normal)
        }else{
            agreeMentBtn.setImage(UIImage(named: "icon_music_unsel"), for: .normal)
        }
    }
    override func initData() {
        super.initData()
        agreeMentBtn.rx.tap.bind { _ in
            if let _ = JL_Tools.getUserByKey(AgreementView.kAgreeMent) {
                JL_Tools.removeUser(byKey: AgreementView.kAgreeMent)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AgreementView.kAgreeMent), object: "no")
            }else{
                JL_Tools.setUser(AgreementView.kAgreeMent, forKey: AgreementView.kAgreeMent)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AgreementView.kAgreeMent), object: "ok")
            }
        }.disposed(by: disposeBag)
        NotificationCenter.default.addObserver(self, selector: #selector(agreeMentAction), name: NSNotification.Name(rawValue: AgreementView.kAgreeMent), object: nil)
    }
    
    @objc func agreeMentAction(note: Notification) {
        let obj = note.object as? String
        if obj == "ok" {
            agreeMentBtn.setImage(UIImage(named: "icon_music_sel"), for: .normal)
        }else{
            agreeMentBtn.setImage(UIImage(named: "icon_music_unsel"), for: .normal)
        }
    }
}
