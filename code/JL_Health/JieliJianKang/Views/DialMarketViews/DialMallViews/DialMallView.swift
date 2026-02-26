//
//  DialMallView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit

class DialMallView: BaseView {
    private let scrollView = UIScrollView()
    private let dialFreeView = FreeDialView()
    private let dialPayView = PayDialView()
    
    
    override func initUI() {
        super.initUI()
        addSubview(scrollView)
        backgroundColor = .clear
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let width = UIScreen.main.bounds.size.width
        scrollView.addSubview(dialFreeView)
        dialFreeView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalTo(width)
        }
        scrollView.addSubview(dialPayView)
        
        dialPayView.snp.makeConstraints { make in
            make.top.equalTo(dialFreeView.snp.bottom)
            make.left.right.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(417)
            make.bottom.equalToSuperview()
        }
    }
    
    override func initData() {
        super.initData()
    
    }
    
    override func prepareData() {
        
        let width = UIScreen.main.bounds.size.width
        dialFreeView.vm.itemsArray.subscribe { [weak self] list in
            guard let self = self else {return}
            let count = dialFreeView.vm.itemsArray.value.count
            var add = 0
            if count % 3 != 0 {
                add = 1
            }
            var height = 170 * (count / 3 + add) + 60
            dialFreeView.snp.remakeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(height)
            }
        }.disposed(by: disposeBag)
        dialPayView.vm.itemsArray.subscribe { [weak self] list in
            guard let self = self else {return}
            let count = dialPayView.vm.itemsArray.value.count
            var add = 0
            if count % 3 != 0 {
                add = 1
            }
            var height = 170 * (count / 3 + add) + 60
            dialPayView.snp.remakeConstraints { make in
                make.top.equalTo(self.dialFreeView.snp.bottom)
                make.left.right.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(height)
                make.bottom.equalToSuperview()
            }
            if count == 0 {
                dialPayView.isHidden = true
            }else{
                dialPayView.isHidden = false
            }
            
        }.disposed(by: disposeBag)
    }

}
