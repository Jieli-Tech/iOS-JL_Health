//
//  ActionPlayer.swift
//  JieliJianKang
//
//  Created by EzioChan on 2022/5/12.
//


import Foundation
import AVFoundation
import UIKit


@objcMembers class ActionPlayer:UIView {
    var playItem:AVPlayerItem?
    var mPlayer:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    var current:TimeInterval{
        get{
            CMTimeGetSeconds(mPlayer?.currentTime() ?? CMTime())
        }
    }
    var total:TimeInterval{
        get{
            CMTimeGetSeconds(mPlayer?.currentItem?.duration ?? CMTime())
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func play(_ url:URL,_ frame:CGRect){
        self.frame = frame;
        playItem = AVPlayerItem.init(url: url)
        mPlayer = AVPlayer(playerItem: playItem)
        playerLayer = AVPlayerLayer(player: mPlayer)
        playerLayer?.frame = frame
        playerLayer?.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer!)
        
        mPlayer?.play()
    }
    
    func pause(){
        mPlayer?.pause()
    }
    func continuePlay(status:Bool){
        if status {
            mPlayer?.play()
        }else{
            mPlayer?.seek(to: CMTime(value: 0, timescale: 1000))
            mPlayer?.play()
        }
    }
    
  
    func sliderTo(v:TimeInterval){
        let duration = v * total
        let t = CMTime(value: CMTimeValue(duration), timescale: 1)
        mPlayer?.seek(to: t)
    }
    
    func refreshLayer(){
        playerLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
}



@objcMembers class EcApplication:NSObject{
    class func gotoSystemSetting(){
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
