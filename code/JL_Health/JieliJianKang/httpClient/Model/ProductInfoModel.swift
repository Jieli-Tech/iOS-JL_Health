//
//  ProductInfoModel.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

import UIKit

@objcMembers class ProductInfoModel: NSObject {
    var idString = ""
    var uuid = ""
    var vid = 0
    var pid = 0
    var title = ""
    var type = ""
    var icon = ""
    var width = 0
    var height = 0
    var content = ""
    var configData:ProductInfoConfigDataModel = ProductInfoConfigDataModel("")
    var createTime = ""
    var updateTime = ""
    var explain = ""
    init(_ dict: [String:Any]) {
        super.init()
        self.idString = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.vid = dict["vid"] as? Int ?? 0
        self.pid = dict["pid"] as? Int ?? 0
        self.title = dict["title"] as? String ?? ""
        self.type = dict["type"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.width = dict["width"] as? Int ?? 0
        self.height = dict["height"] as? Int ?? 0
        self.content = dict["content"] as? String ?? ""
        self.explain = dict["explain"] as? String ?? ""
        self.configData = ProductInfoConfigDataModel(dict["configData"] as? String ?? "")
        self.createTime = dict["createTime"] as? String ?? ""
        self.updateTime = dict["updateTime"] as? String ?? ""
        JLLogManager.logLevel(.DEBUG, content: "ProductInfoModel:\(dict)")
    }
}

@objcMembers class ProductInfoConfigDataModel: NSObject {
    var supportOta = false
    var supportDialPayment = false
    init(_ dictStr: String) {
        super.init()
        let data = dictStr.replacingOccurrences(of: "'", with: "\"").data(using: .utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
            if let supportOta = dict["support_ota"] as? Bool {
                self.supportOta = supportOta
            }
            if let supportDialPayment = dict["support_dial_payment"] as? Bool {
                self.supportDialPayment = supportDialPayment
            }
        }
    }
}

@objcMembers class DialNetInfoModel: NSObject {
    var idString = ""
    var uuid = ""
    var dialid = ""
    var name = ""
    var version = ""
    var content = ""
    var url = ""
    var icon = ""
    var createTime = ""
    var updateTime = ""
    var explain = ""
    init(_ dict: [String:Any]) {
        super.init()
        self.idString = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.dialid = dict["dialid"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.url = dict["url"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.createTime = dict["createTime"] as? String ?? ""
        self.updateTime = dict["updateTime"] as? String ?? ""
        self.explain = dict["explain"] as? String ?? ""
    }
    
}


@objcMembers class DialMallModel: NSObject {
    var dialid = ""
    var productId = ""
    var updateTime = ""
    var createTime = ""
    /// 单价，单位是分，需要APP换算成元
    var price = 0
    var name = ""
    var icon = ""
    /// 传入该ID，进行付款，创建付款账单是需要传入该ID
    var id = ""
    ///这里的uuid用来获取单个表盘详细信息
    var uuid = ""
    var version = ""
    var content = ""
    ///表示用户是否已经购买过
    var status = false

    init(_ dict: [String:Any]) {
        super.init()
        self.dialid = dict["dialid"] as? String ?? ""
        self.productId = dict["productId"] as? String ?? ""
        self.updateTime = dict["updateTime"] as? String ?? ""
        self.createTime = dict["createTime"] as? String ?? ""
        self.price = dict["price"] as? Int ?? 0
        self.name = dict["name"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.id = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.status = dict["status"] as? Bool ?? false
        self.logProperties()
    }
}

@objcMembers class DialMallRecords: NSObject {
    var records:[DialMallModel] = []
    var total:Int = 0
    var size:Int = 0
    var current:Int = 0
    var orders:[String] = []
    var hitCount:Bool = false
    var searchCount:Bool = false
    var pages:Int = 0

    init(_ dict: [String:Any]) {
        super.init()
        let records = dict["records"] as? [[String:Any]] ?? [[:]]
        for item in records {
            let model = DialMallModel(item)
            self.records.append(model)
        }
        self.total = dict["total"] as? Int ?? 0
        self.size = dict["size"] as? Int ?? 0
        self.current = dict["current"] as? Int ?? 0
        self.orders = dict["orders"] as? [String] ?? []
        self.hitCount = dict["hitCount"] as? Bool ?? false
        self.searchCount = dict["searchCount"] as? Bool ?? false
        self.pages = dict["pages"] as? Int ?? 0
        JLLogManager.logLevel(.DEBUG, content: "DialMallRecords:\n\(dict)")
    }
    
}


@objcMembers class DialPageBodyModel: NSObject {
    var pid:Int = 0
    var vid:Int = 0
    var page:Int = 1
    var size:Int = 20
    var versions:[String] = []
    
    init(pid: Int, vid: Int, page: Int, size: Int, versions: [String]) {
        self.pid = pid
        self.vid = vid
        self.page = page
        self.size = size
        self.versions = versions
    }
    
    func beJSONData() -> Data {
        var dict = [String:Any]()
        dict["pid"] = pid
        dict["vid"] = vid
        dict["page"] = page
        dict["size"] = size
        dict["versions"] = versions
        return (try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)) ?? Data()
    }
}

@objcMembers class DialPageModel: NSObject {
    
    var id = ""
    var uuid = ""
    var dialid = ""
    var name = ""
    var version = ""
    var content = ""
    var url = ""
    var icon = ""
    var createTime = ""
    var updateTime = ""
    var explain = ""
    
    init(_ dict: [String:Any]) {
        super.init()
        self.id = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.dialid = dict["dialid"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.url = dict["url"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.createTime = dict["createTime"] as? String ?? ""
        self.updateTime = dict["updateTime"] as? String ?? ""
        self.explain = dict["explain"] as? String ?? ""
    }
    
}


@objcMembers class DialPageRecords: NSObject {
    var records:[DialPageModel] = []
    var total:Int = 0
    var size:Int = 0
    var current:Int = 0
    var orders:[String] = []
    var hitCount:Bool = false
    var searchCount:Bool = false
    var pages:Int = 0
    
    init(_ dict: [String:Any]) {
        super.init()
        let records = dict["records"] as? [[String:Any]] ?? [[:]]
        for item in records {
            let model = DialPageModel(item)
            self.records.append(model)
        }
        self.total = dict["total"] as? Int ?? 0
        self.size = dict["size"] as? Int ?? 0
        self.current = dict["current"] as? Int ?? 0
        self.orders = dict["orders"] as? [String] ?? []
        self.hitCount = dict["hitCount"] as? Bool ?? false
        self.searchCount = dict["searchCount"] as? Bool ?? false
        self.pages = dict["pages"] as? Int ?? 0
        JLLogManager.logLevel(.DEBUG, content: "DialPageRecords\n\(dict)")
    }
}

@objcMembers class DialFreeDownloadModel: NSObject {
    
    var id = ""
    var uuid = ""
    var dialid = ""
    var name = ""
    var version = ""
    var content = ""
    var url = ""
    var icon = ""
    var createTime = ""
    var updateTime = ""
    var explain = ""
    
    init(_ dict: [String:Any]) {
        super.init()
        self.id = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.dialid = dict["dialid"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.url = dict["url"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.createTime = dict["createTime"] as? String ?? ""
        self.updateTime = dict["updateTime"] as? String ?? ""
        self.explain = dict["explain"] as? String ?? ""
        self.logProperties()
    }
}

@objcMembers class DialPayDownloadModel: NSObject {
    var id = ""
    var uuid = ""
    var dialid = ""
    var name = ""
    var version = ""
    var content = ""
    var price = 0
    var url = ""
    var icon = ""
    var createTime = ""
    var updateTime = ""
    var explain = ""
    
    init(_ dict: [String:Any]) {
        super.init()
        self.id = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.dialid = dict["dialid"] as? String ?? ""
        self.name = dict["name"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.price = dict["price"] as? Int ?? 0
        self.url = dict["url"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.createTime = dict["createTime"] as? String ?? ""
        self.updateTime = dict["updateTime"] as? String ?? ""
        self.explain = dict["explain"] as? String ?? ""
        JLLogManager.logLevel(.DEBUG, content: "DialPayDownloadModel\n\(dict)")
    }
    
}


@objcMembers class DialHistoryRecordModel:NSObject {
    var id:String = ""
    var userid:String = ""
    var shopid:String = ""
    var dialid:String = ""
    var orderNumber:String = ""
    var price:Int = 0
    var payType:String = ""
    var status:Bool = false
    var createTime:String = ""
    var payTime:String = ""
    
    init(_ dict:[String:Any]) {
        super.init()
        self.id = dict["id"] as? String ?? ""
        self.userid = dict["userid"] as? String ?? ""
        self.shopid = dict["shopid"] as? String ?? ""
        self.dialid = dict["dialid"] as? String ?? ""
        self.orderNumber = dict["orderNumber"] as? String ?? ""
        self.price = dict["price"] as? Int ?? 0
        self.payType = dict["payType"] as? String ?? ""
        self.status = dict["status"] as? Bool ?? false
        self.createTime = dict["createTime"] as? String ?? ""
        self.payTime = dict["payTime"] as? String ?? ""
    }
}

@objcMembers class DialHistoryRecords: NSObject {
    
    var records:[DialHistoryRecordModel] = []
    var total:Int = 0
    var size:Int = 0
    var current:Int = 0
    var orders:[String] = []
    var hitCount:Bool = false
    var searchCount:Bool = false
    var pages:Int = 0
    
    init(_ dict:[String:Any]) {
        super.init()
        let records = dict["records"] as? [[String:Any]] ?? [[:]]
        for item in records {
            let model = DialHistoryRecordModel(item)
            self.records.append(model)
        }
        self.total = dict["total"] as? Int ?? 0
        self.size = dict["size"] as? Int ?? 0
        self.current = dict["current"] as? Int ?? 0
        self.orders = dict["orders"] as? [String] ?? []
        self.hitCount = dict["hitCount"] as? Bool ?? false
        self.searchCount = dict["searchCount"] as? Bool ?? false
        self.pages = dict["pages"] as? Int ?? 0
        JLLogManager.logLevel(.DEBUG, content: "DialHistoryRecords\n\(dict)")
    }
    
}


@objcMembers class DialPayHistoryModel:NSObject {
    var dialid = ""
    var updateTime = ""
    var createTime = ""
    var price = 0
    var name = ""
    var icon = ""
    var id = ""
    var uuid = ""
    var version = ""
    var content = ""
    var status = false

    init(_ dict: [String:Any]) {
        super.init()
        self.dialid = dict["dialid"] as? String ?? ""
        self.updateTime = dict["update_time"] as? String ?? ""
        self.createTime = dict["create_time"] as? String ?? ""
        self.price = dict["price"] as? Int ?? 0
        self.name = dict["name"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.id = dict["id"] as? String ?? ""
        self.uuid = dict["uuid"] as? String ?? ""
        self.version = dict["version"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.status = dict["status"] as? Bool ?? false
    }
}

@objcMembers class DialPayHistoryRecord: NSObject {
    var records:[DialPayHistoryModel] = []
    var total:Int = 0
    var size:Int = 0
    var current:Int = 0
    var orders:[String] = []
    var hitCount:Bool = false
    var searchCount:Bool = false
    var pages:Int = 0
    
    init(_ dict: [String:Any]) {
        super.init()
        let records = dict["records"] as? [[String:Any]] ?? [[:]]
        for item in records {
            let model = DialPayHistoryModel(item)
            self.records.append(model)
        }
        self.total = dict["total"] as? Int ?? 0
        self.size = dict["size"] as? Int ?? 0
        self.current = dict["current"] as? Int ?? 0
        self.orders = dict["orders"] as? [String] ?? []
        self.hitCount = dict["hitCount"] as? Bool ?? false
        self.searchCount = dict["searchCount"] as? Bool ?? false
        self.pages = dict["pages"] as? Int ?? 0
        JLLogManager.logLevel(.DEBUG, content: "DialPayHistoryRecord\n\(dict)")
    }
}
