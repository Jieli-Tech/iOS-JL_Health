//
//  DialMarketHttp.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

import UIKit

/// 表盘市场 HTTP 请求
@objcMembers class DialMarketHttp: NSObject {
    
    @objc static let shared = DialMarketHttp()
    
    private let disposeBag = DisposeBag()
    private let baseUrl = BasicHttp.basicURL()
    private let memoryCapacity = 10 * 1024 * 1024 // 10 MB 内存缓存
    private let diskCapacity = 100 * 1024 * 1024 // 100 MB 磁盘缓存
    private var cache:URLCache!
    private var session:URLSession!
    private var downloadCompletionCallback:((_ data:Data?,_ progress:Float,_ isDone:Bool)->())?
    
    private override init() {
        super.init()
        cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "NetCache")
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        session = URLSession(configuration: config,delegate: self,delegateQueue: .main)
    }
    
    func clearCache() {
        cache.removeAllCachedResponses()
    }
    
    /// 根据pid、vid查询表盘产品信息
    /// - Parameters:
    ///   - pid: pid
    ///   - vid: vid
    ///   - completion: 回调
    func getProductInfo(_ pid:String,_ vid:String, completion:@escaping (_ product:ProductInfoModel?)->()) {
        let url = baseUrl + "/health/v1/api/watch/shop/onebypidvid?pid=" + pid + "&vid=" + vid
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let data = dict["data"] as? [String:Any] {
                        let product = ProductInfoModel(data)
                        completion(product)
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetProductInfo error: \(dict)")
                        completion(nil)
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetProductInfo error: \(String(describing: err))")
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    /// 根据表盘唯一UUID、PID、VID获取表盘信息
    /// - Parameters:
    ///   - pid: pid
    ///   - vid: vid
    ///   - uuid: uuid
    ///   - completion: 回调
    func getDialInfo(_ pid:String,_ vid:String,_ uuid:String,_ isPay:Bool, completion:@escaping (_ dial:DialNetInfoModel?)->()) {
        
        var url = baseUrl + "/health/v1/api/watch/dial/version/onebyuuid?uuid=" + uuid + "&pid=" + pid + "&vid=" + vid
        if isPay {
            url = baseUrl + "/health/v1/api/watch/shop/onebyuuid?uuid=" + uuid + "&pid=" + pid + "&vid=" + vid
        }
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let data = dict["data"] as? [String:Any] {
                        let dial = DialNetInfoModel(data)
                        completion(dial)
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialInfo error: \(dict)")
                        completion(nil)
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialInfo error: \(String(describing: err))")
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    
    /// 根据pid、vid、version获取表盘列表
    /// 针对表盘信息不支持支付表盘业务的设备
    /// - Parameters:
    ///   - body: body
    ///   - completion: 回调
    func getDialList(_ body:DialPageBodyModel, completion:@escaping (_ record:DialPageRecords?)->()) {
        let url = baseUrl + "/health/v1/api/watch/dial/version/pagebyversion"
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .reloadIgnoringLocalCacheData,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        request.httpBody = body.beJSONData()
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let data = dict["data"] as? [String:Any] {
                        let record = DialPageRecords(data)
                        DispatchQueue.main.async {
                            completion(record)
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialList error: \(dict)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialList error: \(String(describing: err))")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    /// 获取表盘商城列表
    /// - Parameters:
    ///   - dialId: 表盘 ID 从获取手表产品信息回来，ProductInfoModel.idString
    ///   - page: 分页，从 1 开始
    ///   - size: 每页条数
    ///   - isfree: 是否免费
    ///   - completion: 回调
    func getDialMallList(_ dialId:String,_ page:Int,_ size:Int, _ isfree:Bool,completion:@escaping (_ list:DialMallRecords?)->()) {
        let url = baseUrl + "/health/v1/api/watch/shop/page?dialid=" + dialId + "&page=" + String(page) + "&size=" + String(size) + "&isfree=" + String(isfree)
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let data = dict["data"] as? [String:Any] {
                        let records = DialMallRecords(data)
                        DispatchQueue.main.async {
                            completion(records)
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialMallList error: \(dict)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialMallList error: \(String(describing: err))")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }else{
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetDialMallList error: \(String(describing: err))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    
    /// 获取免费表盘信息
    /// - Parameters:
    ///   - uuid: 表盘的 UUID
    ///   - pid: pid
    ///   - vid: vid
    ///   - completion: 回调
    func requireDownloadDialInfoFree(_ uuid:String,_ pid:Int,_ vid:Int,_ completion:@escaping (DialFreeDownloadModel?)->()) {
        
        let url = baseUrl + "/health/v1/api/watch/dial/version/onebyuuid?uuid=" + uuid + "&pid=" + String(pid) + "&vid=" + String(vid)
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let data = dict["data"] as? [String:Any] {
                        let model = DialFreeDownloadModel(data)
                        DispatchQueue.main.async {
                            completion(model)
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nrequireDownloadDialInfoFree error: \(dict)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nrequireDownloadDialInfoFree error: \(String(describing: err))")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }else{
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nrequireDownloadDialInfoFree error: \(String(describing: err))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
    
    /// 查询表盘下载信息
    /// - Parameters:
    ///   - dialId: 表盘 ID 从获取表盘商城回调的 id
    ///   - completion: 回调
    func requireDownloadDialInfo(_ dialId:String,_ completion:@escaping (DialPayDownloadModel?)->()) {
        let url = baseUrl + "/health/v1/api/watch/shop/downloadbyid?id=" + dialId
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let data = dict["data"] as? [String:Any] {
                        let model = DialPayDownloadModel(data)
                        completion(model)
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nrequireDownloadDialInfo error: \(dict)")
                        completion(nil)
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nrequireDownloadDialInfo error: \(String(describing: err))")
                    completion(nil)
                }
            }else{
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nrequireDownloadDialInfo error: \(String(describing: err))")
                completion(nil)
            }
        }
        dataTask.resume()
    }
    
    /// 下载表盘
    /// - Parameters:
    ///   - url: 下载地址
    ///   - completion: 回调
    func downloadWatch(_ url:String,_ completion:@escaping (_ data:Data?,_ progress:Float,_ isDone:Bool)->()) {
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .returnCacheDataElseLoad,timeoutInterval: 10)
        downloadCompletionCallback = completion
        let dataTask = session.downloadTask(with: request as URLRequest)
        dataTask.resume()
    }
    
    /// 支付购买表盘
    /// - Parameters:
    ///   - id: 表盘 ID
    ///   - completion: 回调
    func payFreeDial(_ id:String,_ completion:@escaping (_ status:Bool)->Void ) {
        let url = baseUrl + "/health/v1/api/watch/shop/freepay?shopid=" + id
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let dataTask = makeTask(request){ (data, err) in
            if let data = data {
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int{
                        DispatchQueue.main.async {
                            if code == 0 || code == -10041 {
                                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\npayFreeDial success: \(dict)")
                                completion(true)
                            }else{
                                completion(false)
                                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\npayFreeDial error: \(dict)")
                            }
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\npayFreeDial error: \(dict)")
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\npayFreeDial error: \(String(describing: err))")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }else{
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\npayFreeDial error: \(String(describing: err))")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        dataTask.resume()
    }
    
    
    /// 苹果支付账单验证
    /// - Parameters:
    ///   - shopid: shopId传入 根据产品表盘ID获取表盘市场 接口返回的id
    ///   - isSandBox: //是否沙盒模式
    ///   - receiptData: receiptData
    ///   - completion: 回调
    func verifyPayId(_ shopid:String,_ isSandBox:Bool,_ receiptData:String,_ completion:@escaping (_ status:Bool)->Void ) {
        let url = baseUrl + "/health/v1/api/watch/shop/payment/verify"
        let dict = ["shopId":shopid,"isSandBox":isSandBox,"receiptData":receiptData] as [String : Any]
        let body = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let req = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        req.httpBody = body
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let task = self.makeTask(req) { dt, err in
            if let err = err {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nverifyPayId error: \(String(describing: err))")
                DispatchQueue.main.async {
                    completion(false)
                }
            }else{
                if let data = dt,let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let status = dict["data"] as? Bool {
                        JLLogManager.logLevel(.DEBUG, content: "verifyPayId success: \(url)")
                        DispatchQueue.main.async {
                            completion(status)
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nverifyPayId error: \(dict)")
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nverifyPayId error: \(String(describing: dt))")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
        task.resume()
    }
    
    /// 销毁购买记录
    /// - Parameters:
    ///   - id: 购买 ID
    ///   - completion: 回调
    func removeBuyHistory(_ id:String,_ completion:@escaping (_ status:Bool)->Void ) {
        let url = baseUrl + "/health/v1/api/watch/shop/payment/removebyid?id=" + id
        let request = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .reloadIgnoringLocalCacheData,timeoutInterval: 5)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let task = self.makeTask(request) { dt, err in
            if let err = err {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nremoveBuyHistory error: \(String(describing: err))")
                completion(false)
            }else{
                if let data = dt,let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let status = dict["data"] as? Bool {
                        JLLogManager.logLevel(.DEBUG, content: "removeBuyHistory success: \(url)")
                        completion(status)
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nremoveBuyHistory error: \(dict)")
                        completion(false)
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\nremoveBuyHistory error: \(String(describing: dt))")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    
    /// 查询购买记录(针对帐号的查询）
    /// - Parameters:
    ///   - page: page
    ///   - size: size
    ///   - completion: 回调
    func checkAccountBuyHistory(_ page:Int,_ size:Int,_ completion:@escaping (_ models:DialHistoryRecords?)->Void ) {
        let url = baseUrl + "/health/v1/api/watch/shop/payment/record/page?page=\(page)&size=\(size)"
        let req = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let task = self.makeTask(req) { dt, err in
            if let err = err {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory error: \(String(describing: err))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }else{
                if let data = dt,let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let list = dict["data"] as? [String:Any] {
                        JLLogManager.logLevel(.DEBUG, content: "checkBuyHistory success: \(url)")
                        DispatchQueue.main.async {
                            completion(DialHistoryRecords(list))
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory error: \(dict)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory error: \(String(describing: dt))")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    /// 查询购买记录(针对手表 DialID)
    /// - Parameters:
    ///   - dialid: 手表 ID
    ///   - page: page
    ///   - size: size
    ///   - completion: 回调
    func checkBuyHistory(_ dialid:String,_ page:Int,_ size:Int,_ completion:@escaping (_ models:DialPayHistoryRecord?)->Void ) {
        let url = baseUrl + "/health/v1/api/watch/shop/payment/page?dialid=\(dialid)&page=\(page)&size=\(size)"
        let req = NSMutableURLRequest(url: URL(string: url)!,cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = [
            "jwt-token":User_Http.shareInstance().token,
            "Content-Type": "application/json",
        ]
        let task = self.makeTask(req) { dt, err in
            if let err = err {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory error: \(String(describing: err))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }else{
                if let data = dt,let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    if let code = dict["code"] as? Int,code == 0,let list = dict["data"] as? [String:Any] {
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory success: \(url)")
                        DispatchQueue.main.async {
                            completion(DialPayHistoryRecord(list))
                        }
                    }else{
                        JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory error: \(dict)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }else{
                    JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ncheckBuyHistory error: \(String(describing: dt))")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
    

    //MARK: - private
    private func makeTask(_ request:NSMutableURLRequest,_ completion:@escaping (Data?,Error?)->()) -> URLSessionDataTask {
        return session.dataTask(with: request as URLRequest, completionHandler: { [weak self](responseData, response, err) in
            guard let self = self else {return}
            let url = request.url?.absoluteString ?? ""
            if err != nil {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetProductInfo error: \(String(describing: err)), url: \(url),response: \(String(describing: response))")
                completion(nil,err)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetProductInfo error: \(String(describing: response))")
                let err = NSError(domain: response?.description ?? "", code:0, userInfo: nil)
                completion(nil,err)
                return
            }
            guard let data = responseData else {
                JLLogManager.logLevel(.DEBUG, content: "url:\(url)\ngetProductInfo error: data is nil")
                let err = NSError(domain: "data is nil", code:0, userInfo: nil)
                completion(nil, err)
                return
            }
            // 检查是否从缓存中获取数据
            if let cachedResponse = self.cache.cachedResponse(for: URLRequest(url: URL(string: url)!)) {
                //                JLLogManager.logLevel(.DEBUG, content: "getProductInfo from cache: \(url)")
                completion(cachedResponse.data, nil)
                return
            }
            completion(data, nil)
        })
    }
    
    
}



extension DialMarketHttp: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        JLLogManager.logLevel(.DEBUG, content: "didFinishDownloadingTo: \(location)")
        let data = try? Data(contentsOf: location)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            downloadCompletionCallback?(data,1.0,true)
            downloadCompletionCallback = nil
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        JLLogManager.logLevel(.DEBUG, content: "bytesWritten: \(bytesWritten) totalBytesWritten: \(totalBytesWritten) totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.downloadCompletionCallback?(nil,progress,false)
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error = error {
            JLLogManager.logLevel(.DEBUG, content: "urlSession Error: \(error)")
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {return}
                downloadCompletionCallback?(nil,0.0,true)
            }
        }
    }
    
}
