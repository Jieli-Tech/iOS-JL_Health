//
//  AudioManager.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/18.
//

import UIKit
import AVFoundation

@objcMembers class AudioManager: NSObject {

    static let shared = AudioManager()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(outputDeviceChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }

    @objc private func outputDeviceChanged(_ notification:Notification) {
        JLLogManager.logLevel(.DEBUG, content: "outputDeviceChanged\(String(describing: notification.userInfo))")
    }
}
