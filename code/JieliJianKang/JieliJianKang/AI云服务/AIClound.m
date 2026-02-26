//
//  AIClound.m
//  JieliJianKang
//
//  Created by 李放 on 2023/7/26.
//

#import "AIClound.h"
#import "SpeechRecognitionVC.h"
#import "IFlyAIUI/IFlyAIUI.h"
#import "JLSqliteAICloundMessageRecord.h"
#import "IFlyMSC/IFlyMSC.h"
#import <SpeexKit/SpeexKit.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import <AIKIT/AIKIT.h>
#import "TTSConfig.h"
#import "AIDialXFManager.h"

@interface AIClound()<IFlySpeechRecognizerDelegate,JL_SpeexManagerDelegate,
IFlySpeechSynthesizerDelegate,AIKITSparkDelegate,JLAIManagerDelegate>{
    UIButton *contentView;
    
    DFAudio         *myAudio;
    DFAudioFormat   *myFormat;
    
    int aiuiState;
    int offset;
    
    BOOL sendText;
    BOOL sendAIText;
    BOOL needPlayTTS;
    
    NSString *pcmFile;
    
    IFlySpeechRecognizer *iFlySpeechRecognizer;
    IFlySpeechSynthesizer *iFlySpeechSynthesizer;
    
    int exitAiState;
    NSMutableString * result;
    JL_SpeechAIttsHandler *speechAIHandler;
    int index;
    int chatIndex;
    int audioState;
    int mSn;
    int startIndex;
    int mType;
    NSString *mCurrentAIContext;

    JL_ManagerM *manager;
    int mAIState;
    JLAiManager *aiMananger;
    JL_SpeexManager *mSpeexManager;
    NSDate *myDate;
    NSDate *aiDate;
    NSMutableArray *tempArray;
    AFNetworkReachabilityStatus st;
    AIKITCtxContent *myAIKITCtxContent;
    
    NSTimer *speexHandleTimer;
    BOOL speexisHandle;
    int nowSpeexTime;
    int isCharting;
    
}

@property (nonatomic, strong) NSMutableString * content; // 语义解析返回的内容
@end


@implementation AIClound

+(id)sharedMe{
    static AIClound *ME = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ME = [[self alloc] init];
    });
    return ME;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNote];
        
        mType = 0;
        startIndex = 0;
        mAIState = 0;
        mSn = 0;
        exitAiState=-1;
        offset = 0;
        index = 0;
        chatIndex = 0;
        myFormat = [DFAudioFormat new];
        myFormat.mSampleRate = 16000;
        myFormat.mBitsPerChannel = 16;
        myFormat.mChannelsPerFrame = 1;
        myFormat.mFormatID = kAudioFormatLinearPCM;
        
        myAudio = [[DFAudio alloc] init];
        [myAudio setPlayerBufferSize:10*1024*1024 Format:myFormat];
        [myAudio didPlayerStart];
        
        [self initSynthesizer];
        
        [AiHelper setLogInfo:0 mode:0 path:@""];
        [AiHelper initSDK:^(AiHelperMaker * _Nonnull maker) {
            maker.appId(APPID_VALUE).apiKey(APIKEY).apiSecret(APISERECT);
        }];
        // 注册Spark回调
        [AiHelper registerChatCallback:self];
        
        aiMananger = [[JLAiManager alloc] init];
        aiMananger.delegate = self;
        
        tempArray = [NSMutableArray array];
    }
    return self;
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kOPUS_DECODE_DATA Action:@selector(notePCMData:) Own:self];
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];
    [JL_Tools add:kUI_JL_STOP_TTS Action:@selector(stopTTS:) Own:self];
    [JL_Tools add:kUI_AI_BECOME_ACTIVE Action:@selector(beComeActive) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [JL_Tools remove:kOPUS_DECODE_DATA Own:self];
    [JL_Tools remove:AFNetworkingReachabilityDidChangeNotification Own:self];
    [JL_Tools remove:kUI_JL_STOP_TTS Own:self];
    [JL_Tools remove:kUI_AI_BECOME_ACTIVE Own:self];
}

-(void)beComeActive{
    if(self->result.length==0){
        [iFlySpeechRecognizer startListening];
    }
}

-(void)stopTTS:(NSNotification*)note {
    mType = 1;
    [self->iFlySpeechSynthesizer stopSpeaking];
    [self->iFlySpeechRecognizer stopListening];
}

-(void)noteNetworkStatus:(NSNotification*)note{
    [self networkCheck];
}

-(void)networkCheck{
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    st = net.networkReachabilityStatus;
}

-(int)autoSN{
    return mSn++;
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeSomethingConnected) {
        if(self->iFlySpeechRecognizer == nil)
        {
            [self initRecognizer];
        }
        
        [self->iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
        //[self->iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        [self->iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        //[self->iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [self->iFlySpeechRecognizer setDelegate:self];
        [self->iFlySpeechRecognizer startListening];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [OpusUnit opusIsLog:YES];//Opus解码库的LOG
            [OpusUnit opusDecoderRun];//运行Opus解码库
        });
        
        [self showUI];
        
        manager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
        
        if(mSpeexManager==NULL){
            mSpeexManager = manager.mSpeexManager;
            mSpeexManager.delegate = self;
        }
        
        speechAIHandler = [[JL_SpeechAIttsHandler alloc]  initWithMgr:manager];
    }else if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        mType = 1;
        contentView.hidden = YES;
        startIndex = 0;
        [tempArray removeAllObjects];
        offset = 0;
        
        [self->iFlySpeechSynthesizer stopSpeaking];
        [self->iFlySpeechRecognizer stopListening];
    }
}

- (void)loadMore:(SqlAICloundMessageBlock)block{
    [self queryHistoryMessage:offset With:^(NSArray<AICloundMessageModel *> * _Nonnull chatMessages) {
        block(chatMessages);
    }];
}

-(void)queryHistoryMessage:(int) mOffest With:(SqlAICloundMessageBlock)block{
    NSDate *currentDate = [NSDate date];
    [JLSqliteAICloundMessageRecord s_checkoutWtihDate:currentDate WithOffset:mOffest WithResult:^(NSArray<AICloundMessageModel *> * _Nonnull chatMessages) {
        AICloundMessageModel *currentModel;
        NSDate *lastModelDate;
        //NSMutableArray *tempArray = [NSMutableArray array];
        if(chatMessages.count>0){
            for(int i=0;i<chatMessages.count;i++){
                AICloundMessageModel *message = [[AICloundMessageModel alloc] init];
                currentModel = [chatMessages objectAtIndex:i];
                if(i==0){
                    currentModel.isFirstPage = YES;
                    lastModelDate = currentModel.date;
                }else{
                    if([self getCurrentMin:currentModel.date WithLastDate:lastModelDate]>10){
                        currentModel.isFirstPage = YES;
                        lastModelDate = currentModel.date;
                    }else{
                        currentModel.isFirstPage = NO;
                    }
                }
                message.isFirstPage = currentModel.isFirstPage;
                [message setDate:currentModel.date];
                [message setRole:currentModel.role];
                [message setText:currentModel.text];
                [message setAiCloudState:currentModel.aiCloudState];
                [self->tempArray addObject:message];
            }
            self->offset+=chatMessages.count;
            block(self->tempArray);
        }
    }];
}

-(int)getCurrentMin:(NSDate *)currentDate WithLastDate:(NSDate *)lastDate{
    NSString * dayString=@"0";
    NSString * hourString=@"0";
    NSString * minuteString=@"0";
     
    double currentTime = [currentDate timeIntervalSince1970];
    double lastTime = [lastDate timeIntervalSince1970];
    double poorTime = currentTime - lastTime;
    
    NSNumber *numStage =  [NSNumber numberWithDouble:poorTime];
    NSString *numStr = [NSString stringWithFormat:@"%0.0lf",[numStage doubleValue]];//将double类型数据取整
    NSInteger timeInt=[numStr integerValue];
    
    if (timeInt>=86400)
       {
           dayString = [NSString stringWithFormat:@"%ld", timeInt/86400];
           timeInt-=[dayString integerValue]*86400;
       }
       if (timeInt>=3600 && timeInt<86400) {
           hourString = [NSString stringWithFormat:@"%ld", timeInt/3600];
           timeInt-=[hourString integerValue]*3600;
       }
       if (timeInt<3600) {
           minuteString = [NSString stringWithFormat:@"%ld", timeInt/60];
       }
    
    return [minuteString intValue];
}

-(void)createAIView{
    contentView = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-200/2,44,200,48)];
    contentView.backgroundColor = UIColor.blackColor;
    contentView.layer.shadowOpacity = 1;
    contentView.layer.shadowRadius = 10;
    [contentView addTarget:self action:@selector(enterSpeechRecognitionVC) forControlEvents:UIControlEventTouchUpInside];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:contentView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(25, 25)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    contentView.layer.mask = maskLayer;
    
    CGRect aiImvrect = CGRectMake(54,13,22,22);
    UIImageView *aiImv = [[UIImageView alloc] initWithFrame:aiImvrect];
    aiImv.contentMode = UIViewContentModeScaleToFill;
    UIImage *image = [UIImage imageNamed:@"icon_ai_nol"];
    aiImv.image = image;
    [contentView addSubview:aiImv];
    
    CGRect aiTextrect = CGRectMake(aiImv.frame.origin.x+22+11,10,100,30);
    DFLabel *aiTextView = [[DFLabel alloc] initWithFrame:aiTextrect];
    aiTextView.backgroundColor = [UIColor clearColor];
    aiTextView.text = kJL_TXT("AI云服务");
    aiTextView.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    aiTextView.textColor = UIColor.whiteColor;
    aiTextView.labelType = DFLeftRight;
    [contentView addSubview:aiTextView];
    
    //    UITapGestureRecognizer *contentViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterSpeechRecognitionVC)];
    //    [contentView addGestureRecognizer:contentViewGestureRecognizer];
}


//MARK: - 设备录音回调
/// 录音状态回调
/// - Parameters:
///   - status: 录音状态
///   - originator: 状态变更发起端
///   当发起者是Device时，才会具备params的参数，其中结束录音时，params的属性仅有mVadWay为可使用内容
///   - params: 录音参数
-(void)speexManagerStatus:(JL_SpeakType)status By:(JLCMDOriginator)originator With:(JLRecordParams *_Nullable) params{
    audioState = status;
    
    if(status == JL_SpeakTypeDo){
        startIndex++;
        mType = 0;
        if(startIndex==1){
            startIndex=-10000;
            int sn = [self autoSN];
            mCurrentAIContext = [NSString stringWithFormat:@"%d",sn];
            self->index = 0;
            chatIndex = 0;
            contentView.hidden = NO;
            self->result = @"".mutableCopy;
            exitAiState = -1;
            
            if(mAIState == 1){
                if ([_aiCloundDelegate respondsToSelector:@selector(deleteLastItem)]) {
                    [_aiCloundDelegate deleteLastItem];
                }
            }
            
            if(isCharting){ //响应聊天
                [JL_Tools mainTask:^{
                    AICloundMessageModel *mCloundMessageModel = [[AICloundMessageModel alloc] init];
                    mCloundMessageModel.role = 1; //用户
                    mCloundMessageModel.aiCloudState = 1;
                    mCloundMessageModel.text = @"开始识别...";
                    mCloundMessageModel.date = [NSDate date];
                    [self initMyData:mCloundMessageModel];
                }];
            }
            
            [self->iFlySpeechSynthesizer stopSpeaking];
            //[self->iFlySpeechRecognizer cancel];
            [self->iFlySpeechRecognizer startListening];

        }
    }else if(status == JL_SpeakTypeDone){
        self->mAIState = 3;
        startIndex =0;

        contentView.hidden = YES;
        [iFlySpeechRecognizer stopListening];
        
        sendText = params.speechRecognit.sendText;
        sendAIText = params.speechRecognit.sendAIText;
        needPlayTTS = params.speechRecognit.needPlayTTS;
        
        if (st == AFNetworkReachabilityStatusNotReachable || st == AFNetworkReachabilityStatusUnknown) {
            JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
            speechAiClound.version = 0;
            speechAiClound.type = 2;
            speechAiClound.vendorID = 1;
            speechAiClound.lenght = kJL_TXT("网络有点问题").length;
            speechAiClound.playload = [kJL_TXT("网络有点问题") dataUsingEncoding:NSUTF8StringEncoding];
            
            [self->speechAIHandler speechSendAiCloud:speechAiClound manager:manager result:^(JL_BigData * _Nonnull bigData) {
                return;
            }];
        }
        NSLog(@"\n\nspeex 语音对话结束\n\n");
        [speexHandleTimer invalidate];
        speexHandleTimer = nil;
        speexisHandle = false;
        nowSpeexTime = 0;
        speexHandleTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleSpeexHandleRunner) userInfo:nil repeats:true];
        [speexHandleTimer fire];

    }else if(status == JL_SpeakTypeDoing){
        
    }
}


/// 录音数据回调
/// - Parameter data: 数据
-(void)speexManagerAudio:(NSData *)data{
    NSLog(@"speexManagerAudio:%@",data);
    [OpusUnit opusWriteData:data];
}

-(void)handleSpeexHandleRunner{
    nowSpeexTime+=1;
    if (nowSpeexTime>3){
        if (isCharting){
            [self handleSpeexCallBack];
        }
        nowSpeexTime = 0;
        [speexHandleTimer invalidate];
    }
}

//MARK: -  PCM回调

- (void)notePCMData:(NSNotification*)note {
    NSData *data = [note object];
    NSLog(@"notePCMData:%@",data);

    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self->iFlySpeechRecognizer writeAudio:data];
    });
}



-(void)enterSpeechRecognitionVC{
//    SpeechRecognitionVC *vc = [[SpeechRecognitionVC alloc] init];
//    [JLApplicationDelegate.navigationController pushViewController:vc animated:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}

#pragma mark - 显示/消失
- (void)showUI {
    [self createAIView];
    
    UIWindow *window = [DFUITools getWindow];
    [window makeKeyAndVisible];
    [window addSubview:contentView];
    contentView.hidden = YES;
}

- (void)dismiss {
    [contentView removeFromSuperview];
}

#pragma mark 获取当前时间
-(NSString *)getCurrentTime{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd hh:mm"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return  dateString;
}

-(void)initRecognizer{
    if (iFlySpeechRecognizer == nil) {
        iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    [iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    [iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    iFlySpeechRecognizer.delegate = self;
    
    if (iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //set timeout of recording
        [iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //set VAD timeout of end of speech(EOS)
        [iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //set VAD timeout of beginning of speech(BOS)
        [iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //set network timeout
        [iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //set sample rate, 16K as a recommended option
        [iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        //set language
        [iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //set accent
        [iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        
        //set whether or not to show punctuation in recognition results
        [iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
}


#pragma mark - IFlySpeechRecognizerDelegate

/**
 volume callback,range from 0 to 30.
 **/
- (void) onVolumeChanged: (int)volume
{
    
}

/**
 Beginning Of Speech
 **/
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
}

/**
 End Of Speech
 **/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
}

/**
 result callback of recognition without view
 results：recognition results
 isLast：whether or not this is the last result
 **/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString *resultFromJson = [ISRDataHelper stringFromJson:resultString];
    [result appendString:resultFromJson];

    [JL_Tools delay:1.0 Task:^{
        if(self->result.length>0){
            self->mAIState = 1;
        }else{
            self->mAIState = 3;
        }
    }];
    
    if(audioState == JL_SpeakTypeDoing){
        [iFlySpeechRecognizer startListening];
    }
    if (isLast){
        NSLog(@"\n\nspeex科大讯飞语音识别的内容是：%@\n\n",result);
        speexisHandle = true;
        nowSpeexTime = 0;
        [speexHandleTimer invalidate];
        
        if([self->result containsString:@"。"]){
            NSString *newStr =  [self->result stringByReplacingOccurrencesOfString:@"。" withString:@""];
            self->result = [newStr mutableCopy];
        }
        
        if([self->result containsString:@"？"]){
            NSString *newStr =  [self->result stringByReplacingOccurrencesOfString:@"？" withString:@""];
            self->result = [newStr mutableCopy];
        }
        
        if(((self->st == AFNetworkReachabilityStatusReachableViaWWAN) || (self->st == AFNetworkReachabilityStatusReachableViaWiFi)) && (self->result.length == 0) && (audioState == JL_SpeakTypeDone)){
            JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
            speechAiClound.version = 0;
            speechAiClound.type = 2;
            speechAiClound.vendorID = 1;
            speechAiClound.lenght = kJL_TXT("您好像并没有开始说话").length;
            speechAiClound.playload = [kJL_TXT("您好像并没有开始说话") dataUsingEncoding:NSUTF8StringEncoding];
            
            [self->speechAIHandler speechSendAiCloud:speechAiClound manager:self->manager result:^(JL_BigData * _Nonnull bigData) {
            }];
            [DFUITools showText:kJL_TXT("您好像并没有开始说话") onView:[DFUITools getWindow] delay:1.5];
            [JL_Tools post:kUI_JL_NO_RECORED Object:nil];
            
            if ([self->_aiCloundDelegate respondsToSelector:@selector(deleteLastItem)]) {
                [self->_aiCloundDelegate deleteLastItem];
            }
            
            return;
        }
        
        if (isCharting){
            //响应聊天
            [self handleSpeexCallBack];
        }
        if ([[AIDialXFManager share] dialManager].isCreateing){
            //响应创建AI表盘
            [self sendSpeexContentToDev];
        }
    }
}


- (NSMutableString *)content {
    if (!_content) {
        _content = [NSMutableString stringWithString:@""];
    }
    return _content;
}


//MARK: - 处理识别后的数据
-(void)handleSpeexCallBack{

    [JL_Tools mainTask:^{
        AICloundMessageModel *mCloundMessageModel = [[AICloundMessageModel alloc] init];
        mCloundMessageModel.role = 1; //用户
        mCloundMessageModel.aiCloudState = 1;
        mCloundMessageModel.text = @"识别中...";
        mCloundMessageModel.date = [NSDate date];
        [self update:mCloundMessageModel];
    }];
    
    self->index++;
    
    [JL_Tools delay:0.5 Task:^{
        if(self->sendText && self->result.length>0 && self->exitAiState!=2 && self->index==1){
            self->index=-10;
            
            [JL_Tools mainTask:^{
                AICloundMessageModel *mCloundMessageModel = [[AICloundMessageModel alloc] init];
                mCloundMessageModel.role = 1; //用户
                mCloundMessageModel.aiCloudState = 2; // 成功
                mCloundMessageModel.date = [NSDate date];
                self->myDate = mCloundMessageModel.date;
                if(self->result.length>256){
                    NSMutableString *aiMyStr = [NSMutableString stringWithString:@""];
                    NSString *str1 = [[self->result substringWithRange:NSMakeRange(0, 256)] mutableCopy];
                    NSString *str2 = @"...";
                    [aiMyStr appendString:str1];
                    [aiMyStr appendString:str2];
                    mCloundMessageModel.text = aiMyStr;
                }else{
                    mCloundMessageModel.text = self->result;
                }
                [JL_Tools delay:0.7 Task:^{
                    [self initMyData:mCloundMessageModel];
                }];
            }];
            
            [self sendSpeexContentToDev];
            
            [JL_Tools subTask:^{
                AIKITUsrContext *aiKIUSerContext = [[AIKITUsrContext alloc] init];
                aiKIUSerContext.ctxName = self->mCurrentAIContext;
                [AiHelper asyncChat:[self getChatParam] inputText:self->result usrContext:aiKIUSerContext];
                self.content = @"".mutableCopy;
            }];
        }
    }];
    
}


-(void)sendSpeexContentToDev{
    JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
    speechAiClound.version = 0;
    speechAiClound.type = 0;
    speechAiClound.vendorID = 1;
    speechAiClound.lenght = [self->result length];
    if(self->result.length>256){
        NSMutableString *aiMulStr = [NSMutableString stringWithString:@""];
        NSString *str1 = [[self->result substringWithRange:NSMakeRange(0, 256)] mutableCopy];
        NSString *str2 = @"...";
        [aiMulStr appendString:str1];
        [aiMulStr appendString:str2];
        NSString *aiString =[aiMulStr stringByReplacingOccurrencesOfString:@"\n"withString:@""];//去除换行符
        speechAiClound.playload = [aiString dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        NSString *aiString =[self->result stringByReplacingOccurrencesOfString:@"\n"withString:@""];//去除换行符
        speechAiClound.playload = [aiString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if(result.length > 0){
        [[AIDialXFManager share] setRequestContent:result];
    }
    [self->speechAIHandler speechSendAiCloud:speechAiClound manager:self->manager result:^(JL_BigData * _Nonnull bigData) {
    }];
    
}

#pragma mark - Spark chat Delegate
// 结果回调
- (void)onChatOutput:(NSUInteger)handleId role:(NSString *)role content:(NSString *)content index:(int)index userContext:(AIKITCtxContent *)usrctx {
    myAIKITCtxContent = usrctx;
    
    if([mCurrentAIContext isEqualToString:usrctx.ctxName]){
        [self.content appendString:content];
    }

    chatIndex++;
    if(chatIndex==1){
        chatIndex = -100;
        [JL_Tools subTask:^{
            if(self->result.length>0 && self->exitAiState!=2){
                AICloundMessageModel *mCloundMessageModel = [[AICloundMessageModel alloc] init];
                mCloundMessageModel.role = 1; //用户
                mCloundMessageModel.aiCloudState = 2; // 成功
                mCloundMessageModel.date = self->myDate;
                if(self->result.length>256){
                    NSMutableString *aiMyStr = [NSMutableString stringWithString:@""];
                    NSString *str1 = [[self->result substringWithRange:NSMakeRange(0, 256)] mutableCopy];
                    NSString *str2 = @"...";
                    [aiMyStr appendString:str1];
                    [aiMyStr appendString:str2];
                    mCloundMessageModel.text = aiMyStr;
                }else{
                    mCloundMessageModel.text = self->result;
                }
                [JLSqliteAICloundMessageRecord s_update:mCloundMessageModel];
            }
        }];
    }
}

// 错误回调
- (void)onChatError:(NSUInteger)handleId errNo:(int)errNo desc:(NSString *)errDesc userContext:(AIKITCtxContent *)usrctx {
    myAIKITCtxContent = usrctx;
    
    if(((errNo == 10019) || (errNo == 10013)|| (errNo == 10014) || (errNo == 11200)) && sendAIText && exitAiState!=2 && [mCurrentAIContext isEqualToString:usrctx.ctxName]){
        mAIState = 2;
        NSString *errorStr = @"抱歉，我可能没有理解您的问题。请您详细描述您想了解的内容，我会尽力为您提供帮助。";
        
        [JL_Tools subTask:^{
            if(self->result.length>0 && self->chatIndex==0){
                AICloundMessageModel *mCloundMessageModel = [[AICloundMessageModel alloc] init];
                mCloundMessageModel.role = 1; //用户
                mCloundMessageModel.aiCloudState = 2; // 成功
                mCloundMessageModel.date = self->myDate;
                if(self->result.length>256){
                    NSMutableString *aiMyStr = [NSMutableString stringWithString:@""];
                    NSString *str1 = [[self->result substringWithRange:NSMakeRange(0, 256)] mutableCopy];
                    NSString *str2 = @"...";
                    [aiMyStr appendString:str1];
                    [aiMyStr appendString:str2];
                    mCloundMessageModel.text = aiMyStr;
                }else{
                    mCloundMessageModel.text = self->result;
                }
                [JLSqliteAICloundMessageRecord s_update:mCloundMessageModel];
            }
        }];
        
        AVAudioSession * session = [AVAudioSession sharedInstance];
        if (!session) printf("ERROR INITIALIZING AUDIO SESSION! \n");
        else{
            NSError *nsError = nil;
            [session setCategory:AVAudioSessionCategoryPlayback error:&nsError];
            [session setActive:YES error:&nsError];
        }
        if(mType!=1) [self->iFlySpeechSynthesizer startSpeaking:errorStr];
        
        [JL_Tools delay:0.5 Task:^{
            if(self->mAIState == 2){
                AICloundMessageModel *model = [[AICloundMessageModel alloc] init];
                model.role = 2; //AI
                model.aiCloudState = 2; // 成功
                model.date = [NSDate date];
                self->aiDate = model.date;
                model.text = errorStr;
                [self initAIData:model];
                
                JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
                speechAiClound.version = 0;
                speechAiClound.type = 1;
                speechAiClound.vendorID = 1;
                speechAiClound.lenght = errorStr.length;
                NSString *aiString =[errorStr stringByReplacingOccurrencesOfString:@"\n"withString:@""];//去除换行符
                speechAiClound.playload = [aiString dataUsingEncoding:NSUTF8StringEncoding];

                [self->speechAIHandler speechSendAiCloud:speechAiClound manager:self->manager result:^(JL_BigData * _Nonnull bigData) {
                }];
                
                AICloundMessageModel *aiCloundMessageModel = [[AICloundMessageModel alloc] init];
                aiCloundMessageModel.role = 2; //AI
                aiCloundMessageModel.aiCloudState = 2; // 成功
                aiCloundMessageModel.date = self->aiDate;
                aiCloundMessageModel.text = errorStr;
                [JLSqliteAICloundMessageRecord s_update:aiCloundMessageModel];
            }
        }];
    }
//    [JL_Tools mainTask:^{
//        [DFUITools showText:errDesc onView:[DFUITools getWindow] delay:1.5];
//    }];
}

// token回调
- (void)onChatToken:(NSUInteger)handleId completion:(int)completionTokens prompt:(int)promptTokens total:(int)totalTokens userContext:(AIKITCtxContent *)usrctx {
    myAIKITCtxContent = usrctx;
    
    if(sendAIText && self.content.length>0 && exitAiState!=2 && [mCurrentAIContext isEqualToString:usrctx.ctxName]){
        mAIState = 2;
        if([self->result containsString:@"。"]){
            NSString *newStr =  [self->result stringByReplacingOccurrencesOfString:@"。" withString:@""];
            self->result = [newStr mutableCopy];
        }
        
        if([self->result containsString:@"？"]){
            NSString *newStr =  [self->result stringByReplacingOccurrencesOfString:@"？" withString:@""];
            self->result = [newStr mutableCopy];
        }
        
        AVAudioSession * session = [AVAudioSession sharedInstance];
        if (!session) printf("ERROR INITIALIZING AUDIO SESSION! \n");
        else{
            NSError *nsError = nil;
            [session setCategory:AVAudioSessionCategoryPlayback error:&nsError];
            [session setActive:YES error:&nsError];
        }
        if(mType!=1) [self->iFlySpeechSynthesizer startSpeaking:self.content];

        [JL_Tools mainTask:^{
            AICloundMessageModel *aiCloundMessageModel = [[AICloundMessageModel alloc] init];
            aiCloundMessageModel.role = 2; //AI
            aiCloundMessageModel.aiCloudState = 2; // 成功
            aiCloundMessageModel.date = [NSDate date];
            self->aiDate = aiCloundMessageModel.date;
            if(self.content.length>256){
                NSMutableString *aiContentStr = [NSMutableString stringWithString:@""];
                NSString *str1 = [[self.content substringWithRange:NSMakeRange(0, 256)] mutableCopy];
                NSString *str2 = @"...";
                [aiContentStr appendString:str1];
                [aiContentStr appendString:str2];
                aiCloundMessageModel.text = aiContentStr;
            }else{
                aiCloundMessageModel.text = self.content;
            }
            [self initAIData:aiCloundMessageModel];
        }];
        
        [JL_Tools delay:0.5 Task:^{
            [JL_Tools subTask:^{
                JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
                speechAiClound.version = 0;
                speechAiClound.type = 1;
                speechAiClound.vendorID = 1;
                speechAiClound.lenght = self.content.length;
                if(self.content.length>256){
                    NSMutableString *aiContentStr = [NSMutableString stringWithString:@""];
                    NSString *str1 = [[self.content substringWithRange:NSMakeRange(0, 256)] mutableCopy];
                    NSString *str2 = @"...";
                    [aiContentStr appendString:str1];
                    [aiContentStr appendString:str2];
                    NSString *aiString =[aiContentStr stringByReplacingOccurrencesOfString:@"\n"withString:@""];//去除换行符
                    speechAiClound.playload = [aiString dataUsingEncoding:NSUTF8StringEncoding];
                }else{
                    NSString *aiString =[self.content stringByReplacingOccurrencesOfString:@"\n"withString:@""];//去除换行符
                    speechAiClound.playload = [aiString dataUsingEncoding:NSUTF8StringEncoding];
                }

                [self->speechAIHandler speechSendAiCloud:speechAiClound manager:self->manager result:^(JL_BigData * _Nonnull bigData) {
                }];
                
                AICloundMessageModel *aiCloundMessageModel = [[AICloundMessageModel alloc] init];
                aiCloundMessageModel.role = 2; //AI
                aiCloundMessageModel.aiCloudState = 2; // 成功
                aiCloundMessageModel.date = self->aiDate;
                if(self.content.length>256){
                    NSMutableString *aiStr = [NSMutableString stringWithString:@""];
                    NSString *str1 = [[self.content substringWithRange:NSMakeRange(0, 256)] mutableCopy];
                    NSString *str2 = @"...";
                    [aiStr appendString:str1];
                    [aiStr appendString:str2];
                    aiCloundMessageModel.text = aiStr;
                }else{
                    aiCloundMessageModel.text = self.content;
                }
                [JLSqliteAICloundMessageRecord s_update:aiCloundMessageModel];
            }];
        }];
    }
}

#pragma mark - Initialization

- (void)initSynthesizer
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //TTS singleton
    if (iFlySpeechSynthesizer == nil) {
        iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    iFlySpeechSynthesizer.delegate = self;
    
    [iFlySpeechSynthesizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //set the resource path, only for offline TTS
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *newResPath = [[NSString alloc] initWithFormat:@"%@/xtts/purextts_common.jet;%@/xtts/purextts_xiaoyan.jet",resPath,resPath];

    [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
    
    [iFlySpeechSynthesizer setParameter:newResPath forKey:@"tts_res_path"];
    
    //set speed,range from 1 to 100.
    [iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];

    //set volume,range from 1 to 100.
    [iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];

    //set pitch,range from 1 to 100.
    [iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];

    //set sample rate
    [iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];

    //set TTS speaker
    [iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    [iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    //set xtts params
    [iFlySpeechSynthesizer setParameter:@"1" forKey:@"rdn"];
    [iFlySpeechSynthesizer setParameter:@"0" forKey:@"effect"];
    [iFlySpeechSynthesizer setParameter:@"0" forKey:@"rcn"];
    
    
    NSLog(@"iFlySpeechSynthesizer:%@",iFlySpeechSynthesizer);
    //set engine type
    [iFlySpeechSynthesizer setParameter:instance.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
}

- (ChatParam *)getChatParam {
    return ChatParam.builder()
                    .uid(@"AIKit")
                    .domain(@"general")
                    .maxToken(1024)
                    .auditing(@"default")
                    .temperature(0.55)
                    .topK(4)
                    .chatID(@"123")
                    .url(@"ws://aichat.xf-yun.com/v1/chat");
}

//IFlySpeechRecognizerDelegate协议实现
//IFlySpeechSynthesizerDelegate协议实现
- (void) onCompleted:(IFlySpeechError *) error {
    [error logProperties];
    if((([error errorCode] == 20001) || ([error errorCode] == 10212)) &&  (audioState == JL_SpeakTypeDone)){
        JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
        speechAiClound.version = 0;
        speechAiClound.type = 2;
        speechAiClound.vendorID = 1;
        speechAiClound.lenght = kJL_TXT("网络有点问题").length;
        speechAiClound.playload = [kJL_TXT("网络有点问题") dataUsingEncoding:NSUTF8StringEncoding];
        
        [self->speechAIHandler speechSendAiCloud:speechAiClound manager:manager result:^(JL_BigData * _Nonnull bigData) {
        }];
    }else if([error errorCode]==0){
        if(((self->st == AFNetworkReachabilityStatusReachableViaWWAN) || (self->st == AFNetworkReachabilityStatusReachableViaWiFi)) && (self->result.length == 0) && (audioState == JL_SpeakTypeDone)){
            JLSpeechAiCloud *speechAiClound = [[JLSpeechAiCloud alloc] init];
            speechAiClound.version = 0;
            speechAiClound.type = 2;
            speechAiClound.vendorID = 1;
            speechAiClound.lenght = kJL_TXT("您好像并没有开始说话").length;
            speechAiClound.playload = [kJL_TXT("您好像并没有开始说话") dataUsingEncoding:NSUTF8StringEncoding];
            
            [self->speechAIHandler speechSendAiCloud:speechAiClound manager:self->manager result:^(JL_BigData * _Nonnull bigData) {
            }];
            [DFUITools showText:kJL_TXT("您好像并没有开始说话") onView:[DFUITools getWindow] delay:1.5];
            [JL_Tools post:kUI_JL_NO_RECORED Object:nil];
            
            if ([self->_aiCloundDelegate respondsToSelector:@selector(deleteLastItem)]) {
                [self->_aiCloundDelegate deleteLastItem];
            }
        }
    }
}

//合成开始
- (void) onSpeakBegin {
    JL_RunSDK  *bleSDK = [JL_RunSDK sharedMe];
    if(needPlayTTS){
        [bleSDK.mBleEntityM.mCmdManager cmdStartTTSNote:0];
    }
}

//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg {
    
}

//合成播放进度
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos {
    if(progress == 100){
        JL_RunSDK  *bleSDK = [JL_RunSDK sharedMe];
        if(needPlayTTS){
            [bleSDK.mBleEntityM.mCmdManager cmdStartTTSNote:1];
        }
    }
}

-(void)initMyData:(AICloundMessageModel *) aiCloundMessageModel{
    if ([_aiCloundDelegate respondsToSelector:@selector(initMyData:)]) {
        [_aiCloundDelegate initMyData:aiCloundMessageModel];
    }
}

-(void)initAIData:(AICloundMessageModel *) aiCloundMessageModel{
    if ([_aiCloundDelegate respondsToSelector:@selector(initAIData:)]) {
        [_aiCloundDelegate initAIData:aiCloundMessageModel];
    }
}

-(void)update:(AICloundMessageModel *) aiCloundMessageModel{
    if ([_aiCloundDelegate respondsToSelector:@selector(update:)]) {
        [_aiCloundDelegate update:aiCloundMessageModel];
    }
}

//MARK: - AI 设备推送进入/退出AI表盘
/// 设备回调/推送结果
/// - Parameter mgr: 设备对象
-(void)jlaiUpdateStatus:(JLAiManager *)mgr{
    exitAiState = mgr.status;
    if(mgr.status==2){
        startIndex =0;
    }
    if(mgr.status == 2 && self->result.length>0){
        [self->iFlySpeechSynthesizer stopSpeaking];
        //[self->iFlySpeechRecognizer stopListening];

        if(mAIState == 1 && [mCurrentAIContext isEqualToString:myAIKITCtxContent.ctxName]){
            NSMutableArray *selectTimeArray = [NSMutableArray array];
            if ([_aiCloundDelegate respondsToSelector:@selector(deleteLastItem)]) {
                [_aiCloundDelegate deleteLastItem];
            }

            NSTimeInterval timestamp = [myDate timeIntervalSince1970];
            [selectTimeArray addObject:[NSNumber numberWithInteger:(NSInteger)timestamp]];
            [JLSqliteAICloundMessageRecord s_delete:selectTimeArray];
        }
    }
    if (mgr.status == 1) {
        NSLog(@"进入AI 对讲");
        isCharting = true;
    }else if (mgr.status == 2){
        NSLog(@"退出AI 对讲");
        isCharting = false;
    }
}

@end
