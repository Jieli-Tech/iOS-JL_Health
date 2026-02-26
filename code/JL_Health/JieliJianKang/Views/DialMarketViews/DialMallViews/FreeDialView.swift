//
//  FreeDialView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/13.
//

import UIKit

class FreeDialView: BaseView {
    let titleLab = UILabel()
    let editBtn = UIButton()
    let moreImgv = UIImageView()
    var subCollectView:UICollectionView!
    let vm = DialFreeViewModel()
    var gotoMore:(()->Void)?
    
    override func initUI() {
        super.initUI()
        self.backgroundColor = .white
        self.addSubview(titleLab)
        self.addSubview(editBtn)
        self.addSubview(moreImgv)
        
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLab.text = LanguageCls.localizableTxt("免费表盘")
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(6)
            make.height.equalTo(30)
        }
        
        editBtn.setTitle(LanguageCls.localizableTxt("更多"), for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        editBtn.setTitleColor(.eHex("#919191"), for: .normal)
        editBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab)
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
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 10
        let width = UIScreen.main.bounds.size.width / 3 - 22
        flowLayout.itemSize = CGSize(width: width, height: 170)
        subCollectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.addSubview(subCollectView)
        subCollectView.isScrollEnabled = false
        subCollectView.backgroundColor = .white
        subCollectView.showsHorizontalScrollIndicator = false
        subCollectView.register(DialSubCollectionViewCell.self, forCellWithReuseIdentifier: "DialFreeCollectionViewCell")
        subCollectView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        vm.itemsArray.bind(to: subCollectView.rx.items(cellIdentifier: "DialFreeCollectionViewCell", cellType: DialSubCollectionViewCell.self)) { [weak self] index, model, cell in
            guard let `self` = self else {return}
            cell.configFreeCell(model)
            cell.callBackStatus = { model in
                guard let model = model as? DialFreeModel else {
                    return
                }
                self.changeCurrentDial(model)
            }
        }.disposed(by: disposeBag)
        
        subCollectView.rx.itemSelected.subscribe { [weak self] indexPath in
            guard let self = self else {return}
            self.subCollectView.deselectItem(at: indexPath, animated: true)
           JLLogManager.logLevel(.DEBUG, content: "subCell selected: \(indexPath)")
            let model = self.vm.itemsArray.value[indexPath.row]
            self.changeCurrentDial(model)
        }.disposed(by: disposeBag)
        
        editBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.gotoMore?()
        }.disposed(by: disposeBag)
        
    }
    
    override func initData() {
        super.initData()
        vm.itemsArray.subscribe { [weak self] list in
            guard let self = self else {return}
            let count = list.element?.count ?? 0
            if count > 6 {
                moreImgv.isHidden = false
                editBtn.isHidden = false
            } else {
                moreImgv.isHidden = true
                editBtn.isHidden = true
            }
        }.disposed(by: disposeBag)
    }
    
    private func changeCurrentDial(_ model:DialFreeModel) {
        let dialList = BridgeHelper.dialCache().getWatchList()
        if model.model.status == false && !dialList.contains(model.model.name.uppercased()) {
            let vc = DialPayViewController()
            vc.dialModel = model.model
            BridgeHelper.getNavigationController().pushViewController(vc, animated: true)
            return
        }
        self.vm.setCurrentWatch(model)
    }
    

}
