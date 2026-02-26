//
//  BigFileVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/18.
//

#import "BigFileVC.h"
#import "JLHeadFile.h"
#import "TipView.h"


#import "DocumentView.h"


@interface BigFileVC (){
    DocumentView    *myDocumentView;
    
    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;
    JL_Timer        *mTimer;
}

@end

@implementation BigFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    bt_ble = bleSDK.bt_ble;
    
    mCmdManager = self->bt_ble.mAssist.mCmdManager;
    
    mTimer = [[JL_Timer alloc] init];
    mTimer.subTimeout = 10;
    mTimer.subScale = 1;
}

- (IBAction)startTransport:(id)sender {
    myDocumentView = [[DocumentView alloc] init];
    [self.view addSubview:myDocumentView];
    
    NSString *mPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:@""];
    [myDocumentView showWithPath:mPath Result:^(NSString * _Nonnull file) {
        NSString *path = [mPath stringByAppendingPathComponent:file];
        [self transportFile:path];
    }];
}

-(void)transportFile:(NSString*)path{
    [JL_Tools mainTask:^{
        [TipView startLoadingView:@"大文件传输..." Delay:60*8];
        
        //设置设备的环境变量
        [self->mCmdManager.mFileManager cmdPreEnvironment:JL_FileOperationEnvironmentTypeBigFileTransmission
                                             Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            
            //大文件传输API
            [self->mCmdManager.mFileManager cmdBigFileData:path WithFileName:[path lastPathComponent]
                                              Result:^(JL_BigFileResult result,
                                                       float progress) {
                if (result == JL_BigFileTransferStart) {
                    NSLog(@"---> 开始传输。");
                    [TipView setLoadingText:@"开始传输"];
                }
                if (result == JL_BigFileTransferEnd) {
                    NSLog(@"---> 传输完成");
                    [TipView setLoadingText:@"传输完成" Delay:0.5];
                }
                if (result == JL_BigFileTransferDownload) {
                    NSLog(@"---> 传输进度: %.2f",progress);
                    NSString *txt = [NSString stringWithFormat:@"传输进度:%.1f%%",progress*100.0f];
                    [TipView setLoadingText:txt];
                }
                if (result == JL_BigFileTransferOutOfRange) {
                    [TipView setLoadingText:@"传输数据超范围" Delay:0.5];
                }
                if (result == JL_BigFileTransferFail) {
                    [TipView setLoadingText:@"文件传输失败" Delay:0.5];
                }
                if (result == JL_BigFileCrcError) {
                    [TipView setLoadingText:@"文件校验失败" Delay:0.5];
                }
                if (result == JL_BigFileOutOfMemory) {
                    [TipView setLoadingText:@"空间不足" Delay:0.5];
                }
                if (result == JL_BigFileTransferNoResponse) {
                    [TipView setLoadingText:@"设备没有响应" Delay:0.5];
                }
                if (result == JL_BigFileTransferCancel) {
                    NSLog(@"---> 传输取消");
                    [TipView setLoadingText:@"传输取消" Delay:0.5];
                }
            }];
        }];
        
//        [JL_Tools delay:2.0 Task:^{
//            [self stopTransport:nil];
//        }];
        
    }];
}

-(void)transportFilesArray:(NSArray*)filesArray{
    [JL_Tools subTask:^{
        [TipView startLoadingView:@"大文件传输..." Delay:60*8];
        //设置设备的环境变量
        [self->mCmdManager.mFileManager cmdPreEnvironment:JL_FileOperationEnvironmentTypeBigFileTransmission
                                             Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            if(status == JL_CMDStatusSuccess){
                [self->mTimer threadContinue];
            }
        }];
        [self->mTimer threadWait];
        
        for (NSString *path in filesArray) {
            //大文件传输API
            [self->mCmdManager.mFileManager cmdBigFileData:path WithFileName:[path lastPathComponent]
                                              Result:^(JL_BigFileResult result,
                                                       float progress) {
                if(result != JL_BigFileTransferDownload ||
                   result != JL_BigFileTransferStart){
                    [self->mTimer threadContinue];
                }
                
                if (result == JL_BigFileTransferStart) {
                    NSLog(@"---> 开始传输。");
                    [TipView setLoadingText:@"开始传输"];
                }
                if (result == JL_BigFileTransferEnd) {
                    NSLog(@"---> 传输完成");
                    [TipView setLoadingText:@"传输完成" Delay:0.5];
                }
                if (result == JL_BigFileTransferDownload) {
                    NSLog(@"---> 传输进度: %.2f",progress);
                    NSString *txt = [NSString stringWithFormat:@"传输进度:%.1f%%",progress*100.0f];
                    [TipView setLoadingText:txt];
                }
                if (result == JL_BigFileTransferOutOfRange) {
                    [TipView setLoadingText:@"传输数据超范围" Delay:0.5];
                }
                if (result == JL_BigFileTransferFail) {
                    [TipView setLoadingText:@"文件传输失败" Delay:0.5];
                }
                if (result == JL_BigFileCrcError) {
                    [TipView setLoadingText:@"文件校验失败" Delay:0.5];
                }
                if (result == JL_BigFileOutOfMemory) {
                    [TipView setLoadingText:@"空间不足" Delay:0.5];
                }
                if (result == JL_BigFileTransferNoResponse) {
                    [TipView setLoadingText:@"设备没有响应" Delay:0.5];
                }
                if (result == JL_BigFileTransferCancel) {
                    NSLog(@"---> 传输取消");
                    [TipView setLoadingText:@"传输取消" Delay:0.5];
                }
            }];
            [self->mTimer threadWait];
        }
    }];
}


- (IBAction)stopTransport:(id)sender {
    [mCmdManager.mFileManager cmdStopBigFileData];
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
