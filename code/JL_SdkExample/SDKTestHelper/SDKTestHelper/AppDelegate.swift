//
//  AppDelegate.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/2.
//

import UIKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import SnapKit
@_exported import Toast_Swift
@_exported import JLUsefulTools

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let mainVc = MainViewController()
        let navc = NavViewController(rootViewController: mainVc)
        mainVc.navigationController?.setNavigationBarHidden(true, animated: true)
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navc
        self.window?.makeKeyAndVisible()
        
        _R.initFold()
        
        return true
    }




}

