//
//  AutoProductIcon.swift
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/14.
//

import UIKit

@objcMembers public class AutoProductIcon: NSObject {
    
    static let share = AutoProductIcon()
    private var loadingArray:[String] = []
    
    public override init() {
        super.init()
    }
    
    func getDeviceProductUrl(pid:String,vid:String){
        let tempStr = pid+"_"+vid;
        if let local = checkImgUrl(pid, vid){
            debugPrint("get local path With:\(tempStr) \npath:\(local)")
            NotificationCenter.default.post(name: NSNotification.Name("AutoProductImgv"), object: nil)
        }else{
            if let _ = loadingArray.firstIndex(where: {$0 == tempStr}){
                
            }else{
                self.loadingArray.append(tempStr)
                JLWatchHttp.requestWatchInfoPid(Int32(pid) ?? 2, vid: Int32(vid) ?? 130) { dict in
                    debugPrint("getDeviceProductUrl:\(dict)")
                    if let code = dict["code"] as? Int{
                        if code == 0{
                            if let data = dict["data"] as? [AnyHashable:Any]{
                                let v = data["icon"] as? String
                                self.saveToLocal(pid, vid, v)
                                DispatchQueue.main.sync {
                                    NotificationCenter.default.post(name: NSNotification.Name("AutoProductImgv"), object: nil)
                                }
                            }
                        }
                    }
                    self.loadingArray.removeAll(where: {$0 == tempStr})
                }
            }
        }
    }
    
    
    func saveToLocal(_ pid:String,_ vid:String,_ url:String?){
        debugPrint("save local path pid:\(pid)+vid:\(vid) \npath:\(String(describing: url))")
        if let u = url {
            UserDefaults.standard.set(u, forKey: pid+"_"+vid)
        }else{
            UserDefaults.standard.removeObject(forKey: pid+"_"+vid)
        }
    }
    
    
    func saveToLocal(pid:Int,vid:Int,_ url:String?){
        let str = beString(value: pid)+"_"+beString(value: vid)
        debugPrint("saveToLocal local path pid_vid:\(str)\npath:\(String(describing: url))")
        if let u = url {
            UserDefaults.standard.set(u, forKey: str)
        }else{
            UserDefaults.standard.removeObject(forKey: str)
        }
    }
    
    private func beString(value:Int)->String{
        var str = String(value)
        str = addZero(value: str)
        return str
    }
    
    private func addZero(value:String)->String{
        
        if value.count<4{
            return addZero(value: "0"+value)
        }else{
            return value
        }
    }
    func checkImgUrl(_ pid:String,_ vid:String)->String?{
        UserDefaults.standard.value(forKey: pid+"_"+vid) as? String
//        UIImageView().sd_setImage(with: URL(string: url)!, placeholderImage: UIImage.init(named: "img_watch_128_2"))
        
    }
    


}
