//
//  DialMallViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/22.
//

import UIKit

class DialMallViewController: BaseViewController {
    private var subCollectView:UICollectionView!
    var vm:DialPayViewModel!
    
    override func initUI() {
        super.initUI()
        navigationView.title = LanguageCls.localizableTxt("付费表盘")
        self.view.backgroundColor = .white
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 10
        let width = UIScreen.main.bounds.size.width / 3 - 22
        flowLayout.itemSize = CGSize(width: width, height: 160)
        subCollectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.view.addSubview(subCollectView)
        subCollectView.backgroundColor = .clear
        subCollectView.showsVerticalScrollIndicator = false
        subCollectView.register(DialSubCollectionViewCell.self, forCellWithReuseIdentifier: "DialPayCollectionViewCell")
        subCollectView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        vm.allItemsArray.bind(to: subCollectView.rx.items(cellIdentifier: "DialPayCollectionViewCell", cellType: DialSubCollectionViewCell.self)) { [weak self] index, model, cell in
            guard let `self` = self else {return}
            cell.configPayCell(model)
            cell.callBackStatus = { model in
                guard let model = model as? DialMallModel else {
                    return
                }
                self.setCurrentWatch(model)
            }
        }.disposed(by: disposeBag)
        
        subCollectView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else {return}
                let model = self.vm.allItemsArray.value[index.row]
                 self.setCurrentWatch(model)
            }).disposed(by: disposeBag)
        
        let footHeader = MJRefreshAutoNormalFooter { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.subCollectView.mj_footer?.beginRefreshing()
            }
            vm.loadNextPage(){
                DispatchQueue.main.async {
                    self.subCollectView.mj_footer?.endRefreshing()
                }
            }
        }
        subCollectView.mj_footer = footHeader
        subCollectView.mj_footer?.isHidden = true
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe(){ [weak self]_ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
    }
    
    private func setCurrentWatch(_ model:DialMallModel){
        let list = BridgeHelper.dialCache().getWatchList() as? [String] ?? []
        if model.status == false && !list.contains(model.name.uppercased()){
            let vc = DialPayViewController()
            vc.dialModel = model
            BridgeHelper.getNavigationController().pushViewController(vc, animated: true)
            return
        }
        vm.setCurrentModel(model)
    }
    
}
