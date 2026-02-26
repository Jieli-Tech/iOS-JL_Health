//
//  SettingInfo.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/3/1.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class SettingInfo{
    class func saveCustomerBleConnect(_ status:Bool){
        UserDefaults.standard.set(status, forKey: "customerBleConnect")
        UserDefaults.standard.synchronize()
    }
    
    class func getCustomerBleConnect()->Bool{
        return UserDefaults.standard.bool(forKey: "customerBleConnect")
    }
    
    class func savePairEnable(_ status:Bool){
        UserDefaults.standard.set(status, forKey: "pairEnable")
        UserDefaults.standard.synchronize()
    }
    
    class func getPairEnable()->Bool{
        return UserDefaults.standard.bool(forKey: "pairEnable")
    }
    
    class func setToHistory(_ uuid:String){
        UserDefaults.standard.set(uuid, forKey: "toHistory")
        UserDefaults.standard.synchronize()
    }
    class func getToHistory()->String?{
        return UserDefaults.standard.string(forKey: "toHistory")
    }
    
    class func getCustomTransportSupport()->Bool{
        return UserDefaults.standard.bool(forKey: "customTransportSupport")
    }
    
    class func saveCustomTransportSupport(_ status:Bool){
        UserDefaults.standard.set(status, forKey: "customTransportSupport")
        UserDefaults.standard.synchronize()
    }
}
