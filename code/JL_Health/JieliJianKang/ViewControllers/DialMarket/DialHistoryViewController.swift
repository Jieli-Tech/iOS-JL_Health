//
//  DialHistoryViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/20.
//

import UIKit

class DialHistoryViewController: BaseViewController {
    private var subCollectView:UICollectionView!
    private var noneImgv = UIImageView()
    private var noneLab = UILabel()
    private let vm = DialHistoryViewModel()
    
    override func initUI() {
        super.initUI()
        navigationView.title = LanguageCls.localizableTxt("购买记录")
        self.view.backgroundColor = .white
        
        view.addSubview(noneImgv)
        view.addSubview(noneLab)
        
        noneImgv.image = UIImage(named: "record_img_defaultpage")
        noneImgv.contentMode = .scaleAspectFit
        noneImgv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(208)
            make.height.equalTo(178)
        }
        noneLab.text = LanguageCls.localizableTxt("暂无记录")
        noneLab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        noneLab.textColor = .eHex("#919191")
        noneLab.textAlignment = .center
        noneLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(noneImgv.snp.bottom).offset(20)
        }
        
        noneImgv.isHidden = true
        noneLab.isHidden = true
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 10
        let width = UIScreen.main.bounds.size.width / 3 - 22
        flowLayout.itemSize = CGSize(width: width, height: 160)
        subCollectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.view.addSubview(subCollectView)
        subCollectView.backgroundColor = .clear
        subCollectView.showsHorizontalScrollIndicator = false
        subCollectView.register(DialSubCollectionViewCell.self, forCellWithReuseIdentifier: "DialFreeCollectionViewCell")
        subCollectView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        vm.allItemsArray.bind(to: subCollectView.rx.items(cellIdentifier: "DialFreeCollectionViewCell", cellType: DialSubCollectionViewCell.self)) { index, model, cell in
            cell.configPayHistoryCell(model)
        }.disposed(by: disposeBag)
        
        subCollectView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else {return}
                let model = self.vm.allItemsArray.value[index.row]
                self.vm.setCurrentDial(model)
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
        vm.allItemsArray.subscribe() { [weak self] list in
            guard let self = self else {return}
            if list.element?.count == 0 {
                self.noneLab.isHidden = false
                self.noneImgv.isHidden = false
                if (self.subCollectView != nil) {
                    self.subCollectView.isHidden = true
                }
            } else {
                self.noneLab.isHidden = true
                self.noneImgv.isHidden = true
                if (self.subCollectView != nil) {
                    self.subCollectView.isHidden = false
                }
            }
        }.disposed(by: disposeBag)
        
    }

}
