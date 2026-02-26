//
//  WindowsTipsViews.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/2/28.
//

import UIKit

@objcMembers class WindowsTipsViews: UIView {
    
    static private let share = WindowsTipsViews(frame: .zero)
    private var mWindow = UIApplication.shared.windows.first
    
    private lazy var aiServiceTipsView: AIServiceTipsView = {
        AIServiceTipsView(frame: .zero)
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        mWindow?.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showAIServiceTips(){
        DispatchQueue.main.async {
            share.isHidden = false
            share.mWindow?.addSubview(share.aiServiceTipsView)
            share.aiServiceTipsView.snp.remakeConstraints { make in
                make.top.equalToSuperview().inset(40+share.mWindow!.safeAreaInsets.top)
                make.centerX.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(48)
            }
        }
    }
    
    class func removeAIServiceTips(){
        DispatchQueue.main.async {
            share.aiServiceTipsView.removeFromSuperview()
            share.isHidden = true
        }
    }
    
    
}
