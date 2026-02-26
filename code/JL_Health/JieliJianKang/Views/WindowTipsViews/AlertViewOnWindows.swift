//
//  WindowsTipsViews.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/2/28.
//

import UIKit

@objcMembers class AlertViewOnWindows: UIView {
    
    static private let share = AlertViewOnWindows(frame: .zero)
    private var mWindow = UIApplication.shared.windows.first
    
    private lazy var aiServiceTipsView: AIServiceTipsView = {
        AIServiceTipsView(frame: .zero)
    }()
    private var verifyCodeTipsView = AlertVerifyCodeView()
    private let dialTransportView = AlertViewDialTransport()
    private let deleteingView = AlertDeleteingTipsView()
    private let connectingView = AlertConnectingTipsView()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green
        verifyCodeTipsView.isHidden = true
        dialTransportView.isHidden = true
        deleteingView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getFirstWindow() -> UIWindow? {
        return UIApplication.shared.windows.first
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
    
    
    //MARK: - 验证码
    class func showVerifyCodeTips(callBack:@escaping(_ code:String,_ value:String,_ err:Error?)->()){
        DispatchQueue.main.async {
            share.verifyCodeTipsView.isHidden = false
            share.mWindow?.addSubview(share.verifyCodeTipsView)
            share.verifyCodeTipsView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.verifyCodeTipsView.makeRequest(callBack: callBack)
        }
    }
    
    class func removeVerifyCodeTips(){
        DispatchQueue.main.async {
            share.verifyCodeTipsView.removeFromSuperview()
            share.verifyCodeTipsView.isHidden = true
        }
    }
    
    //MARK: - 表盘传输
    class func showDialTransport(){
        DispatchQueue.main.async {
            share.dialTransportView.setProgress("", 0)
            share.dialTransportView.isHidden = false
            share.mWindow?.addSubview(share.dialTransportView)
            share.dialTransportView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    class func getDialTransport() -> AlertViewDialTransport{
        return share.dialTransportView
    }
    
    class func removeDialTransport(){
        DispatchQueue.main.async {
            share.dialTransportView.removeFromSuperview()
            share.dialTransportView.isHidden = true
        }
    }
    
    //MARK: - 删除表盘
    class func showDialDelete(){
        DispatchQueue.main.async {
            share.deleteingView.isHidden = false
            share.mWindow?.addSubview(share.deleteingView)
            share.deleteingView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.deleteingView.startLoading()
        }
    }
    
    class func removeDialDelete(){
        DispatchQueue.main.async {
            share.deleteingView.removeFromSuperview()
            share.deleteingView.isHidden = true
            share.deleteingView.stopLoading()
        }
    }
    
    //MARK: - 连接中
    
    class func showConnecting( tips:String? = nil,timeout:Int = 0) {
        DispatchQueue.main.async {
            share.connectingView.isHidden = false
            share.mWindow?.addSubview(share.connectingView)
            share.connectingView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            share.connectingView.startLoading(tips)
        }
        if timeout > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
                AlertViewOnWindows.removeConnecting()
            }
        }
    }
    
   class func removeConnecting(){
        DispatchQueue.main.async {
            share.connectingView.removeFromSuperview()
            share.connectingView.isHidden = true
            share.connectingView.stopLoading()
        }
    }
}
