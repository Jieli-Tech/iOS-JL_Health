//
//  DataTester.swift
//  JieliJianKang
//
//  Created by EzioChan on 2022/5/26.
//

import Foundation
import JL_BLEKit

@objc public class SportDataTest:NSObject{

    @objc class func readFile(){
        let path = Bundle.main.path(forResource: "aaa", ofType: ".dat") ?? ""
        if let data = try?Data(contentsOf: URL(fileURLWithPath: path)) {
            
            let model = JLSportRecordModel(data: data)
            NSLog("%@", model)
        }

    }
    
}
