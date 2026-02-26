//
//  DialViewController.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/22.
//

import UIKit

class DialViewController: BaseViewController {
    private var subCollectView:UICollectionView!
    private let editBtn = UIButton()
    private let vm = DialVcViewModel()
    private var isEdit = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JL_Tools.add(kJL_BLE_M_ENTITY_DISCONNECTED, action: #selector(disconnectAction), own: self)
    }
    
    @objc func disconnectAction(){
        JL_Tools.remove(kJL_BLE_M_ENTITY_DISCONNECTED, own: self)
        BridgeHelper.getNavigationController().popToRootViewController(animated: true)
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = LanguageCls.localizableTxt("表盘")
        self.view.backgroundColor = .white
        
        view.addSubview(editBtn)
        editBtn.setTitle(LanguageCls.localizableTxt("管理"), for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        editBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        editBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.width.equalTo(50)
            make.top.equalTo(navigationView.snp.bottom)
        }
        
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
        subCollectView.register(DialSubCollectionViewCell.self, forCellWithReuseIdentifier: "DialSubCollectionViewCell")
        subCollectView.snp.makeConstraints { make in
            make.top.equalTo(editBtn.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        
        vm.allItemsArray.bind(to: subCollectView.rx.items(cellIdentifier: "DialSubCollectionViewCell", cellType: DialSubCollectionViewCell.self)) { [weak self] index, model, cell in
            guard let `self` = self else {return}
            cell.configVcPageModel(model,self.isEdit)
            
            cell.callBackEdit = { model in
                guard let model = model as? DialPageModel else {
                    return
                }
                self.gotoEdit(model.name)
            }
            cell.callBackStatus = { model in
                guard let model = model as? DialPageModel else {
                    return
                }
                self.vm.setCurrentWatch(model)
            }
            cell.callBackDelete = { model in
                guard let model = model as? DialPageModel else {
                    return
                }
                self.deleteAction(model)
            }
        }.disposed(by: disposeBag)
        
        subCollectView.rx.itemSelected.subscribe { [weak self] indexPath in
            guard let self = self else {return}
            self.subCollectView.deselectItem(at: indexPath, animated: true)
           JLLogManager.logLevel(.DEBUG, content: "subCell selected: \(indexPath)")
            let model:DialPageModel = self.vm.allItemsArray.value[indexPath.row]
            //增加容错点击，UI 太细时点击外围也算是触发此消息
            if self.isEdit {
                self.deleteAction(model)
                return
            }
            if (model.name.uppercased() == BridgeHelper.dialCache().currentWatchName()) {
                self.gotoEdit(model.name)
            } else {
                self.vm.setCurrentWatch(model)
            }

        }.disposed(by: disposeBag)
        
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
        editBtn.rx.tap.subscribe(){ [weak self]_ in
            guard let self = self else {return}
            if self.isEdit {
                self.isEdit = false
                self.editBtn.setTitle(LanguageCls.localizableTxt("管理"), for: .normal)
            } else {
                self.isEdit = true
                self.editBtn.setTitle(LanguageCls.localizableTxt("完成"), for: .normal)
            }
            self.isEditing = self.isEdit
            self.subCollectView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    private func deleteAction(_ model:DialPageModel){
        AlertViewOnWindows.showDialDelete()
        DialBaseViewModel.shared.deleteWatch(model.name) {
            self.isEdit = false
            self.editBtn.setTitle(self.isEdit ? LanguageCls.localizableTxt("完成") : LanguageCls.localizableTxt("管理"), for: .normal)
            self.subCollectView.reloadData()
            AlertViewOnWindows.removeDialDelete()
        }
    }
    
    private func gotoEdit(_ name:String){
        let vc = CustomWatchVC()
        vc.watchName = name.uppercased()
        BridgeHelper.getNavigationController().pushViewController(vc, animated: true)
    }

}
