//
//  AIDialXFManager.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/13.
//

#import "AIDialXFManager.h"
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "TransferringView.h"


#define HANDLE_INDEX_SAVE @"handleIndexSave"

@interface AIDialXFManager ()<JLAIDialManagerDelegate>{
    NSString *hostPath;
    NSString *ApiSecret;
    NSString *ApiKey;
    NSString *appId;
    NSDateFormatter *dateFm;
    AFHTTPSessionManager *Afmanager;
    NSString *binPath;
    UIImage *basicImage;
    NSString *requestContent;
    AiDialInstallResult installResult;
    TransferringView *aiStyleTransferringView; //进入AI表盘选择风格界面
    UIImage *originSizeImage;
    int mType;
    NSTimer *transferringTimer;
    int currentTime;
    int maxTime;
}
@end

@implementation AIDialXFManager

+(instancetype)share{
    static AIDialXFManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return  manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        hostPath = @"https://spark-api.cn-huabei-1.xf-yun.com/v2.1/tti";
        ApiSecret = @"ZjMzNTM0ZGJiMDQ2ODI2NTQyNWVjOTcy";
        ApiKey = @"65dbf2af3c95900e31024e6d2e3b99da";
        appId = @"94df387f";
        
        maxTime = 20;
        currentTime = 0;
        
        Afmanager = [AFHTTPSessionManager manager];
        
        dateFm = [NSDateFormatter new];
        dateFm.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
        dateFm.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss zzz";
        dateFm.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        
        _dialManager = [[JLAIDialManager alloc] init];
        _dialManager.delegate = self;
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
        path = [path stringByAppendingPathComponent:@"aithume.png"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        basicImage = [UIImage imageWithData:data];
        
        aiStyleTransferringView = [[TransferringView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [win addSubview:aiStyleTransferringView];
        aiStyleTransferringView.hidden = true;
        [self addNote];
    }
    return self;
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] intValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        if(aiStyleTransferringView!=NULL) [aiStyleTransferringView removeFromSuperview];
    }
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)setRequestContent:(NSString *)content{
    requestContent = content;
}

//MARK: - create url

-(NSString *)createUrl{
    printf("\n\n\n\n");
    
    NSString *dt = [dateFm stringFromDate:[NSDate new]];
    kJLLog(JLLOG_DEBUG, @"date:%@",dt);
    NSString *authorization = [self makeAuthorization:dt];
    kJLLog(JLLOG_DEBUG, @"Author:%@",authorization);
    
    NSString *signature = [self hmacSHA256WithSecret:authorization key:ApiSecret];
    kJLLog(JLLOG_DEBUG, @"signature:%@",signature);
    
    NSString *authorization_origin = [NSString stringWithFormat:@"api_key=\"%@\", algorithm=\"%@\", headers=\"%@\", signature=\"%@\"",ApiKey,@"hmac-sha256",@"host date request-line",signature];
    kJLLog(JLLOG_DEBUG, @"authorization_origin:%@",authorization_origin);
    
    NSData *tmpDt = [authorization_origin dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationTarget = [tmpDt base64EncodedStringWithOptions:0];
    kJLLog(JLLOG_DEBUG, @"authorization:%@",authorizationTarget);
    
    
    NSDictionary *dict = @{
        @"authorization":authorizationTarget,
        @"date": [dt stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
        @"host": @"spark-api.cn-huabei-1.xf-yun.com"
    };
    
    NSString *localPath = [NSString stringWithFormat:@"%@?authorization=%@&date=%@&host=%@",hostPath,dict[@"authorization"],dict[@"date"],dict[@"host"]];
    kJLLog(JLLOG_DEBUG, @"the request url:%@",localPath);
    
    printf("\n\n\n\n");
    return localPath;
}

-(NSString *)makeAuthorization:(NSString *)dateStr{
    NSString * authorization = [NSString stringWithFormat:@"host: spark-api.cn-huabei-1.xf-yun.com\ndate: %@\nPOST /v2.1/tti HTTP/1.1",dateStr];
    return authorization;
}

-(NSString *)hmacSHA256WithSecret:(NSString *)sectret key:(NSString *)key{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [sectret cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return hash;
}

//MARK: - Request Body

-(void)saveTypeIndex:(int)index{
    [[NSUserDefaults standardUserDefaults] setValue:@(index) forKey:HANDLE_INDEX_SAVE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(int)getType{
    int index = [[NSUserDefaults.standardUserDefaults valueForKey:HANDLE_INDEX_SAVE] intValue];
    return index;
}

-(NSString *)typeIndex{
    int index = [[NSUserDefaults.standardUserDefaults valueForKey:HANDLE_INDEX_SAVE] intValue];
    switch (index) {
        case 0:
            return @"水墨画风格";
            break;
        case 1:
            return @"写实风景风格";
            break;
        case 2:
            return @"3D卡通风格";
            break;
        case 3:
            return @"赛博朋克风格";
            break;
        case 4:
            return @"折纸风格";
            break;
        case 5:
            return @"水彩墨风格";
            break;
        default:
            return @"水墨画风格";
            break;
    }
}

-(NSDictionary *)requestBody:(NSString *)content{
    NSDictionary *dict = @{
        @"header": @{
            @"app_id": appId,
        },
        @"parameter":@{
            @"chat":@{
                @"domain":@"general"
            }
        },
        @"payload": @{
            @"message":@{
                @"text": @[
                    @{
                        @"role":@"user",
                        @"content": [NSString stringWithFormat:@"%@%@",[self typeIndex],content]
                    }
                ],
            }
        }
    };
    return dict;
}

//MARK: - 请求科大讯飞生成内容
-(void)requestToKdxf:(NSString *)content{
    
    
    [AlertViewOnWindows showAIServiceTips];
    requestContent = content;
    
    NSURL *url = [NSURL URLWithString:[self createUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *params = [self requestBody:content];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{@"content-Type": @"application/json"};
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [AlertViewOnWindows removeAIServiceTips];
        if (error) {
            kJLLog(JLLOG_DEBUG, @"请求错误：%@",error);
        }  else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            kJLLog(JLLOG_DEBUG, @"返回内容%@",dict);
            int code = [dict[@"header"][@"code"] intValue];
            if(code!=0){
                [JL_Tools mainTask:^{
                    UIWindow *win = [UIApplication sharedApplication].keyWindow;
                    [DFUITools showText:@"请求错误,请重新申请图片" onView:win delay:1.5];
                    //if(self->mTransferringView!=NULL) self->mTransferringView.hidden = YES;
                }];
            }else{
                NSArray *arr = dict[@"payload"][@"choices"][@"text"];
                NSDictionary *txtDict = arr.firstObject;
                NSString *content = txtDict[@"content"];
                NSData *dt = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
                self->basicImage = [UIImage imageWithData:dt];
                kJLLog(JLLOG_DEBUG, @"basicImage:%@",self->basicImage);
                self->originSizeImage = [UIImage imageWithData:dt];
                [self makeCustomBgImgv:self->basicImage];
            }
        }
    }];
    [dataTask resume];
}


-(void)setAiDialStyle{
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    [self.dialManager aiDialSetManager:mgr AiStyle:[self typeIndex] Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
    }];
}

//MARK: - 图像处理

-(void)makeDialwithSize:(CGSize)size Result:(void (^)(NSData *_Nullable data))result{
    
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    JLModel_Device *model = [mgr outputDeviceModel];
    UIImage *radiusImage = [AIDialXFManager machRadius:basicImage withBg:true];
    NSData *imageData = [JLBmpConvert resizeImage:radiusImage andResizeTo:CGSizeMake(size.width, size.height)];
    UIImage *image = [UIImage imageWithData:imageData];
    
    JLBmpConvertType type = JLBmpConvertType701N_ARBG;
    if (model.sdkType == JL_SDKType701xWATCH) {
        type = JLBmpConvertType701N_ARBG;
    }else if (model.sdkType == JL_SDKType695xWATCH){
        type = JLBmpConvertType695N_RBG;
    }else if (model.sdkType == JL_SDKType707nWATCH){
        type = JLBmpConvertType707N_ARGB;
    }
    [JLBmpConvert covert:type Image:image completion:^(NSData * _Nullable outFileData, NSError * _Nullable error) {
        if (error) {
            kJLLog(JLLOG_DEBUG, @"图片转换失败");
            return ;
        }
        if (outFileData) {
            result(outFileData);
        }
    }];
}


//MARK: - 写入自定义表盘

-(void)makeCustomBgImgv:(UIImage *)basicImage{
    
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    
    __block NSString *watchBinName = @"";
    [mgr.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial Result:^(uint8_t flag, uint32_t size, NSString * _Nullable path, NSString * _Nullable describe) {
        kJLLog(JLLOG_DEBUG, @"获取表盘成功!\n当前表盘 ---> %@",path);
        NSString *wName = [path lastPathComponent];
        if ([wName isEqual:@"WATCH"]) {
            watchBinName = @"/BGP_W000";
        } else {
            NSString *txt = [wName stringByReplacingOccurrencesOfString:@"WATCH" withString:@""];
            NSInteger strLen = txt.length;
            if (strLen == 1) watchBinName = [NSString stringWithFormat:@"/BGP_W00%@", txt];
            if (strLen == 2) watchBinName = [NSString stringWithFormat:@"/BGP_W0%@", txt];
            if (strLen == 3) watchBinName = [NSString stringWithFormat:@"/BGP_W%@", txt];
        }
        
        if (flag == 0) {
            CGSize scaleZoomSize = self->_dialManager.scaleZoomSize;
            [self makeDialwithSize:scaleZoomSize Result:^(NSData * _Nullable data) {
                if (data) {
                    [JL_Tools mainTask:^{
                        self->aiStyleTransferringView.hidden = NO;
                    }];
                    kJLLog(JLLOG_DEBUG, @"-->添加AI 表盘缩略图的大小:%lld",(long long)data.length);
                    [DialManager addFile:@"/AITHUMB" Content:data Result:^(DialOperateType type, float progress) {
                        if (type == DialOperateTypeSuccess){
                            [self.dialManager aiDialSendThumbAiImageTo:mgr withPath:@"/AITHUMB" Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

-(void)addDial:(NSString *)wName Data:(NSData *)pathData{
    kJLLog(JLLOG_DEBUG, @"-->添加自定义表盘的大小:%lld",(long long)pathData.length);
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    __block typeof(self) wself = self;
    [DialManager addFile:wName Content:pathData Result:^(DialOperateType type, float progress) {
        [self continueTimer];
        if(wself->installResult){
            wself->installResult(progress*100,type);
        }
        if (type == DialOperateTypeNoSpace) {
            kJLLog(JLLOG_DEBUG, @"空间不足");
            [JL_Tools mainTask:^{
                self->aiStyleTransferringView.hidden = YES;
            }];
            [self removeTimer];
        }
        if (type == DialOperateTypeFail) {
            kJLLog(JLLOG_DEBUG, @"添加失败");
            [JL_Tools mainTask:^{
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                [DFUITools showText:@"表盘添加失败..." onView:win delay:1.5];
                self->aiStyleTransferringView.hidden = YES;
            }];
            [self removeTimer];
        }
        if (type == DialOperateTypeDoing) {
            kJLLog(JLLOG_DEBUG, @"添加中...%.2f",progress*100);
        }
        if (type == DialOperateTypeSuccess) {
            kJLLog(JLLOG_DEBUG, @"添加成功");
            [self removeTimer];
            wself->installResult = nil;
            [JL_Tools mainTask:^{
                self->aiStyleTransferringView.hidden = YES;
            }];
            [mgr.mFlashManager cmdWatchFlashPath:wName Flag:JL_DialSettingActivateCustomDial
                                          Result:^(uint8_t flag, uint32_t size,
                                                   NSString * _Nullable path,
                                                   NSString * _Nullable describe) {
                [JL_Tools mainTask:^{
                    if (flag == 0){
                        kJLLog(JLLOG_DEBUG, @"设置成功");
                        [wself saveImageToPath];
                    }else{
                        kJLLog(JLLOG_DEBUG, @"设置失败");
                    }
                }];
            }];
        }
    }];
}

-(void)replaceDialFile:(NSString *)wName Data:(NSData *)pathData{
    
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    __block typeof(self) wself = self;
    //若设备端存在同名表盘背景时，替换表盘背景
    kJLLog(JLLOG_DEBUG, @"-->跟新自定义表盘的大小:%lld",(long long)pathData.length);
    [DialManager repaceFile:wName Content:pathData
                     Result:^(DialOperateType type, float progress)
     {
    [self continueTimer];
    if(wself->installResult){
        wself->installResult(progress*100,type);
    }
    
    if (type == DialOperateTypeNoSpace) {
        kJLLog(JLLOG_DEBUG, @"空间不足");
        [JL_Tools mainTask:^{
            self->aiStyleTransferringView.hidden = YES;
        }];
        [self removeTimer];
    }
    
    if (type == DialOperateTypeDoing) {
        kJLLog(JLLOG_DEBUG, @"更新中...%.2f",progress*100);
    }
    
    if (type == DialOperateTypeFail) {
        kJLLog(JLLOG_DEBUG, @"更新失败");
        [JL_Tools mainTask:^{
            UIWindow *win = [UIApplication sharedApplication].keyWindow;
            [DFUITools showText:@"表盘添加失败..." onView:win delay:1.5];
            self->aiStyleTransferringView.hidden = YES;
        }];
        [self removeTimer];
    }
    
    if (type == DialOperateTypeSuccess) {
        kJLLog(JLLOG_DEBUG, @"更新成功:%@",wName);
        [self removeTimer];
        wself->installResult = nil;
        [JL_Tools mainTask:^{
            self->aiStyleTransferringView.hidden = YES;
        }];
        
        [mgr.mFlashManager cmdWatchFlashPath:wName Flag:JL_DialSettingActivateCustomDial
                                      Result:^(uint8_t flag, uint32_t size,
                                               NSString * _Nullable path,
                                               NSString * _Nullable describe) {
            [JL_Tools mainTask:^{
                if (flag == 0){
                    kJLLog(JLLOG_DEBUG, @"设置成功");
                    [wself saveImageToPath];
                }else{
                    kJLLog(JLLOG_DEBUG, @"设置失败");
                }
            }];
        }];
    }
    }];
}

-(void)saveImageToPath{
    if (basicImage && originSizeImage){
        
        NSDate *date = [NSDate new];
        NSDateFormatter *dtFm = [NSDateFormatter new];
        [dtFm setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *middlePath = [NSString stringWithFormat:@"%@/CustomDial",[EcTools appUserDevFolder]];
        NSString *path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:middlePath File:[NSString stringWithFormat:@"%@.png",[dtFm stringFromDate:date]]];
        NSData *dt = UIImagePNGRepresentation(basicImage);
        [JL_Tools writeData:dt fillFile:path];
        
        NSString *pathOrigin = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"CustomDialOrigin" File:[NSString stringWithFormat:@"%@.png",[dtFm stringFromDate:date]]];
        NSData *dtOrigin = UIImagePNGRepresentation(originSizeImage);
        [JL_Tools writeData:dtOrigin fillFile:pathOrigin];
        
        [[NSUserDefaults standardUserDefaults] setValue:[dtFm stringFromDate:date] forKey:@"customerUsing"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCustomDial" object:nil];
        basicImage = nil;
        originSizeImage = nil;
    }
}

-(void)installDialToDevice:(UIImage *)img WithType:(int) type  originSizeImage:(UIImage*) originSizeImage completion:(AiDialInstallResult)completion{
    
    installResult = completion;
    basicImage = img;
    mType = type;
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    self->originSizeImage = originSizeImage;
    
    [self timerAction];
    
    __block NSString *watchBinName = @"";
    [mgr.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial Result:^(uint8_t flag, uint32_t size, NSString * _Nullable path, NSString * _Nullable describe) {
        kJLLog(JLLOG_DEBUG, @"获取表盘成功!\n当前表盘 ---> %@",path);
        NSString *wName = [path lastPathComponent];
        if ([wName isEqual:@"WATCH"]) {
            watchBinName = @"/BGP_W000";
        } else {
            NSString *txt = [wName stringByReplacingOccurrencesOfString:@"WATCH" withString:@""];
            NSInteger strLen = txt.length;
            if (strLen == 1) watchBinName = [NSString stringWithFormat:@"/BGP_W00%@", txt];
            if (strLen == 2) watchBinName = [NSString stringWithFormat:@"/BGP_W0%@", txt];
            if (strLen == 3) watchBinName = [NSString stringWithFormat:@"/BGP_W%@", txt];
        }
        
        if (flag == 0) {
            if(type == 1){
                self->aiStyleTransferringView.hidden = NO;
            }
            JLModel_Device *model = [mgr outputDeviceModel];
            uint16_t dev_W = model.flashInfo.mScreenWidth;
            uint16_t dev_H = model.flashInfo.mScreenHeight;
            if (dev_W == 0) dev_W = 240;
            if (dev_H == 0) dev_H = 240;
            CGSize tmpSize = CGSizeMake(dev_W, dev_H);
            NSMutableArray *customList = [kJL_DIAL_CACHE getWatchCustomList];
            [self makeDialwithSize:tmpSize Result:^(NSData * _Nullable data) {
                if (data == nil){
                    kJLLog(JLLOG_DEBUG, @"convert 的数据为空不更新表盘");
                    return;
                }
                if ([customList containsObject:watchBinName]) {
                    [self replaceDialFile:watchBinName Data:data];//更新自定义图片
                } else {
                    [self addDial:watchBinName Data:data];//增加自定义图片
                }
            }];
            
        }
    }];
    
}

//MARK: - AI 表盘代理
- (void)aiDialManager:(nonnull JLAIDialManager *)manager didAiDialStatusChange:(uint8_t)status {
    if(status == 0){
        kJLLog(JLLOG_DEBUG, @"退出AI表盘");
        [aiStyleTransferringView setHidden:true];
    }
    if (status == 1){
        kJLLog(JLLOG_DEBUG, @"进入AI表盘");
        [aiStyleTransferringView setHidden:NO];
    }
}

- (void)aiDialdidReCreateManager:(nonnull JLAIDialManager *)manager {
    //重新创建
    kJLLog(JLLOG_DEBUG, @"重新创建");
    [self requestToKdxf:requestContent];
    [aiStyleTransferringView setHidden:true];
}

- (void)aiDialdidRestartRecordManager:(nonnull JLAIDialManager *)manager {
    //    重新录音
    kJLLog(JLLOG_DEBUG, @"重新录音");
    [aiStyleTransferringView setHidden:true];
}

- (void)aiDialdidStartCreateManager:(nonnull JLAIDialManager *)manager {
    //开始创建
    kJLLog(JLLOG_DEBUG, @"开始创建");
    [self requestToKdxf:requestContent];
}

- (void)aiDialdidStartInstallManager:(nonnull JLAIDialManager *)manager {
    //开始安装
    kJLLog(JLLOG_DEBUG, @"开始安装");
    [self installDialToDevice:basicImage WithType:1 originSizeImage:originSizeImage completion:^(float progress, DialOperateType success) {
        
    }];
}

/// 裁剪图片方法
/// - Parameter image: 图片
/// - Parameter withBg: 是否带背景
/// - Returns: 裁剪后的图片
+(UIImage *)machRadius:(UIImage *)image withBg:(BOOL)withBg{
    UIView *tmpView = [[UIView alloc] init];
    JLModel_Flash *flashModel = kJL_BLE_CmdManager.mFlashManager.flashInfo;
    CGFloat dev_W = flashModel.mScreenWidth == 0 ? 240 : flashModel.mScreenWidth;
    CGFloat dev_H = flashModel.mScreenHeight == 0 ? 240 : flashModel.mScreenHeight;
    CGSize screenSize = CGSizeMake(dev_W/2.0, dev_H/2.0);
    JLDialInfoExtentedModel *dialInfoModel = [[JL_RunSDK sharedMe] dialInfoExtentedModel];
    tmpView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    if (withBg) {
        tmpView.backgroundColor = dialInfoModel.backgroundColor;
    }else{
        tmpView.backgroundColor = [UIColor clearColor];
    }
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    imgv.image = image;
    if ([[JL_RunSDK sharedMe] configModel].exportFunc.spDialInfoExtend){
        if (dialInfoModel.shape == 0x01){ //圆
            imgv.layer.cornerRadius = screenSize.width/2;
        }else if (dialInfoModel.shape == 0x02){ //矩形
            imgv.layer.cornerRadius = 0;
        }else if (dialInfoModel.shape == 0x03){ //圆角矩形
            imgv.layer.cornerRadius = dialInfoModel.radius/2;
        }
    }
    imgv.layer.masksToBounds = YES;
    [tmpView addSubview:imgv];
    UIGraphicsBeginImageContextWithOptions(tmpView.frame.size, NO, 2);
    [tmpView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *targetImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImg;
}

//MARK: - 计时器
- (void)timerAction {
    [transferringTimer invalidate];
    currentTime = 0;
    transferringTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimerAction) userInfo:nil repeats:true];
    [transferringTimer fire];
}

-(void)countTimerAction{
    currentTime++;
    if (currentTime > maxTime) {
        [transferringTimer invalidate];
        currentTime = 0;
        if(installResult){
            kJLLog(JLLOG_DEBUG, @"安装失败timeout");
            installResult(0,DialOperateTypeFail);
        }
    }
}

-(void)continueTimer{
    currentTime = 0;
}

-(void)removeTimer{
    [transferringTimer invalidate];
    transferringTimer = nil;
    currentTime = 0;
}



@end
