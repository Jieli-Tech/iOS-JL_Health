//
//  FindPhoneView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/23.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FindPhoneView.h"
#import "JL_RunSDK.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface FindPhoneView()<LanguagePtl>{
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIButton *closeBtn;
    __weak IBOutlet UILabel *titleLab;
    NSTimer *voiceTimer;
}
@end

@implementation FindPhoneView

- (instancetype)init
{
    self = [DFUITools loadNib:@"FindPhoneView"];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        centerView.layer.cornerRadius = 10;
        centerView.layer.masksToBounds = YES;
        [JL_Tools add:AVAudioSessionInterruptionNotification Action:@selector(noteInterruption:) Own:self];
        [JL_Tools add:kJL_MANAGER_FIND_PHONE Action:@selector(recivedVoiceNote:) Own:self];
        [self languageChange];
        [[LanguageCls share] add:self];
    }
    return self;
}
-(void)setTitleStr:(NSString *)titleStr{
    titleLab.text = titleStr;
    _titleStr = titleStr;
}

- (IBAction)closeBtnAction:(id)sender {
    self.hidden = YES;
    JL_FindDeviceManager *findDeviceManager = kJL_BLE_CmdManager.mFindDeviceManager;
    [findDeviceManager cmdFindDevice:NO timeOut:10 findIphone:YES Operation:nil];
    [self removeFromSuperview];
    [voiceTimer invalidate];
    voiceTimer = nil;
}


-(void)startVoice{
    [voiceTimer invalidate];
    voiceTimer = nil;
    voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(beginVoice) userInfo:nil repeats:YES];
    [voiceTimer fire];
}



-(void)beginVoice{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSoundWithCompletion(1304, nil);
}


-(void)noteInterruption:(NSNotification*)note{
    self.hidden = YES;
    [self removeFromSuperview];
    [voiceTimer invalidate];
    voiceTimer = nil;
}

-(void)recivedVoiceNote:(NSNotification*)note{
    NSDictionary *dict = [note object];
    NSDictionary *dict1 = dict[kJL_MANAGER_KEY_OBJECT];
     if ([dict1[@"op"] intValue] != 1) {
        self.hidden = YES;
        [self removeFromSuperview];
        [voiceTimer invalidate];
        voiceTimer = nil;
    }
}

-(void)languageChange{
    [self setTitleStr:kJL_TXT("设备查找手机中...")];
    [closeBtn setTitle:kJL_TXT("关闭声音") forState:UIControlStateNormal];
}

@end
