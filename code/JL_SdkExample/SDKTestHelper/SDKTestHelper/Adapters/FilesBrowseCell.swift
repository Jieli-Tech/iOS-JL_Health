//
//  FilesBrowseCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/27.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class FilesBrowseCell: UICollectionViewCell {
    
    let mainLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    func initUI() {
        addSubview(mainLabel)
        mainLabel.font = UIFont.systemFont(ofSize: 14)
        mainLabel.textAlignment = .center
        mainLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.layer.cornerRadius = 15
        self.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








