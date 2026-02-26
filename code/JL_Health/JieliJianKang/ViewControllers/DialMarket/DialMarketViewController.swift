//
//  DialMarketViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit

@objcMembers class DialMarketViewController: BaseViewController, UINavigationControllerDelegate {
    
    private var titleView: WatchDialTitleView!
    private let scrollView = UIScrollView()
    private let dialMallView = DialMallView()
    private let dialLocalView = DialLocalView()
    private let dialCustomView = CustomDialView(frame: CGRectZero)
    private var selectImageView:PhotoView!
    private var imgPicker:UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JL_Tools.add(kJL_BLE_M_ENTITY_DISCONNECTED, action: #selector(disconnectAction), own: self)
    }
    
    @objc func disconnectAction(){
        JL_Tools.remove(kJL_BLE_M_ENTITY_DISCONNECTED, own: self)
        BridgeHelper.getNavigationController().popToRootViewController(animated: true)
    }
    
    
    override func initUI() {
        super.initUI()
        let window = UIApplication.shared.windows.first
        navigationView.title = LanguageCls.localizableTxt("表盘")
        navigationView.rightBtn.setImage(UIImage.init(named: "dial_icon_record"), for: .normal)
        navigationView.rightBtn.isHidden = false
        
        view.backgroundColor = .white
        let width = UIScreen.main.bounds.size.width
        titleView = WatchDialTitleView(frame: CGRect(x: 57, y: 10, width: width - 57 * 2, height: 35))
        view.addSubview(titleView)
        let sW = UIScreen.main.bounds.size.width
        titleView.callback = { index in
            self.scrollView.setContentOffset(CGPoint(x: sW * CGFloat(index), y: 0), animated: true)
        }        
        titleView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(57)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(35)
        }

        view.addSubview(scrollView)
        
        selectImageView = PhotoView(frame: CGRect(x: 0, y: 0, width: width, height: UIScreen.main.bounds.size.height))
        view.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectImageView.delegate = self
        selectImageView.isHidden = true
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        dialCustomView.delegate = self
        
        scrollView.addSubview(dialMallView)
        scrollView.addSubview(dialLocalView)
        scrollView.addSubview(dialCustomView)
        
        let height = 44 + (window?.safeAreaInsets.top ?? 20) + 45
        
        dialMallView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(width)
            make.right.equalTo(dialLocalView.snp.left)
            make.height.equalTo(UIScreen.main.bounds.size.height - height)
            make.bottom.equalToSuperview()
        }
        
        dialLocalView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(dialMallView.snp.right)
            make.width.equalTo(width)
            make.right.equalTo(dialCustomView.snp.left)
            make.height.equalTo(UIScreen.main.bounds.size.height - height)
            make.bottom.equalToSuperview()
        }
        
        dialCustomView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(dialLocalView.snp.right)
            make.width.equalTo(width)
            make.right.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.height - height)
            make.bottom.equalToSuperview()
        }
        
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe(){ [weak self]_ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        navigationView.rightBtn.rx.tap.subscribe(){ [weak self]_ in
            guard let _ = self else {return}
            BridgeHelper.getNavigationController().pushViewController(DialHistoryViewController(), animated: true)
        }.disposed(by: disposeBag)
        
    }

}

//MARK: - ScrollViewDelegate
extension DialMarketViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let width = UIScreen.main.bounds.size.width
        titleView.handleBtnClick(Int32(offsetX / width))
    }
    
}

// MARK: - CustomDialDelegate
extension DialMarketViewController:CustomDialDelegate {
    
    
    func pushBackAction(_ vc: CustomDialEditVC) {
        BridgeHelper.getNavigationController().pushViewController(vc, animated: true)
    }
    
    func hiddenAction() {
        selectImageView.isHidden = false
    }
    
    func installDial(_ model: CustomDialCellModel) {
        AlertViewOnWindows.showDialTransport()
        AIDialXFManager.share().installDial(toDevice: model.image, withType: 0, originSizeImage: model.originImage) { progress, type in
            switch type {
                case .noSpace:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("空间不足"))
                case .doing:
                    AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在添加"), progress / 100.0)
                case .fail:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("添加失败"))
                case .success:
                    AlertViewOnWindows.getDialTransport().setSuccess()
                    do {
                        try FileManager.default.removeItem(atPath: model.originPath)
                        try FileManager.default.removeItem(atPath: model.filePath)
                    }catch {
                        JLLogManager.logLevel(.ERROR, content: "remove item error: \(error)")
                    }
                    self.dialCustomView.handleReloadData()
                case .unnecessary:
                    break
                case .resetFial:
                    break
                case .normal:
                    break
                case .cmdFail:
                    break
                @unknown default:
                    break
            }
            
        }
    }
    
    
}

// MARK: - PhotoDelegate
extension DialMarketViewController: PhotoDelegate {
    func takePhoto() {
        self.selectImageView.isHidden = true
        makePicker(.camera)
    }
    
    func takePicture() {
        self.selectImageView.isHidden = true
        makePicker(.photoLibrary)
    }
    private func makePicker(_ type:UIImagePickerController.SourceType) {
        imgPicker = UIImagePickerController()
        imgPicker?.delegate = self
        imgPicker?.allowsEditing = true
        imgPicker?.sourceType = type
        imgPicker?.modalPresentationStyle = .fullScreen
        if type == .camera {
            imgPicker?.cameraDevice = .rear
            imgPicker?.cameraFlashMode = .off
        }
        self.present(imgPicker!, animated: true, completion: nil)
    }
}

// MARK: - ImagePicker
extension DialMarketViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.originalImage] as? UIImage else {return}
        let modelFlash = BridgeHelper.getCurrentCmdManager()?.mFlashManager.flashInfo
        let width = Int(modelFlash?.mScreenWidth ?? 0) / 2
        let height = Int(modelFlash?.mScreenHeight ?? 0) / 2
        
        let vc = HQImageEditViewController()
        vc.originImage = img
        vc.maskViewAnimation = true
        vc.editViewSize = CGSize(width: width, height: height)
        vc.delegate = self
        vc.model = BridgeHelper.getDialInfoExtentManager()
        picker.dismiss(animated: true, completion: nil)
        BridgeHelper.getNavigationController().pushViewController(vc, animated: true)
    }
    
}

// MARK: - ImageEdit
extension DialMarketViewController:HQImageEditViewControllerDelegate{
    
    func edit(_ vc: HQImageEditViewController, finishiEditShotImage image: UIImage, originSizeImage: UIImage) {
        vc.navigationController?.popViewController(animated: true)
        AlertViewOnWindows.showDialTransport()
        AIDialXFManager.share().installDial(toDevice: image, withType: 0, originSizeImage: originSizeImage) { progress, type in
            switch type {
                case .noSpace:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("空间不足"))
                case .doing:
                    AlertViewOnWindows.getDialTransport().setProgress(LanguageCls.localizableTxt("正在添加"), progress / 100.0)
                case .fail:
                    AlertViewOnWindows.getDialTransport().setFail(LanguageCls.localizableTxt("添加失败"))
                case .success:
                    AlertViewOnWindows.getDialTransport().setSuccess()
                    self.dialCustomView.handleReloadData()
                case .unnecessary:
                    break
                case .resetFial:
                    break
                case .normal:
                    break
                case .cmdFail:
                    break
                @unknown default:
                    break
            }
            
        }
        
    }
    
    func editControllerDidClickCancel(_ vc: HQImageEditViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
    
    
}

