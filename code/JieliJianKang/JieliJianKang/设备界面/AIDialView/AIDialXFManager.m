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
    //TransferringView * mTransferringView; //第一次AI生成缩略图
    TransferringView * transferringView;  //第二次生成表盘
    TransferringView *aiStyleTransferringView; //进入AI表盘选择风格界面
    
    int mType;
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
        ApiSecret = @"abcd";   //请去科大讯飞的官网注册
        ApiKey = @"123456789"; //请去科大讯飞的官网注册
        appId = @"123456";     //请去科大讯飞的官网注册
        
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
        
        [self addNote];
    }
    return self;
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        //if(self->mTransferringView!=NULL) self->mTransferringView.hidden = YES;
        if(transferringView!=NULL) [transferringView removeFromSuperview];
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
    NSLog(@"date:%@",dt);
    NSString *authorization = [self makeAuthorization:dt];
    NSLog(@"Author:%@",authorization);
    
    NSString *signature = [self hmacSHA256WithSecret:authorization key:ApiSecret];
    NSLog(@"signature:%@",signature);
    
    NSString *authorization_origin = [NSString stringWithFormat:@"api_key=\"%@\", algorithm=\"%@\", headers=\"%@\", signature=\"%@\"",ApiKey,@"hmac-sha256",@"host date request-line",signature];
    NSLog(@"authorization_origin:%@",authorization_origin);
    
    NSData *tmpDt = [authorization_origin dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorizationTarget = [tmpDt base64EncodedStringWithOptions:0];
    NSLog(@"authorization:%@",authorizationTarget);
    
    
    NSDictionary *dict = @{
        @"authorization":authorizationTarget,
        @"date": [dt stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
        @"host": @"spark-api.cn-huabei-1.xf-yun.com"
    };
    
    NSString *localPath = [NSString stringWithFormat:@"%@?authorization=%@&date=%@&host=%@",hostPath,dict[@"authorization"],dict[@"date"],dict[@"host"]];
    NSLog(@"the request url:%@",localPath);
    
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

    //mTransferringView = [[TransferringView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    //UIWindow *win = [UIApplication sharedApplication].keyWindow;
    //[win addSubview:mTransferringView];
    
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
        if (error) {
            NSLog(@"请求错误：%@",error);
        }  else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"返回内容%@",dict);
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
                NSLog(@"basicImage:%@",self->basicImage);
                
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

-(NSString *)makeDialwithName:(NSString *)watchBinName withSize:(CGSize)size{
    
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    JLModel_Device *model = [mgr outputDeviceModel];
    
    NSData *imageData = [BitmapTool resizeImage:basicImage andResizeTo:CGSizeMake(size.width, size.height)];
    
    NSString *bmpPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];
    
    [JL_Tools removePath:bmpPath];
    [JL_Tools removePath:binPath];
    
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:watchBinName];
    
    UIImage *image = [UIImage imageWithData:imageData];
    int width = image.size.width;
    int height = image.size.height;
    NSLog(@"压缩分辨率 ---> w:%df h:%df",width,height);
    
    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:image];
    [JL_Tools writeData:bitmap fillFile:bmpPath];
    
    if (model.sdkType == JL_SDKType701xWATCH) {
        /*--- BR28压缩算法 ---*/
        //br28_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        
        //带有alpha的图片转换
        br28_btm_to_res_path_with_alpha((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        NSLog(@"--->Br28 BIN【%@】is OK!", watchBinName);
    }else{
        /*--- BR23压缩算法 ---*/
        br23_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        NSLog(@"--->Br23 BIN【%@】is OK!", watchBinName);
    }
    self->binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];
    return bmpPath;
}


//MARK: - 写入自定义表盘

-(void)makeCustomBgImgv:(UIImage *)basicImage{
    
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    
    __block NSString *watchBinName = @"";
    [mgr.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial Result:^(uint8_t flag, uint32_t size, NSString * _Nullable path, NSString * _Nullable describe) {
        NSLog(@"获取表盘成功!\n当前表盘 ---> %@",path);
        NSString *wName = [path lastPathComponent];
        if ([wName isEqual:@"WATCH"]) {
            watchBinName = @"BGP_W000";
        } else {
            NSString *txt = [wName stringByReplacingOccurrencesOfString:@"WATCH" withString:@""];
            NSInteger strLen = txt.length;
            if (strLen == 1) watchBinName = [NSString stringWithFormat:@"BGP_W00%@", txt];
            if (strLen == 2) watchBinName = [NSString stringWithFormat:@"BGP_W0%@", txt];
            if (strLen == 3) watchBinName = [NSString stringWithFormat:@"BGP_W%@", txt];
        }
        
        if (flag == 0) {
            [self makeDialwithName:watchBinName withSize:CGSizeMake(240, 240)];

            NSData *pathData = [NSData dataWithContentsOfFile:self->binPath];
            NSLog(@"-->添加AI 表盘缩略图的大小:%lld",(long long)pathData.length);
            
            [DialManager addFile:@"/AITHUMB" Content:pathData Result:^(DialOperateType type, float progress) {
                if (type == DialOperateTypeSuccess){
                    [self.dialManager aiDialSendThumbAiImageTo:mgr withPath:@"/AITHUMB" Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
//                        [JL_Tools mainTask:^{
//                            if(self->mTransferringView!=NULL) self->mTransferringView.hidden = YES;
//                        }];
                    }];
                }
            }];
            
        }
    }];
}

-(void)addDial:(TransferringView *) transferringView{
    NSString *wName = [NSString stringWithFormat:@"/%@",[binPath lastPathComponent]];
    NSData *pathData = [NSData dataWithContentsOfFile:binPath];
    NSLog(@"-->添加自定义表盘的大小:%lld",(long long)pathData.length);
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    __block typeof(self) wself = self;
    [DialManager addFile:wName Content:pathData Result:^(DialOperateType type, float progress) {
                
        if(wself->installResult){
            wself->installResult(progress*100,type);
        }
        
        if (type == DialOperateTypeNoSpace) {
            NSLog(@"空间不足");
            [JL_Tools mainTask:^{
                if(transferringView!=NULL) transferringView.hidden = YES;
            }];
        }
        if (type == DialOperateTypeFail) {
            NSLog(@"添加失败");
            [JL_Tools mainTask:^{
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                [DFUITools showText:@"表盘添加失败..." onView:win delay:1.5];
                if(transferringView!=NULL) transferringView.hidden = YES;
            }];
        }
        if (type == DialOperateTypeDoing) {
            NSLog(@"添加中...%.2f",progress*100);
        }
        if (type == DialOperateTypeSuccess) {
            NSLog(@"添加成功");
            wself->installResult = nil;
            [JL_Tools mainTask:^{
                if(transferringView!=NULL) transferringView.hidden = YES;
            }];
            
            /*--- 更新缓存 ---*/
            [kJL_DIAL_CACHE addWatchCustomListObject:wName];
            [mgr.mFlashManager cmdWatchFlashPath:wName Flag:JL_DialSettingActivateCustomDial
                                          Result:^(uint8_t flag, uint32_t size,
                                                   NSString * _Nullable path,
                                                   NSString * _Nullable describe) {
                [JL_Tools mainTask:^{
                    if (flag == 0){
                        NSLog(@"设置成功");
                        [wself saveImageToPath:self->basicImage];
                    }else{
                        NSLog(@"设置失败");
                    }
                }];
            }];
        }
    }];
}

-(void)replaceDialFile:(TransferringView *) transferringView{
    
    NSString *wName = [NSString stringWithFormat:@"/%@",[binPath lastPathComponent]];
    NSData *pathData = [NSData dataWithContentsOfFile:binPath];
    NSLog(@"-->添加自定义表盘的大小:%lld",(long long)pathData.length);
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    __block typeof(self) wself = self;
    //若设备端存在同名表盘背景时，替换表盘背景
    NSLog(@"-->跟新自定义表盘的大小:%lld",(long long)pathData.length);
    [DialManager repaceFile:wName Content:pathData
                     Result:^(DialOperateType type, float progress)
     {
        if(wself->installResult){
            wself->installResult(progress*100,type);
        }
        
        if (type == DialOperateTypeNoSpace) {
            NSLog(@"空间不足");
            [JL_Tools mainTask:^{
                if(transferringView!=NULL) transferringView.hidden = YES;
            }];
        }
        
        if (type == DialOperateTypeDoing) {
            NSLog(@"更新中...%.2f",progress*100);
        }
        
        if (type == DialOperateTypeFail) {
            NSLog(@"更新失败");
            [JL_Tools mainTask:^{
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                [DFUITools showText:@"表盘添加失败..." onView:win delay:1.5];
                if(transferringView!=NULL) transferringView.hidden = YES;
            }];
        }
        
        if (type == DialOperateTypeSuccess) {
            NSLog(@"更新成功");
            wself->installResult = nil;
            [JL_Tools mainTask:^{
                if(transferringView!=NULL) transferringView.hidden = YES;
            }];
            
            [mgr.mFlashManager cmdWatchFlashPath:wName Flag:JL_DialSettingActivateCustomDial
                                          Result:^(uint8_t flag, uint32_t size,
                                                   NSString * _Nullable path,
                                                   NSString * _Nullable describe) {
                [JL_Tools mainTask:^{
                    if (flag == 0){
                        NSLog(@"设置成功");
                        [wself saveImageToPath:wself->basicImage];
                    }else{
                        NSLog(@"设置失败");
                    }
                }];
            }];
        }
    }];
}

-(void)saveImageToPath:(UIImage *)image{
    NSData *dt = UIImagePNGRepresentation(image);
    NSDate *date = [NSDate new];
    NSDateFormatter *dtFm = [NSDateFormatter new];
    [dtFm setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"CustomDial" File:[NSString stringWithFormat:@"%@.png",[dtFm stringFromDate:date]]];
    [JL_Tools writeData:dt fillFile:path];
    [[NSUserDefaults standardUserDefaults] setValue:[dtFm stringFromDate:date] forKey:@"customerUsing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCustomDial" object:nil];
}

-(void)installDialToDevice:(UIImage *)img WithType:(int) type completion:(AiDialInstallResult)completion{
    
    installResult = completion;
    basicImage = img;
    mType = type;
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    
    __block NSString *watchBinName = @"";
    [mgr.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial Result:^(uint8_t flag, uint32_t size, NSString * _Nullable path, NSString * _Nullable describe) {
        NSLog(@"获取表盘成功!\n当前表盘 ---> %@",path);
        NSString *wName = [path lastPathComponent];
        if ([wName isEqual:@"WATCH"]) {
            watchBinName = @"BGP_W000";
        } else {
            NSString *txt = [wName stringByReplacingOccurrencesOfString:@"WATCH" withString:@""];
            NSInteger strLen = txt.length;
            if (strLen == 1) watchBinName = [NSString stringWithFormat:@"BGP_W00%@", txt];
            if (strLen == 2) watchBinName = [NSString stringWithFormat:@"BGP_W0%@", txt];
            if (strLen == 3) watchBinName = [NSString stringWithFormat:@"BGP_W%@", txt];
        }
        
        if (flag == 0) {
            self->transferringView = [[TransferringView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            UIWindow *win = [UIApplication sharedApplication].keyWindow;
            [win addSubview:self->transferringView];
            self->transferringView.hidden = NO;
//            if(self->mType == 0){
//                self->transferringView.hidden = NO;
//            }else{
//                self->transferringView.hidden = YES;
//            }
            
            JLModel_Device *model = [mgr outputDeviceModel];
            uint16_t dev_W = model.flashInfo.mScreenWidth;
            uint16_t dev_H = model.flashInfo.mScreenHeight;
            if (dev_W == 0) dev_W = 240;
            if (dev_H == 0) dev_H = 240;
            CGSize size = CGSizeMake(dev_W, dev_H);
            
            [self makeDialwithName:watchBinName withSize:size];
            
            NSMutableArray *customList = [kJL_DIAL_CACHE getWatchCustomList];
            if ([customList containsObject:watchBinName]) {
                [self replaceDialFile:self->transferringView];//更新自定义图片
            } else {
                [self addDial:self->transferringView];//增加自定义图片
            }
        }
    }];
    
}

//MARK: - AI 表盘代理
- (void)aiDialManager:(nonnull JLAIDialManager *)manager didAiDialStatusChange:(uint8_t)status {
    if(status == 0){
        NSLog(@"退出AI表盘");
        if(aiStyleTransferringView!=NULL) [aiStyleTransferringView removeFromSuperview];
    }
    if (status == 1){
        NSLog(@"进入AI表盘");
        
        if(aiStyleTransferringView!=NULL) {
            [aiStyleTransferringView removeFromSuperview];
        }
        
        aiStyleTransferringView = [[TransferringView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [win addSubview:aiStyleTransferringView];
        
        [self setAiDialStyle];
    }
}

- (void)aiDialdidReCreateManager:(nonnull JLAIDialManager *)manager {
    //重新创建
    NSLog(@"重新创建");
    [self requestToKdxf:requestContent];
}

- (void)aiDialdidRestartRecordManager:(nonnull JLAIDialManager *)manager {
    //    重新录音
    NSLog(@"重新录音");
    
}

- (void)aiDialdidStartCreateManager:(nonnull JLAIDialManager *)manager {
    //开始创建
    NSLog(@"开始创建");
    [self requestToKdxf:requestContent];
}

- (void)aiDialdidStartInstallManager:(nonnull JLAIDialManager *)manager {
    //开始安装
    NSLog(@"开始安装");
    [self installDialToDevice:basicImage WithType:1 completion:^(float progress, DialOperateType success) {
        
    }];
}

@end
