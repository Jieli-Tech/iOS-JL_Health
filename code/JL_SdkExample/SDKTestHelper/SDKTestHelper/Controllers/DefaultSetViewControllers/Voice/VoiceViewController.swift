//
//  VoiceVC.swift
//  WatchTest
//
//  Created by 杰理科技 on 2023/11/10.
//

import UIKit

class VoiceViewController: BaseViewController,JL_SpeexManagerDelegate {
    @IBOutlet weak var lbTip: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    
    var mManager :JL_ManagerM?
    var speexManager: JL_SpeexManager?  //用于【设备传输语音数据】
    var myAudio: DFAudio?               //用于【播放设备解码后的PCM数据】
    var myFormat: DFAudioFormat?        //用于【音频参数】
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*--- 实例音频传输 ---*/
        mManager     = BleManager.shared.currentCmdMgr
        speexManager = BleManager.shared.currentCmdMgr?.mSpeexManager
        speexManager?.delegate = self
        
        /*--- 建立OPUS解码器 ---*/
        myFormat = DFAudioFormat()
        myFormat!.mFormatID = kAudioFormatLinearPCM;
        myFormat!.mBitsPerChannel = 16
        myFormat!.mChannelsPerFrame = 1
        myFormat!.mSampleRate = 16000
        
        myAudio = DFAudio()
        myAudio!.setPlayerBufferSize(10*1024*1024, format: myFormat!)
        myAudio!.didPlayerStart()

        DispatchQueue.global().async {
            OpusUnit.opusIsLog(true)
            OpusUnit.opusSetSampleRate(16000, kbps: 16000, channels: 1)
            OpusUnit.opusDecoderRun()
        }
        JL_Tools.add(kOPUS_DECODE_DATA, action: #selector(notePcmData(_:)), own: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        actionStop(0)
        myAudio?.didPlayerRelease()
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.voiceTransmissionDecoding()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        recordBtn.layer.cornerRadius = 8.0
    }
    
    override func initData() {
        super.initData()
        self.navigationView.leftBtn.rx.tap.subscribe { [weak self]_ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func actionRecord(_ sender: Any) {
        print("--->Start record")
        
        let speech = JLSpeechRecognition()
        speech.sendText    = false
        speech.sendAIText  = false
        speech.needPlayTTS = false
        
        let params = JLRecordParams()
        params.mDataType      = .OPUS
        params.mVadWay        = .normal
        params.mSampleRate    = .rate16K
        params.speechRecognit = speech
        
        /*--- APP发起录音 ---*/
        speexManager?.cmdStartRecord(mManager!, params: params)
    }
    
    @IBAction func actionStop(_ sender: Any) {
        let st = speexManager?.cmdCheckRecordStatus()
        if st == .doing{
            print("--->Stop record")
            speexManager?.cmdStopRecord(mManager!, reason: .normal)
        }
    }

    
    // MARK: - JL_SpeexManager Delegate
    func speexManagerStatus(_ status: JL_SpeakType, by originator: JLCMDOriginator, with params: JLRecordParams?) {
                
        if status == .do {
            if originator == .app {
                self.view.makeToast("APP start speech")
                lbTip.text = "APP start speech"
                recordBtn.setTitle("Release to stop", for: .normal)
            }
            if originator == .device {
                self.view.makeToast("Device start speech")
                lbTip.text = "Device start speech"
                recordBtn.setTitle("stop", for: .normal)

                /*--- 允许设备传输语音数据 ---*/
                speexManager?.cmdAllowSpeak()
                
            }
        }else if status == .doing{
            lbTip.text = "voice transmission..."
        }else if status == .done{
            lbTip.text = "Please press and hold the Record button on your device or APP."
            recordBtn.setTitle("Record", for: .normal)

        }else{
            lbTip.text = "Please press and hold the recording button on your device or APP."
            recordBtn.setTitle("Record", for: .normal)
            self.view.makeToast("speech errors")
        }
    }
    
    // MARK: - 将Opus传入解码器
    func speexManagerAudio(_ data: Data) {
        DispatchQueue.main.async {
            OpusUnit.opusWrite(data)
        }
    }
    
    
    // MARK: - 解码后的PCM
    @objc func notePcmData(_ note:NSNotification){
        let data = note.object as! Data
        print("--->pcm buffer : \(data.count)")
        myAudio?.didPlayerInputBuffer(data)
    }
    
}

