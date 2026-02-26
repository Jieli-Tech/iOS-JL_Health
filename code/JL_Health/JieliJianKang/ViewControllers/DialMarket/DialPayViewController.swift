//
//  DialPayViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/20.
//

import UIKit

class DialPayViewController: BaseViewController {
    var dialModel:DialMallModel!
    private let scrollView = UIScrollView()
    private let watchView = UIView()
    private let watchImgv = UIImageView()
    private let watchBgImgv = UIImageView()
    private let watchTitleLab = UILabel()
    private let watchSubTitleLab = UILabel()
    private let line = UIView()
    private let detailLab = UILabel()
    private let bottomBtn = DialPayBottomView()
    private var isDone:Bool = false
    
    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        navigationView.title = dialModel.name.uppercased()
        view.addSubview(scrollView)
        scrollView.addSubview(watchView)
        watchView.addSubview(watchImgv)
        watchView.addSubview(watchBgImgv)
        scrollView.addSubview(line)
        scrollView.addSubview(watchTitleLab)
        scrollView.addSubview(watchSubTitleLab)
        scrollView.addSubview(detailLab)
        scrollView.addSubview(bottomBtn)
        
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(40)
            make.left.right.bottom.equalToSuperview()
        }
        let width = UIScreen.main.bounds.size.width
        scrollView.addSubview(watchView)
        watchView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.height.equalTo(254)
            make.centerX.equalToSuperview()
        }
        
        watchImgv.kf.setImage(with: URL(string: dialModel.icon))
        watchImgv.contentMode = .scaleAspectFit
        watchImgv.snp.makeConstraints { make in
            make.width.equalTo(BridgeHelper.getDialInfoExtentManager().shape == 0x01 ? 148 : 114)
            make.height.equalTo(BridgeHelper.getDialInfoExtentManager().shape == 0x01 ? 148 : 174)
            make.centerX.equalTo(watchView)
            make.centerY.equalTo(watchView).offset(BridgeHelper.getDialInfoExtentManager().shape == 0x01 ? 0 : -5)
        }
        watchBgImgv.contentMode = .scaleAspectFit
        watchBgImgv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        watchTitleLab.text = dialModel.name.uppercased()
        watchTitleLab.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        watchTitleLab.textColor = .eHex("#242424")
        watchTitleLab.textAlignment = .center
        watchTitleLab.snp.makeConstraints { make in
            make.top.equalTo(watchView.snp.bottom).offset(20)
            make.width.equalTo(width)
        }
        
        if dialModel.price == 0 {
            watchSubTitleLab.text = LanguageCls.localizableTxt("免费")
        }else{
            watchSubTitleLab.text = LanguageCls.localizableTxt("杰币") + "\(dialModel.price/100)"
        }
        watchSubTitleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        watchSubTitleLab.textColor = .eHex("#558CFF")
        watchSubTitleLab.textAlignment = .center
        watchSubTitleLab.snp.makeConstraints { make in
            make.top.equalTo(watchTitleLab.snp.bottom).offset(8)
            make.width.equalTo(width)
        }
        
        line.backgroundColor = .eHex("#EAEAEA")
        line.snp.makeConstraints { make in
            make.top.equalTo(watchSubTitleLab.snp.bottom).offset(40)
            make.width.equalTo(width - 48)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        detailLab.text = dialModel.content == "" ? "表盘简介：杰理智能表盘" : dialModel.content
        detailLab.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        detailLab.textColor = .eHex("#242424")
        detailLab.numberOfLines = 0
        detailLab.textAlignment = .left
        detailLab.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(30)
            make.left.equalToSuperview().inset(24)
            make.height.greaterThanOrEqualTo(20)
            make.width.equalTo(width - 48)
            
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.top.equalTo(detailLab.snp.bottom).offset(70)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(30)
        }
        
    }
    
    override func initData() {
        super.initData()
        watchBgImgv.image = UIImage(named: "img_watch_254")
        if BridgeHelper.getDialInfoExtentManager().shape == 0x01 {
            watchBgImgv.image = UIImage(named: "img_watch_254")
        }else if BridgeHelper.getDialInfoExtentManager().shape == 0x02
                    || BridgeHelper.getDialInfoExtentManager().shape == 0x03 {
            watchBgImgv.image = UIImage(named: "img_watch_254_02")
        }
        if dialModel.price == 0 {
            bottomBtn.setTitle(LanguageCls.localizableTxt("下载"))
        }else{
            if !dialModel.status {
                bottomBtn.setTitle(LanguageCls.localizableTxt("购买"))
            } else {
                bottomBtn.setTitle(LanguageCls.localizableTxt("下载"))
            }
        }
        bottomBtn.buyBtnSingle.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.isDone {
                BridgeHelper.getNavigationController().popViewController(animated: true)
                return
            }
            if self.dialModel.price == 0 {
                DialMarketHttp.shared.payFreeDial(dialModel.id) {  status in
                    if status == false {
                        AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("购买失败"))
                        return
                    }
                    self.downloadAction()
                }
            }else{
                buyDial()
            }
        }).disposed(by: disposeBag)
        
        navigationView.leftBtn.rx.tap.subscribe(){ [weak self]_ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
    }
    
    private func buyDial() {
        JLUI_Effect.startLoadingView(LanguageCls.localizableTxt("支付中"), delay: 60.0 * 10)
        StoreIAPManager.shareSIAP().startPurch(withID: self.dialModel.productId) { type, msg in
            if type == .purchSuccess {
                DispatchQueue.main.async {
                    JLUI_Effect.setLoadingText(LanguageCls.localizableTxt("支付成功，等待支付结果..."))
                    DialMarketHttp.shared.verifyPayId(self.dialModel.id, false, msg) { status in
                        JLUI_Effect.removeLoadingView()
                        if status {
                            self.downloadAction()
                        }else{
                            AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("购买失败"))
                        }
                    }
                }
            }
            if type != .purchasing ,type != .purchSuccess {
                DispatchQueue.main.async {
                    JLUI_Effect.removeLoadingView()
                    AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("购买失败"))
                }
            }
        }
    }
    
    private func downloadAction(){
        DialMarketHttp.shared.requireDownloadDialInfo(self.dialModel.id) { info in
            guard let info = info else {return}
            DialMarketHttp.shared.downloadWatch(info.url) { data, progress, isDone in
                DispatchQueue.main.async {
                    self.bottomBtn.setProgress(progress)
                    JLLogManager.logLevel(.DEBUG, content: "downloadWatch: \(info.url) progress: \(progress) done: \(isDone)")
                    if isDone {
                        guard let data = data else {return}
                        let watchPath = "/" + self.dialModel.name.uppercased()
                        DialManager.addFile(watchPath, content: data) { flag, progress in
                            switch flag {
                                case .noSpace:
                                    self.bottomBtn.setTitle(LanguageCls.localizableTxt("下载"))
                                    self.bottomBtn.setProgress(1.0)
                                    self.bottomBtn.setBuyBtnEnable(true)
                                    AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("空间不足"))
                                case .doing:
                                    self.bottomBtn.setProgress(progress)
                                case .fail:
                                    self.bottomBtn.setTitle(LanguageCls.localizableTxt("下载"))
                                    self.bottomBtn.setProgress(1.0)
                                    self.bottomBtn.setBuyBtnEnable(true)
                                    AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("添加失败"))
                                case .success:
                                    self.bottomBtn.setProgress(1.0)
                                    self.bottomBtn.setTitle(LanguageCls.localizableTxt("完成"))
                                    self.bottomBtn.setBuyBtnEnable(true)
                                    AlertViewOnWindows.getFirstWindow()?.makeToast(LanguageCls.localizableTxt("添加成功"))
                                    BridgeHelper.getCurrentCmdManager()?.mFlashManager.cmdWatchFlashPath(watchPath, flag: .setDial) { flag, size, path, describe in
                                        if flag == 0 {
                                            BridgeHelper.dialCache().setCurrrentWatchName(self.dialModel.name.uppercased())
                                            BridgeHelper.dialCache().addWatchListObject(self.dialModel.name.uppercased())
                                            BridgeHelper.dialCache().addVersion(self.dialModel.version, toWatch: self.dialModel.name.uppercased())
                                            BridgeHelper.dialCache().setUuidOfWatch(self.dialModel.name.uppercased(), uuid: self.dialModel.uuid)
                                            self.isDone = true
                                        }
                                    }
                                default:
                                    break
                            }
                        }
                    }
                }
            }
        }
    }
    
}
