//
//  FilesBrowseVC.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/10.
//

import UIKit

class FilesBrowseViewController: BaseViewController {
    
    let progressView = UIProgressView()
    let progressLab = UILabel()
    
    var titleColoct:UICollectionView!
    let titleItemsArray = BehaviorRelay<[JLModel_File]>(value: [])
    var subItemsTable = UITableView()
    let subItemsArray = BehaviorRelay<[JLModel_File]>(value: [])
    let filesItem = UIButton()
    let fileLoadView = FileLoadView()
    
    private var readSavePath = ""
    private var isTransporting = false
    
    
    private var nowModel:JLModel_File?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "File Browse"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        
        view.addSubview(progressView)
        view.addSubview(progressLab)
        
        progressView.progress = 0
        progressView.trackTintColor = UIColor.random()
        progressView.progressTintColor = UIColor.random()
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        
        progressLab.text = "0%"
        progressLab.textColor = UIColor.random()
        progressLab.font = UIFont.boldSystemFont(ofSize: 30)
        progressLab.textAlignment = .center
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(progressLab.snp.left)
            make.height.equalTo(4)
        }
        
        progressLab.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(progressView.snp.centerY)
        }
        
        let flayout = UICollectionViewFlowLayout()
        flayout.itemSize = CGSize(width: 120, height: 30)
        flayout.minimumLineSpacing = 0
        flayout.minimumInteritemSpacing = 0
        flayout.scrollDirection = .horizontal
        
        titleColoct = UICollectionView(frame: CGRectZero, collectionViewLayout: flayout)
        titleColoct.backgroundColor = .clear
        titleColoct.showsHorizontalScrollIndicator = false
        titleColoct.register(FilesBrowseCell.self, forCellWithReuseIdentifier: "FilesBrowseCell")
        view.addSubview(titleColoct)
        titleColoct.rx.setDelegate(self).disposed(by: disposeBag)
        
        
        subItemsTable.register(FileModelCell.self, forCellReuseIdentifier: "FileModelCell")
        subItemsTable.backgroundColor = .clear
        subItemsTable.separatorStyle = .none
        subItemsTable.tableFooterView = UIView()
        subItemsTable.rowHeight = 50
        subItemsTable.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        view.addSubview(subItemsTable)
        
        filesItem.setTitle("Browse downloaded", for: .normal)
        filesItem.setTitleColor(UIColor.white, for: .normal)
        filesItem.backgroundColor = UIColor.random()
        filesItem.layer.cornerRadius = 8
        filesItem.layer.masksToBounds = true
        
        view.addSubview(filesItem)
        view.addSubview(fileLoadView)
        
        titleColoct.snp.makeConstraints { make in
            make.top.equalTo(progressLab.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
        
        subItemsTable.snp.makeConstraints { make in
            make.top.equalTo(titleColoct.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(filesItem.snp.top).offset(-10)
        }
        
        filesItem.snp.makeConstraints { make in
            make.top.equalTo(subItemsTable.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        titleItemsArray.bind(to: titleColoct.rx
            .items(cellIdentifier: "FilesBrowseCell",
                   cellType: FilesBrowseCell.self)) { index, model, cell in
            cell.mainLabel.text = model.fileName
            cell.backgroundColor = UIColor.random()
            cell.mainLabel.textColor = UIColor.white
        }.disposed(by: disposeBag)
        
        
        subItemsArray.bind(to: subItemsTable.rx
            .items(cellIdentifier: "FileModelCell",
                   cellType: FileModelCell.self)) { index, model, cell in
            cell.textLabel1.text = model.fileName
            cell.centerView.backgroundColor = UIColor.random()
            if model.fileType == .folder{
                cell.imgv.image = UIImage(named: "fold")
            }else{
                cell.imgv.image = UIImage(named: "file")
            }
        }.disposed(by: disposeBag)
        
        fileLoadView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        fileLoadView.isHidden = true
        
        handleItemSelect()
        
    }
    
    override func initData() {
        super.initData()
        
        
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.isTransporting{
                let alert = UIAlertController(title: "Tips",
                                              message: "File transfer in progress, do you want to cancel?",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel",
                                              style: .cancel))
                alert.addAction(UIAlertAction(title: "Confirm",
                                              style: .default,
                                              handler: { _ in
                    BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContentCancel()
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
        
        filesItem.rx.tap.subscribe(onNext: { [weak self] in
            self?.fileLoadView.showFiles(_R.path.transportFilePath)
            self?.fileLoadView.isHidden = false
        }).disposed(by: disposeBag)
        
        let nowModel = JLModel_File()
        nowModel.fileName = "Root"
        nowModel.fileType = .folder
        nowModel.fileClus = 0
        nowModel.cardType = BleManager.shared.currentCmdMgr?.mFileManager
            .getCurrentFileHandleType().beCardType() ?? .FLASH
        nowModel.fileHandle = (BleManager.shared.currentCmdMgr?.mFileManager.currentDeviceHandleData().eHex)!
        
        BleManager.shared.currentCmdMgr?.mFileManager.cmdCleanCacheType(nowModel.cardType)
        
        titleItemsArray.accept([nowModel])
        
        self.nowModel = nowModel
        
        BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(nowModel, number: 10)
        BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseMonitorResult({ [weak self](items, reason) in
            switch reason {
            case .busy:
                break
            case .commandEnd:
                break
            case .folderEnd:
                self?.view.makeToast("End of browsing",position: .center)
                self?.subItemsTable.mj_footer?.endRefreshing()
            case .playSuccess:
                self?.view.makeToast("play files")
            case .dataFail:
                self?.view.makeToast("Data reading failed")
            case .reading:
                if let arr = items as? [JLModel_File]{
                    DispatchQueue.main.async {
                        self?.subItemsArray.accept(arr)
                    }
                }
            case .unknown:
                break
            @unknown default:
                break
            }
        })
        
        
        
    }
    
    
    func handleItemSelect(){
        titleColoct.rx.modelSelected(JLModel_File.self).subscribe(onNext: { [weak self] model in
            guard let self = self else {
                return
            }
            var newArr:[JLModel_File] = []
            for i  in 0..<self.titleItemsArray.value.count {
                let item = self.titleItemsArray.value[i]
                newArr.append(item)
                if item.fileClus == model.fileClus{
                    break
                }
            }
            self.titleItemsArray.accept(newArr)
            self.nowModel = model
            BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(model, number: 10)
        }).disposed(by: disposeBag)
        
        subItemsTable.rx.modelSelected(JLModel_File.self).subscribe(onNext: { [weak self] model in
            guard let self = self else {
                return
            }
            if model.fileType == .folder{
                var newArr:[JLModel_File] = self.titleItemsArray.value
                newArr.append(model)
                self.titleItemsArray.accept(newArr)
                self.nowModel = model
                BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(model, number: 10)
            }else{
                if self.isTransporting{
                    self.view.makeToast("Transferring files",position: .center)
                    return
                }
                let alert = UIAlertController(title: "Select download method",
                                              message:  "The downloaded files are stored in the [/transportFiles] folder of [documentDirectory]",
                                              preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Folder",
                                              style: .destructive,
                                              handler: { _ in
                    BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContent(withName: model.fileName,result: { st, size, data, progress in
                        self.handleDownloadProgress( st, size, data, progress,model)
                    })
                }))
                alert.addAction(UIAlertAction(title: "File cluster",
                                              style: .destructive,
                                              handler: { _ in
                    BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContent(withFileClus: model.fileClus,result: { st, size, data, progress in
                        self.handleDownloadProgress( st, size, data, progress,model)
                    })
                }))
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
        
    }
    
    
    @objc func loadMoreData(){
        if let nowModel = nowModel{
            BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(nowModel, number: 10)
        }
    }
    
    private func handleDownloadProgress(_ result:JL_FileContentResult ,_ size:UInt32,_ data:Data?,_ progress:Float,_ model:JLModel_File){
        switch result {
        case .reading:
            DispatchQueue.main.async {
                self.progressView.progress = progress
                self.progressLab.text = String(format: "%.1f%%", progress*100)
            }
            self.isTransporting = true
            JL_Tools.write(data ?? Data(), endFile: readSavePath)
        case .end:
            self.view.makeToast("Reading end:\(result)")
            self.isTransporting = false
        case .start:
            self.view.makeToast("Reading start:\(result)")
            readSavePath = _R.path.transportFilePath+"/"+model.fileName
            try?FileManager.default.removeItem(atPath: readSavePath)
            FileManager.default.createFile(atPath: readSavePath, contents: data)
            self.isTransporting = true
        default:
            self.isTransporting = false
            self.view.makeToast("Reading error:\(result)")
        }
    }
    
}

extension FilesBrowseViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item  = titleItemsArray.value[indexPath.row]
        let width = item.fileName.textAutoWidth(height: 30, font: UIFont.systemFont(ofSize: 14))+20
        return CGSize(width: width, height: 30)
    }
}

fileprivate extension String{
    
    func textAutoWidth(height:CGFloat, font:UIFont) ->CGFloat{
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let rect = string.boundingRect(with:CGSize(width:0, height: height), options: [origin,lead], attributes: [NSAttributedString.Key.font:font], context:nil)
        return rect.width
    }
}


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


class FileModelCell:UITableViewCell{
    let textLabel1 = UILabel()
    let imgv = UIImageView()
    let centerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(centerView)
        centerView.addSubview(textLabel1)
        centerView.addSubview(imgv)
        
        centerView.layer.shadowColor = UIColor.black.cgColor
        centerView.layer.shadowRadius = 6
        centerView.layer.shadowOpacity = 0.5
        centerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        centerView.layer.cornerRadius = 10
        centerView.clipsToBounds = true
        
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        textLabel1.font = UIFont.systemFont(ofSize: 14)
        textLabel1.numberOfLines = 0
        textLabel1.textColor = UIColor.white
        
        textLabel1.snp.makeConstraints { make in
            make.left.equalTo(imgv.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-4)
        }
        imgv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(2)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





