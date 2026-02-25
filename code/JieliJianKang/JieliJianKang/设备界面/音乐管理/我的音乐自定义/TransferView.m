//
//  TransferView.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/15.
//

#import "TransferView.h"
#import "JL_RunSDK.h"
#import "JLFileTransferHelper.h"

@interface TransferView(){
    UIView *bgView;
    UIView *bottomView;
    
    //传输过程中
    UILabel *label1;     //正在传输 (2/10)
    UILabel *label2;     //传输百分比
    UILabel *label3;     //歌曲名字
    UILabel *label4;     //音乐传输描述
    UIProgressView *pv;  //传输的进度条View
    
    //传输成功
    UIImageView *imv;    //传输成功的图片
    UILabel     *label5; //传输成功的文字
    
    UIView  *fenGenView; //分割View;
    UIButton *mBtn; //按钮;
    float sw;
    float sh;
    
    int mTransferIndex; //歌曲已传输的个数
    int mTotalCount;  //传输歌曲的总个数
    NSArray *mSelectArray;
    
    BOOL transgerFlag; //传输音乐的标识
    NSMutableArray *tempArray; //存储待传输的音乐
}

@end
@implementation TransferView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
        
        transgerFlag = NO;
        
        [self initUI];
    }
    return self;
}

-(void)initUI{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(12, sh-17-196, sw-24, 196)];
    [self addSubview:bottomView];
    bottomView.backgroundColor = [UIColor whiteColor];
    
    bottomView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    bottomView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,1);
    bottomView.layer.shadowOpacity = 1;
    bottomView.layer.shadowRadius = 10;
    bottomView.layer.cornerRadius = 15;
    
    label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(28,31,115,22);
    label1.numberOfLines = 0;
    [bottomView addSubview:label1];
    label1.font =  [UIFont fontWithName:@"PingFang SC" size: 16];
    label1.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(bottomView.frame.size.width-28-35,31,50,22);
    label2.numberOfLines = 0;
    [bottomView addSubview:label2];
    label2.font =  [UIFont fontWithName:@"PingFang SC" size: 16];
    label2.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    label3 = [[UILabel alloc] init];
    label3.frame = CGRectMake(28,label1.frame.origin.y+label1.frame.size.height+4,bottomView.frame.size.width-28,15);
    label3.numberOfLines = 0;
    [bottomView addSubview:label3];
    label3.font =  [UIFont fontWithName:@"PingFang SC" size: 10];
    label3.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    pv = [[UIProgressView alloc]initWithFrame:CGRectMake(28, 83, sw-24-56, 3)];
    pv.progressTintColor = kDF_RGBA(85, 140, 255, 1.0);
    pv.trackTintColor = kDF_RGBA(216, 216, 216, 1.0);
    pv.layer.cornerRadius = 1.5;
    pv.layer.masksToBounds = YES;
    [bottomView addSubview:pv];
    
    label4 = [[UILabel alloc] init];
    label4.frame = CGRectMake(20,pv.frame.origin.y+pv.frame.size.height+16,sw-24-40,20);
    label4.numberOfLines = 0;
    [bottomView addSubview:label4];
    label4.font =  [UIFont fontWithName:@"PingFang SC" size: 14];
    label4.text = kJL_TXT("音乐文件传输中请保持手机与手表的蓝牙连接");
    label4.contentMode = UIViewContentModeCenter;
    label4.textAlignment = NSTextAlignmentCenter;
    label4.textColor = kDF_RGBA(145, 145, 145, 1.0);
    
    fenGenView = [[UIView alloc] init];
    fenGenView.frame = CGRectMake(0,label4.frame.origin.y+label4.frame.size.height+23,sw-24,1);
    fenGenView.backgroundColor = kDF_RGBA(247, 247, 247, 1.0);
    [bottomView addSubview:fenGenView];
    
    mBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,196-50,sw-24,50)];
    [mBtn addTarget:self action:@selector(cancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [mBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    [mBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:16]];
    [mBtn setTitleColor:kDF_RGBA(36, 36, 36, 1.0) forState:UIControlStateNormal];
    [bottomView addSubview:mBtn];
    
    CGRect rect = CGRectMake((sw-24)/2-58/2,27,58,58);
    imv = [[UIImageView alloc] initWithFrame:rect];
    imv.contentMode = UIViewContentModeScaleToFill;
    UIImage *image = [UIImage imageNamed:@"icon_success_nol"];
    imv.image = image;
    [bottomView addSubview:imv];
    
    label5 = [[UILabel alloc] init];
    label5.frame = CGRectMake(imv.frame.origin.x-31,imv.frame.origin.y+imv.frame.size.height+15,sw-24,22);
    label5.numberOfLines = 0;
    [bottomView addSubview:label5];
    label5.font =  [UIFont fontWithName:@"PingFang SC" size: 16];
    label5.contentMode = UIViewContentModeCenter;
    label5.textColor = kDF_RGBA(36, 36, 36, 1.0);
    
    label1.hidden = YES;
    label2.hidden = YES;
    label3.hidden = YES;
    label4.hidden = YES;
    pv.hidden = YES;
    
    imv.hidden = YES;
    label5.hidden = YES;
}

-(void)setTotalCount:(int)totalCount{
    mTotalCount = totalCount;
    label1.text = [NSString stringWithFormat:@"%@ %@%d%@", kJL_TXT("正在传输"), @"(1/", mTotalCount, @")"];
    label5.text = [NSString stringWithFormat:@"%d%@", mTotalCount, kJL_TXT("首音乐传输成功")];
}

-(void)setSelectArray:(NSArray *)selectArray{
    mSelectArray = selectArray;
    
    self->imv.hidden = YES;
    self->label5.hidden = YES;
    
    label1.text = [NSString stringWithFormat:@"%@ %@%d%@%d%@", kJL_TXT("正在传输"), @"(", (int)(mTotalCount - selectArray.count + 1), @"/", mTotalCount, @")"];
    label1.hidden = NO;
    label2.hidden = NO;
    label3.hidden = NO;
    label4.hidden = NO;
    pv.hidden = NO;

    for (int i = 0; i<selectArray.count;i++) {
        if(transgerFlag == YES){
            return;
        }
        
        self->transgerFlag = YES;
        
        NSString *path = [DFFile listPath:NSDocumentDirectory MiddlePath:@"music"
                                  File:mSelectArray[i]];
        NSString *name = mSelectArray[i];

        
        [kJL_BLE_CmdManager.mFileManager setCurrentFileHandleType:[JLFileTransferHelper getMusicTargetDev]];
        [kJL_BLE_CmdManager.mFileManager cmdPreEnvironment:0x00 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
            [kJL_BLE_CmdManager.mFileManager cmdBigFileData:path WithFileName:name Result:^(JL_BigFileResult result, float progress) {
                if(result == JL_BigFileTransferStart){
                    self->label2.text = @"0%";
                    self->pv.progress = 0;
                }
                if(result == JL_BigFileTransferDownload){
                    
                    self->label3.text = self->mSelectArray[i];
                    
                    NSString *txt = [NSString stringWithFormat:@"%.0f%%",progress*100.0f];
                    self->label2.text = txt;
                    self->pv.progress = progress;
                }
                if(result == JL_BigFileTransferEnd){
                    self->transgerFlag = NO;
                    
                    self->tempArray = [NSMutableArray new];
                    self->tempArray = [selectArray mutableCopy];
                    [self->tempArray removeObject:selectArray[i]];
                    
                    if(self->tempArray.count>0){
                        [JL_Tools delay:1.0 Task:^{
                            [self setSelectArray:self->tempArray];
                        }];
                    }else{
                        self->label1.hidden = YES;
                        self->label2.hidden = YES;
                        self->label3.hidden = YES;
                        self->label4.hidden = YES;
                        self->pv.hidden = YES;

                        self->imv.hidden = NO;
                        self->label5.hidden = NO;
                    }
                    self->label2.text = @"100%";
                    self->pv.progress = 1.0;

                    [self->mBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
                    [self->mBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
                }
                if(result == JL_BigFileTransferOutOfRange){
                    [DFUITools showText:kJL_TXT("文件传输数据越界") onView:self delay:1.0];
                }
                if(result == JL_BigFileTransferFail){
                    [DFUITools showText:kJL_TXT("文件传输失败") onView:self delay:1.0];
                }
                if(result == JL_BigFileCrcError){
                    [DFUITools showText:kJL_TXT("文件校验失败") onView:self delay:1.0];
                }
                if (result == JL_BigFileOutOfMemory) {
                    [DFUITools showText:kJL_TXT("设备没有空间") onView:self delay:1.0];
                }
                if (result == JL_BigFileTransferNoResponse) {
                    [DFUITools showText:kJL_TXT("设备响应超时") onView:self delay:1.0];
                }
                if (result == JL_BigFileTransferCancel) {
                    [DFUITools showText:@"传输取消" onView:self delay:1.0];
                }
            }];
        }];
    }
}

#pragma mark 取消按钮
-(void)cancelBtn:(UIButton *)btn{
    self.hidden = YES;
    if (transgerFlag) {
        self->transgerFlag = NO;
        
        [kJL_BLE_CmdManager.mFileManager cmdStopBigFileData];
    }
    // 所有文件传输完成
    if ((pv.progress == 1.0) && (pv.hidden == YES)) {
        if ([self.delegate respondsToSelector:@selector(transferAllMusicFinish)]) {
            [self.delegate transferAllMusicFinish];
        }
    }
}
@end
