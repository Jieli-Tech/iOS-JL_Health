//
//  ICPViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/11/21.
//

import UIKit
import WebKit

@objcMembers class ICPViewController: BaseViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    var urlStr: String = ""
    override func initUI() {
        super.initUI()
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.insertSubview(webView, at: 0)
        webView.load(URLRequest(url: URL(string: urlStr)!))
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        navigationView.title = LanguageCls.localizableTxt("ICP filing information")
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        JLLogManager.logLevel(.DEBUG, content: "didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        JLLogManager.logLevel(.ERROR, content: "didFail. error: \(error)")
    }

}
