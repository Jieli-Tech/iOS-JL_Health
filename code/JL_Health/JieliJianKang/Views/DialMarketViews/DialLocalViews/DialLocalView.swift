//
//  DialLocalView.swift
//  JieliJianKang
//
//  Created by EzioChan on 2024/9/18.
//

import UIKit

class DialLocalView: BaseView {
    
    let titleLab = UILabel()
    let editBtn = UIButton()
    var subCollectView:UICollectionView!
    var vm = DialSubViewModel.shared
    var gotoMore:(()->Void)?
    private var isEdit:Bool = false
    var superVC:UIViewController?
 
    override func initUI() {
        super.initUI()
        self.backgroundColor = .white
        self.addSubview(titleLab)
        self.addSubview(editBtn)
        
        
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLab.text = LanguageCls.localizableTxt("本地表盘")
        titleLab.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        
        editBtn.setTitle(LanguageCls.localizableTxt("管理"), for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        editBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        editBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.height.equalTo(30)
            make.right.equalToSuperview().inset(8)
        }
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        let width = UIScreen.main.bounds.size.width / 3 - 22
        flowLayout.itemSize = CGSize(width: width, height: 160)
        subCollectView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        self.addSubview(subCollectView)
        subCollectView.backgroundColor = .white
        subCollectView.showsHorizontalScrollIndicator = false
        subCollectView.showsVerticalScrollIndicator = false
        subCollectView.register(DialSubCollectionViewCell.self, forCellWithReuseIdentifier: "DialSubCollectionViewCell")
        subCollectView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        vm.itemsArray.bind(to: subCollectView.rx.items(cellIdentifier: "DialSubCollectionViewCell", cellType: DialSubCollectionViewCell.self)) { [weak self] (index, model, cell) in
            guard let `self` = self else {return}
            
            cell.configCell(self.vm,model,self.isEdit)
            
            cell.callBackEdit = {  model in
                guard let model = model as? DialSubModel else {
                    return
                }
                self.gotoEdit(model.model.name)
            }
            cell.callBackStatus = {  model in
                guard let model = model as? DialSubModel else {
                    return
                }
                self.vm.setCurrentWatch(model)
            }
            cell.callBackDelete = {model in
                guard let model = model as? DialSubModel else {
                    return
                }
                self.deleteAction(model)
            }
        }.disposed(by: disposeBag)
        
        subCollectView.rx.itemSelected.subscribe { [weak self] indexPath in
            guard let self = self else {return}
            self.subCollectView.deselectItem(at: indexPath, animated: true)
           JLLogManager.logLevel(.DEBUG, content: "subCell selected: \(indexPath)")
            let model:DialSubModel = self.vm.itemsArray.value[indexPath.row]
            //增加容错点击，UI 太细时点击外围也算是触发此消息
            if self.isEdit {
//                self.deleteAction(model)
                return
            }
            if (model.isUsing) {
                self.gotoEdit(model.model.name)
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
            if vm.itemsArray.value.count > 0  {
                self.subCollectView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }.disposed(by: disposeBag)
        vm.updateOldRow.subscribe() { [weak self] index in
            guard let self = self else {return}
            if vm.itemsArray.value.count > 0  {
                self.subCollectView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()
        editBtn.rx.tap.subscribe() { [weak self] _ in
            guard let self = self else {return}
            self.isEdit = !self.isEdit
            self.editBtn.setTitle(self.isEdit ? LanguageCls.localizableTxt("完成") : LanguageCls.localizableTxt("管理"), for: .normal)
            self.subCollectView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    private func deleteAction(_ model:DialSubModel){
        AlertViewOnWindows.showDialDelete()
        DialBaseViewModel.shared.deleteWatch(model.model.name) { [weak self] in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
                self.isEdit = false
                self.editBtn.setTitle(self.isEdit ? LanguageCls.localizableTxt("完成") : LanguageCls.localizableTxt("管理"), for: .normal)
                self.subCollectView.reloadData()
                AlertViewOnWindows.removeDialDelete()
                BridgeHelper.getCurrentCmdManager()?.mFlashManager.cmdWatchFlashPath(nil, flag: .readCurrentDial, result: { flag, size, path, des in
                    if flag == 0 {
                        JLLogManager.logLevel(.DEBUG, content: "dial path: \(path ?? "")")
                        if let currentWatch = path?.replacingOccurrences(of: "/", with: "") {
                            BridgeHelper.dialCache().setCurrrentWatchName(currentWatch.uppercased())
                        }
                        self.vm.requireDialsInfo()
                    }
                })
            }
        }
    }
    
    private func gotoEdit(_ name:String){
        let vc = CustomWatchVC()
        vc.watchName = name.uppercased()
        BridgeHelper.getNavigationController().pushViewController(vc, animated: true)
    }

}
