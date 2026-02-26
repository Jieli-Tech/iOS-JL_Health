//
//  CreateVoicesVC.swift
//  WatchTest
//
//  Created by EzioChan on 2024/1/24.
//

import UIKit
import JLWtsToCfgLib
import JL_BLEKit
import DFUnits
import JLUsefulTools

class CreateVoicesViewController: BaseViewController{
    let getInfoBtn = UIButton()
    let infoLab = UILabel()
    let subTable = UITableView()
    let makePcmBtn = UIButton()
    let pcm2wtsBtn = UIButton()
    let drawView = PlotView(frame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 90))
    let makePackageBtn = UIButton()
    let makeBundlePcmPkgBtn = UIButton()
    let tipsView = CreateVoiceView()
    
    
    private var isRecording = false
    private var recPcmData = Data()
    private let voiceReplace = JLVoicePackageManager.share()
    private var voiceInfo:JLVoiceReplaceInfo?
    private let items = BehaviorRelay<[JLTipsVoiceInfo]>(value: [])
    private var finishIndex = 0
    private let audioHelper = DFAudio()
    private var audioPlayer:AVAudioPlayer?
    private let audioFm = DFAudioFormat()
    private var tipsVoiceInfos:[TipsVoiceModel] = []
    var ecTask = EasyStack<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var testItems:[JLTipsVoiceInfo] = []
        for i in 0..<1{
            let v = JLTipsVoiceInfo()
            v.fileName =  String(i)+".wts"
            v.index = UInt8(i)
            v.length = 65535
            v.nickName = "Nick name"+String(i)
            v.offset = 0x00
            testItems.append(v)
        }
        items.accept(testItems)
    }
    override func initUI() {
        super.initUI()
        navigationView.title = "Prompt tone packaging"
        navigationView.leftBtn.setTitle("Back", for: .normal)
        view.addSubview(getInfoBtn)
        view.addSubview(infoLab)
        view.addSubview(subTable)
        view.addSubview(drawView)
        view.addSubview(makePcmBtn)
        view.addSubview(pcm2wtsBtn)
        view.addSubview(makePackageBtn)
        view.addSubview(makeBundlePcmPkgBtn)
        view.addSubview(tipsView)
        
        getInfoBtn.setTitle("Get device prompt info", for: .normal)
        getInfoBtn.setTitleColor(.white, for: .normal)
        getInfoBtn.backgroundColor = UIColor.random()
        getInfoBtn.layer.cornerRadius = 10
        getInfoBtn.layer.masksToBounds = true
        getInfoBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        infoLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        infoLab.adjustsFontSizeToFitWidth = true
        infoLab.textColor = .darkText
        infoLab.numberOfLines = 0
        
        drawView.backgroundColor = UIColor.white
        
        makePcmBtn.setTitle("Record PCM ", for: .normal)
        makePcmBtn.setTitleColor(.white, for: .normal)
        makePcmBtn.backgroundColor = UIColor.random()
        makePcmBtn.layer.cornerRadius = 10
        makePcmBtn.layer.masksToBounds = true
        
        pcm2wtsBtn.setTitle("PCM 2 WTS", for: .normal)
        pcm2wtsBtn.setTitleColor(.white, for: .normal)
        pcm2wtsBtn.backgroundColor = UIColor.random()
        pcm2wtsBtn.layer.cornerRadius = 10
        pcm2wtsBtn.layer.masksToBounds = true
        
        makePackageBtn.setTitle("By Record Custom Voices", for: .normal)
        makePackageBtn.setTitleColor(.white, for: .normal)
        makePackageBtn.backgroundColor = UIColor.random()
        makePackageBtn.layer.cornerRadius = 10
        makePackageBtn.layer.masksToBounds = true
        
        makeBundlePcmPkgBtn.setTitle("By Sandbox Voices", for: .normal)
        makeBundlePcmPkgBtn.setTitleColor(.white, for: .normal)
        makeBundlePcmPkgBtn.backgroundColor = UIColor.random()
        makeBundlePcmPkgBtn.layer.cornerRadius = 10
        makeBundlePcmPkgBtn.layer.masksToBounds = true
        
        tipsView.isHidden = true
        
        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 60
        subTable.tableFooterView = UIView()
        subTable.register(VoiceInfoCell.self, forCellReuseIdentifier: "tagCell")
        subTable.separatorStyle = .none
        
        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell",cellType: VoiceInfoCell.self)){ [weak self](index,item,cell) in
            guard let `self` = self else{return}
            cell.makeModel(item)
            if index <= self.finishIndex {
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)
        
        
        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(getInfoBtn.snp.bottom).offset(12)
            make.height.equalTo(200)
        }
        
        infoLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(12)
            make.height.equalTo(60)
        }
        
        getInfoBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(infoLab.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        drawView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(subTable.snp.bottom).offset(12)
            make.height.equalTo(90)
        }
        
        makePcmBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.height.equalTo(35)
            make.right.equalTo(pcm2wtsBtn.snp.left).offset(-12)
            make.width.equalTo(pcm2wtsBtn.snp.width)
            make.top.equalTo(drawView.snp.bottom).offset(12)
        }
        
        pcm2wtsBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.left.equalTo(makePcmBtn.snp.right).offset(12)
            make.width.equalTo(makePcmBtn.snp.width)
            make.top.equalTo(drawView.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        
        tipsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        makePackageBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(pcm2wtsBtn.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        
        makeBundlePcmPkgBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(makePackageBtn.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        
    }
    
    override func initData() {
        super.initData()
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self](_) in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        audioFm.mSampleRate = 16000;
        audioFm.mChannelsPerFrame = 1;
        audioFm.mBitsPerChannel = 16;
        audioFm.mFormatID = kAudioFormatLinearPCM;

        audioHelper.setRecorderFormat(audioFm)
        drawView.fm = audioFm
        let session = AVAudioSession.sharedInstance()
        try?session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        session.requestRecordPermission { [weak self] (granted) in
            guard let `self` = self else{return}
            if !granted{
                self.view.makeToast("Please allow microphone access")
            }
        }
        
        JL_Tools.add(kDFAudio_REC, action: #selector(getPCMData(note:)), own: self)
        
        self.getInfoBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            guard let cmdMgr = BleManager.shared.currentCmdMgr else {return}
            self.voiceReplace.voicesReplaceGetVoiceInfo(cmdMgr, result: { cmdStatus ,info in
                if cmdStatus != .success {
                    self.view.makeToast("Error requesting device information:\(cmdStatus)")
                    return
                }
                self.voiceInfo = info
                guard let info = info else {
                    return;
                }
                self.infoLab.text = "Number of files:" + String(info.maxNum) + "\nfile name:" + info.fileName + "\nReserved area size:" + String(info.blockSize)
                self.items.accept(info.infoArray)
                
            })
        }.disposed(by: disposeBag)
        
        
        self.pcm2wtsBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            
            let model = self.items.value[self.finishIndex]
            let wtsPath = _R.path.tipsVoice + "/" + model.fileName
            try?FileManager.default.removeItem(atPath: wtsPath)
            self.tipsView.isHidden = false
            JLPcmToWts.share().pcm(toWts: _R.path.library+"/temp.pcm", bitOutFileName: wtsPath, targetRate: 20000, sr_in: 16000, vadthr: 0, usesavemodef: 0) { status, data ,path in
                if status{
                    ECPrintDebug("pcm2wts success", self, "\(#function)", #line)
                    self.view.makeToast("pcm2wts success")
                    self.finishIndex+=1
                    let md = TipsVoiceModel(name:model.nickName , file: model.fileName, path: wtsPath, type: false)
                    self.tipsVoiceInfos.append(md)
                    self.subTable.reloadData()
                    self.tipsView.isHidden = true
                }
            }
        }.disposed(by:disposeBag)
        
        makePcmBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            if self.isRecording{
                self.audioHelper.didRecorderStop()
                self.makePcmBtn.setTitle("start", for: .normal)
                self.drawView.points = self.recPcmData
                let tmpPath = _R.path.library+"/temp.pcm"
                try?FileManager.default.removeItem(atPath: tmpPath)
                FileManager.default.createFile(atPath: tmpPath, contents: self.recPcmData)
                self.playAudioData()
            }else{
                self.recPcmData = Data()
                DDOpenALAudioPlayer.sharePalyer().stopSound()
                self.audioHelper.didRecorderStart()
                self.makePcmBtn.setTitle("stop", for: .normal)
            }
            self.isRecording.toggle()
        }.disposed(by: disposeBag)
        
        makePackageBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
//            if self.finishIndex == items.value.count-1{
            if let info = self.voiceInfo{
                let vc = PackageResViewController()
                vc.canNotPushBack = true
                vc.info = info
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.view.makeToast("Please obtain the device prompt information first",position: .center)
            }
//            }else{
//                self.view.makeToast("请先生成所有文件",position: .center)
//            }
        }.disposed(by: disposeBag)
        
        makeBundlePcmPkgBtn.rx.tap.subscribe { [weak self](_) in
            guard let `self` = self else{return}
            guard let pcms = _R.path.pcmPath.listFile(),pcms.count>0 else {
                self.view.makeToast("Please import the pcm file into the Document/pcmData folder first",position: .center)
                return
            }
            
            tipsView.isHidden = false
            for item in pcms{
                self.ecTask.push(item)
            }
            self.changeToWts()
        }.disposed(by: disposeBag)
    }
    
    private func changeToWts(){
        if let str = ecTask.pop(){
            let name = (str as NSString).lastPathComponent.replacingOccurrences(of: ".pcm", with: ".wts")
            let wtsPath = _R.path.tipsVoice + "/" + name
            try?FileManager.default.removeItem(atPath: wtsPath)
            JLPcmToWts.share().pcm(toWts: str, bitOutFileName: wtsPath, targetRate: 20000, sr_in: 16000, vadthr: 0, usesavemodef: 0) { [weak self](status, dt, fileName) in
                self?.changeToWts()
            }
        }else{
            tipsView.isHidden = true
            if let info = voiceInfo{
                let vc = PackageResViewController()
                vc.info = info
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.view.makeToast("Please obtain the device prompt information first",position: .center)
            }
        }
    }

    @objc func getPCMData(note:Notification){
        let dt = note.object as! Data
        self.recPcmData.append(dt)
    }
    
    func playAudioData(){
        let dt = Data(self.recPcmData)
        DDOpenALAudioPlayer.sharePalyer().openAudio(fromQueue: dt, samplerate: Int32(audioFm.mSampleRate), channels: Int32(audioFm.mChannelsPerFrame), bit: Int32(audioFm.mBitsPerChannel))
    }
    
    


}

fileprivate extension Data{
    mutating func add(_ num:UInt16){
        let byte1:UInt8 = UInt8(num >> 8)
        let byte2:UInt8 = UInt8(num & 0xff)
        let dt = Data([byte1,byte2])
        self.append(dt)
    }
    mutating func add(_ num:UInt32){
        let byte1:UInt16 = UInt16(num >> 16)
        let byte2:uint16 = UInt16(num & 0xFFFF)
        self.add(byte1)
        self.add(byte2)
    }
}

fileprivate class VoiceInfoCell:UITableViewCell{
    let mainLab = UILabel()
    let subLab = UILabel()

    private var model:JLTipsVoiceInfo?
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainLab)
        contentView.addSubview(subLab)
        
        mainLab.font = UIFont.systemFont(ofSize: 14)
        mainLab.textColor = UIColor.darkText
        subLab.font = UIFont.systemFont(ofSize: 12)
        subLab.textColor = UIColor.darkText

        mainLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(20)
            make.left.equalToSuperview().inset(8)
        }
        
        subLab.snp.makeConstraints { make in
            make.top.equalTo(mainLab.snp.bottom)
            make.height.equalTo(20)
            make.left.equalToSuperview().inset(8)
        }
        
    }
    
    func makeModel(_ md:JLTipsVoiceInfo){
        self.mainLab.text = "FileName:"+md.fileName
        self.subLab.text = "NickName:" + md.nickName + " index：" + String(md.index)+" size:" + String(md.length)
        self.model = md
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





