//
//  DataTester.swift
//  JieliJianKang
//
//  Created by EzioChan on 2022/5/26.
//

import Foundation
import JL_BLEKit
import CoreImage

@objc public class SportDataTest:NSObject{

    @objc class func readFile(){
        let path = Bundle.main.path(forResource: "test", ofType: ".jpg") ?? ""
        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/test.jpg"
        if let data = try?Data(contentsOf: URL(fileURLWithPath: path)) {
            try?FileManager.default.removeItem(atPath: path1)
            FileManager.default.createFile(atPath: path1, contents: data)
            if let image = UIImage(data: data) {
                let img1 = image.ciImage?.cropped(to: CGRect(x: 0, y: 0, width: 240, height: 296))
                let img2 = img1?.toUIImage(orientation: .up) ?? UIImage()
                let tgPath = OCTest.makeDialwithName("MYTEST", with: CGSize(width: 240, height: 296), image: img2)
                let binData = try?Data(contentsOf: URL(fileURLWithPath: tgPath))
                if let binData = binData {
                    print("binData:\(binData.count) bytes,basic data:\(data.count) bytes")
                }
                
            }
            
        }

    }
    

    
}
  

extension CIImage {
    func toCGImage() -> CGImage? {
        let context = { CIContext(options: nil) }()
        return context.createCGImage(self, from: self.extent)
    }

    func toUIImage(orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = self.toCGImage() else { return nil }
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }
}


