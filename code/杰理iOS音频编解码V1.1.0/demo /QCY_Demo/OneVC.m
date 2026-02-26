//
//  OneVC.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2020/3/17.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "OneVC.h"
#import <DFUnits/DFUnits.h>
//#import "OpusUnit.h"
#import "PCMFilePlayer.h"
#import <SpeexKit/SpeexKit.h>

@interface OneVC ()
{
    __weak IBOutlet UILabel *timeLabel;
    DFTips          *loadingTip;
    
    DFAudio         *myAudio;
    DFAudioFormat   *myFormat;
    
    NSTimeInterval  interval;
    NSString *pcmFile;

    
}
@property (weak  ,nonatomic) IBOutlet UIView   *subTitleView;
@property (weak  ,nonatomic) IBOutlet UILabel  *subLabel;

@property (assign,nonatomic) float sw;
@property (assign,nonatomic) float sh;
@property (assign,nonatomic) float sGap_h;
@property (assign,nonatomic) float sGap_t;

@property (assign, nonatomic) BOOL isPlayOpus;
@property (assign, nonatomic) BOOL isPlayPCM;
@property (strong, nonatomic) NSFileHandle *fileHandle;
@end

@implementation OneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    myFormat = [DFAudioFormat new];
    myFormat.mSampleRate = 16000;
    myFormat.mBitsPerChannel = 16;
    myFormat.mChannelsPerFrame = 1;
    myFormat.mFormatID = kAudioFormatLinearPCM;
    myAudio = [[DFAudio alloc] init];
    
    [myAudio setPlayerBufferSize:10*1024*1024 Format:myFormat];
    [myAudio didPlayerStart];
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [OpusUnit opusIsLog:YES];//Opus解码库的LOG
//        [OpusUnit opusEecoderRun];//运行Opus编码库
//    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [OpusUnit opusIsLog:YES];//Opus解码库的LOG
        [OpusUnit opusSetSampleRate:16000 Kbps:32000 Channels:1];
        [OpusUnit opusDecoderRun];//运行Opus解码库
    });
    
    // 监听PCM数据回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notePCMData:) name:kOPUS_DECODE_DATA object:nil];
    // 监听Opus数据回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteOpusData:) name:kOPUS_ENCODE_DATA object:nil];
}

#pragma mark - opus解码

/**
 *  Opus文件 转 PCM流 播放
 */
- (IBAction)btn_opus:(id)sender {
    NSString *pf = [DFFile listPath:NSDocumentDirectory MiddlePath:@"AI_TTS" File:@"test.pcm"];
    [DFFile removePath:pf];
    pcmFile = [DFFile createOn:NSDocumentDirectory MiddlePath:@"AI_TTS" File:@"test.pcm"];
    NSLog(@"Create PCM: %@",pcmFile);
    
    if (!self.isPlayOpus) {
        self.isPlayOpus = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self->interval = [NSDate timeIntervalSinceReferenceDate];

            NSString *opusPath = [DFFile find:@"noise.opus"];
            NSData *opusBuffer = [NSData dataWithContentsOfFile:opusPath];
            unsigned long seek = 0;
            while (1) {
                if (!self.isPlayOpus) {
                    break;
                }
                NSData *tmp = [DFTools data:opusBuffer R:seek L:1*1024];
//                NSLog(@"---> opus input data: %lu",(unsigned long)tmp.length);
                if (tmp.length > 0) {
                    /*---- 传入OPUS数据  ----*/
                    [OpusUnit opusWriteData:tmp];
                    //sleep(0.1);
                    seek = seek + tmp.length;
                } else {
                    self.isPlayOpus = NO;
                    break;
                }
            }
        });
    } else {
        self.isPlayOpus = NO;
    }
}

/*--- PCM回调 ---*/
- (void)notePCMData:(NSNotification*)note {
    NSData *data = [note object];
    
    //播放PCM数据
    NSLog(@"--->pcm buffer : %lu",(unsigned long)data.length);
    [myAudio didPlayerInputBuffer:data];
    
    [DFFile writeData:data endFile:pcmFile];
}


/**
 *  Opus文件 转 PCM文件
 */
- (IBAction)opusFileToPCMFile:(id)sender {
    // 创建PCM文件
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dataFilePath = [docsdir stringByAppendingPathComponent:@"pcm"];
    BOOL isDirExist = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:dataFilePath isDirectory:&isDirExist];
    if (!isDirExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [dataFilePath stringByAppendingPathComponent:@"1.pcm"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSLog(@"remove file : %@", filePath);
    }
    NSString *txt = @"";
    [txt writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    // 调用解码方法，输入 Opus文件路径 与 PCM文件路径
    int result = [OpusUnit opusDecodeOPUS:[[NSBundle mainBundle] pathForResource:@"o3o" ofType:@"opus"] PCM:filePath];

    if (result == 0) {
        // 解码成功
        NSLog(@"opusFileToPCMFile OK 了");
    }
}

#pragma mark - opus编码

/**
 *  PCM文件 转 OPUS文件
 */
- (IBAction)pcmFileToOpusFileBtnFunc:(id)sender {
    // 创建Opus文件
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dataFilePath = [docsdir stringByAppendingPathComponent:@"opus"];
    BOOL isDirExist = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:dataFilePath isDirectory:&isDirExist];
    if (!isDirExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [dataFilePath stringByAppendingPathComponent:@"1.opus"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSLog(@"remove file : %@", filePath);
    }
    NSString *txt = @"";
    [txt writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    // 调用编码方法，输入 PCM文件路径 与 Opus文件路径
    int result = [OpusUnit opusEncodePCM:[[NSBundle mainBundle] pathForResource:@"MyAuido" ofType:@"pcm"] OPUS:filePath];

    if (result == 0) {
        // 编码成功
        NSLog(@"pcmFileToOpusBtnFunc OK 了");
    }
}

- (IBAction)pcmStreamToOpusFileBtnFunc:(id)sender {
    if (!self.isPlayPCM) {
        self.isPlayPCM = YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *pcmPath = [DFFile find:@"MyAuido.pcm"];
            NSData *pcmBuffer = [NSData dataWithContentsOfFile:pcmPath];
            unsigned long seek = 0;
            while (1) {
                if (!self.isPlayPCM) {
                    break;
                }
                NSData *tmp = [DFTools data:pcmBuffer R:seek L:1*1024];
//                NSLog(@"---> pcm input data: %lu",(unsigned long)tmp.length);
                if (tmp.length > 0) {
                    /*---- 传入PCM数据  ----*/
                    [OpusUnit pcmWriteData:tmp];
                    sleep(0.1);
                    seek = seek + tmp.length;
                } else {
                    self.isPlayPCM = NO;
                    break;
                }
            }
        });
    } else {
        self.isPlayPCM = NO;
    }
}

- (void)noteOpusData:(NSNotification*)note {
    NSData *data = [note object];
//    NSLog(@"--->opus buffer : %lu",(unsigned long)data.length);

    [self.fileHandle writeData:data]; //追加写入数据
    if (data.length == 0) {
        [self.fileHandle closeFile];
        NSLog(@"[self.fileHandle closeFile]");
    }
}

/**
 *  创建Opus文件路径
 */
- (NSFileHandle *)fileHandle {
    if (_fileHandle == nil) {
        NSLog(@"初始化fileHandle开始");
        NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dataFilePath = [docsdir stringByAppendingPathComponent:@"opus"];
        BOOL isDirExist = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:dataFilePath isDirectory:&isDirExist];
        if (!isDirExist) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *filePath = [dataFilePath stringByAppendingPathComponent:@"ahh.opus"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            NSLog(@"remove file : %@", filePath);
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *str = @"";
            [str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        _fileHandle = fileHandle;
        NSLog(@"初始化fileHandle结束");
    }
    [_fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    return _fileHandle;
}

#pragma mark - PCM音频播放

/**
 *  播放PCM文件
 */
- (IBAction)playPCMFileBtnFunc:(id)sender {
    [[PCMFilePlayer sharePlayer] playPCMFileWithFileName:@"1"];
}



#pragma mark - UI Method

- (void)setupUI {
    _sw = [DFUITools screen_2_W];
    _sh = [DFUITools screen_2_H];
    if (_sh < 812.0f) {//兼容iPhoneX尺寸以下手机
        _sGap_h = 74.0;
        _sGap_t = 44.0;
    }else{
        _sGap_h = 88.0;
        _sGap_t = 64.0;
    }
    _subTitleView.frame = CGRectMake(0, 0, _sw, _sGap_h);
    _subLabel.center    = CGPointMake(_sw/2.0, _sGap_h - 20.0);
}

- (void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay {
    [loadingTip hide:YES ];
    UIWindow *win = [DFUITools getWindow];
    loadingTip = [DFUITools showHUDWithLabel:text onView:win
                                       color:[UIColor blackColor]
                              labelTextColor:[UIColor whiteColor]
                      activityIndicatorColor:[UIColor whiteColor]];
    [loadingTip hide:YES afterDelay:delay];
}

- (void)endLoadingView {
    [loadingTip hide:YES];
}



@end

