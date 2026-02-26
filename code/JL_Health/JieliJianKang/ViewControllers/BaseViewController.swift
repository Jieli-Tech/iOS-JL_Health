//
//  BaseViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit


class NaviView: BaseView {
    public let bgView = UIView()
    public let leftBtn = UIButton()
    public let rightBtn = UIButton()
    public let titleLab = UILabel()
    open var bgColor = UIColor.eHex("#000000", alpha: 0.04)

    var title: String {
        get {
            titleLab.text ?? ""
        }
        set {
            titleLab.text = newValue
        }
    }

    override func initUI() {

        self.addSubview(bgView)
        self.addSubview(leftBtn)
        self.addSubview(titleLab)
        self.addSubview(rightBtn)
        bgView.backgroundColor = .white

        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightBtn.setTitleColor(.white, for: .normal)
        rightBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        rightBtn.isHidden = true

        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        leftBtn.setTitleColor(.white, for: .normal)
        leftBtn.setImage(UIImage(named: "icon_return_nol"), for: .normal)
        leftBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.textColor = .eHex("#242424")
        titleLab.textAlignment = .center
        titleLab.adjustsFontSizeToFitWidth = true

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        leftBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.centerY.equalTo(titleLab.snp.centerY)
        }
        titleLab.snp.makeConstraints { make in
            make.bottom.equalTo(self).inset(6)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }

        rightBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.centerY.equalTo(titleLab.snp.centerY)
        }

    }
}

class BaseViewController: UIViewController {
    open var navigationView = NaviView()
    open var disposeBag = DisposeBag()
    open var canNotPushBack: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationView)
        view.backgroundColor = .eHex("#F6F7F8")
        let window = UIApplication.shared.windows.first
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top).inset(0)
            make.height.equalTo(44 + (window?.safeAreaInsets.top ?? 20))
            make.left.right.equalTo(view).inset(0)
        }

        initData()
        initUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        if canNotPushBack {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if canNotPushBack {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(willEnterForeground(_:)),
          name: UIApplication.willEnterForegroundNotification,
          object: nil)
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(didBecomeActive(_:)),
          name: UIApplication.didBecomeActiveNotification,
          object: nil)
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(willEnterForeground(_:)),
          name: UIApplication.willResignActiveNotification,
          object: nil)
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(willEnterForeground(_:)),
          name: UIApplication.willTerminateNotification,
          object: nil)
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(willEnterForeground(_:)),
          name: UIApplication.didEnterBackgroundNotification,
          object: nil)
    }
    
    @objc func didBecomeActive(_ noti: Notification) {

    }
    @objc func willEnterForeground(_ noti: Notification) {

    }
    
    @objc func disconnectStatusChange(_ notification: Notification) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func initUI() {

    }

    func initData() {

    }
}
