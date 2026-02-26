//
//  AlarmCollectionViewCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/23.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmDateCollectionCell: UICollectionViewCell {
    let titleLab = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        contentView.addSubview(titleLab)
        titleLab.textColor = .darkText
        titleLab.textAlignment = .center
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        titleLab.adjustsFontSizeToFitWidth = true
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bind(_ item:AlarmDateSelectModel){
        titleLab.text = item.dateStr
        if item.isSelected {
            self.backgroundColor = .blue
            self.titleLab.textColor = .white
        }else{
            self.titleLab.textColor = .darkText
            self.backgroundColor = .gray
        }
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

