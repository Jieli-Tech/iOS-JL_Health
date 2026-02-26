//
//  DialSubView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/10.
//

import UIKit

@objcMembers class DialSubView: BaseView, LanguagePtl {
 
    
    let titleLab = UILabel()
    let editBtn = UIButton()
    let moreImgv = UIImageView()
    var subCollectView:UICollectionView!
    let vm = DialSubViewModel.shared
    var gotoMore:(()->Void)?
    var gotoEdit:((String)->Void)?

   
    override func initUI() {
        super.initUI()
        self.backgroundColor = .white
        self.addSubview(titleLab)
        self.addSubview(editBtn)
        self.addSubview(moreImgv)
        
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLab.text = LanguageCls.localizableTxt("表盘")
        titleLab.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        
        editBtn.setTitle(LanguageCls.localizableTxt("全部"), for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        editBtn.setTitleColor(.eHex("#919191"), for: .normal)
        editBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.height.equalTo(30)
            make.right.equalTo(moreImgv.snp.left).offset(2)
        }
        
        moreImgv.image = UIImage(named: "icon_right_02_dis")
        moreImgv.contentMode = .scaleAspectFit
        moreImgv.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(editBtn)
            make.height.equalTo(30)
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: 100, height: 160)
        subCollectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.addSubview(subCollectView)
        subCollectView.backgroundColor = .white
        subCollectView.showsHorizontalScrollIndicator = false
        subCollectView.register(DialSubCollectionViewCell.self, forCellWithReuseIdentifier: "DialSubCollectionViewCell")
        subCollectView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        vm.itemsArray.bind(to: subCollectView.rx.items(cellIdentifier: "DialSubCollectionViewCell", cellType: DialSubCollectionViewCell.self)) { [weak self](index, model, cell) in
            guard let self = self else {return}
            cell.configCell(self.vm,model)
            
            cell.callBackEdit = { model in
                guard let model = model as? DialSubModel else {
                    return
                }
                self.gotoEdit?(model.model.name)
            }
            cell.callBackStatus = { model in
                guard let model = model as? DialSubModel else {
                    return
                }
                self.vm.setCurrentWatch(model)
            }
            
        }.disposed(by: disposeBag)
        
        subCollectView.rx.itemSelected.subscribe { [weak self] indexPath in
            guard let self = self else {return}
            self.subCollectView.deselectItem(at: indexPath, animated: true)
           JLLogManager.logLevel(.DEBUG, content: "subCell selected: \(indexPath)")
            let model:DialSubModel = self.vm.itemsArray.value[indexPath.row]
            //增加容错点击，UI 太细时点击外围也算是触发此消息
            if (model.isUsing) {
                self.gotoEdit?(model.model.name)
            } else {
                self.vm.setCurrentWatch(model)
            }
        }.disposed(by: disposeBag)
        
        editBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.gotoMore?()
        }.disposed(by: disposeBag)
        
        vm.updateNewRow.subscribe() { [weak self] index in
            guard let self = self else {return}
            if vm.itemsArray.value.count > 0 {
                self.subCollectView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }.disposed(by: disposeBag)
        vm.updateOldRow.subscribe() { [weak self] index in
            guard let self = self else {return}
            if vm.itemsArray.value.count > 0 {
                self.subCollectView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }.disposed(by: disposeBag)
    }
    
    override func initData() {
        super.initData()
        LanguageCls.share().add(self)
    }
    
    func languageChange() {
        titleLab.text = LanguageCls.localizableTxt("表盘")
        editBtn.setTitle(LanguageCls.localizableTxt("全部"), for: .normal)
    }

}
