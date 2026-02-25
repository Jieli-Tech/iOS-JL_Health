//
//  WatchMarket.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/4/1.
//

#import "WatchMarket.h"
#import "User_Http.h"
#import "JLWatchHttp.h"

@implementation WatchMarket

static WatchMarket *market = nil;
+(id)sharedMe{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        market = [[self alloc] init];
    });
    return market;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.watchListFree = [NSMutableArray new];
        self.watchListPay  = [NSMutableArray new];
    }
    return self;
}

-(void)searchAllWatchResult:(void(^)(void))result{

    JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
    //NSArray *versionArray = [model.flashInfo.mFlashMatchVersion componentsSeparatedByString:@","];
    
    NSData *pidVidData = [JL_Tools HexToData:model.pidvid];
    int vid = (int)[JL_Tools dataToInt:[JL_Tools data:pidVidData R:0 L:2]];
    int pid = (int)[JL_Tools dataToInt:[JL_Tools data:pidVidData R:2 L:2]];
//    NSString *vid_str = [NSString stringWithFormat:@"%d",vid];
//    NSString *pid_str = [NSString stringWithFormat:@"%d",pid];
    NSLog(@"WATCH MARKET--->【%@】Vid:%d Pid:%d",model.pidvid,vid,pid);
    
    
    /*--- 审核测试 ---*/
    UserProfile *pf = [[User_Http shareInstance] userPfInfo];
    if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
        [pf.email isEqual:kStoreIAP_MOBILE]) {
        //Vid:2 Pid:130
        vid = 2;
        pid = 130;
        NSLog(@"WATCH MARKET--->【TEST】Vid:%d Pid:%d",vid,pid);
        
    }
    
    
    /*--- 8-1. 根据pid、vid获取手表产品信息 ---*/
    [JLWatchHttp requestWatchInfoPid:pid Vid:vid Result:^(NSDictionary * _Nonnull info) {
        if (![info[@"data"] isEqual:[NSNull null]] && info) {
            NSString *id_str = info[@"data"][@"id"];
            NSString *configString = info[@"data"][@"configData"];

            
            /*--- 检查是否支持表盘商城支付功能 ---*/
            kJL_DIAL_CACHE.isSupportPayment = YES;
            if (![configString isEqual:[NSNull null]]) {
                NSData *configData = [configString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:configData
                                                                           options:NSJSONReadingMutableLeaves error:nil];
                
                NSLog(@"Config INFO ---> %@",configDict);
                kJL_DIAL_CACHE.isSupportPayment = [configDict[@"support_dial_payment"] boolValue];
            }
            NSString *iconStr = info[@"data"][@"icon"];
            [[AutoProductIcon share] saveToLocalWithPid:pid vid:vid :iconStr];
            
            /*--- 审核测试 ---*/
            UserProfile *pf = [[User_Http shareInstance] userPfInfo];
            if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
                [pf.email isEqual:kStoreIAP_MOBILE]) {
                kJL_DIAL_CACHE.isSupportPayment = YES;
            }
            
            
            if (kJL_DIAL_CACHE.isSupportPayment) {
                /*--- 付费+免费的表盘商城 ---*/
                /*--- 8-2. 根据pid、vid获取手表产品信息(免费表盘) ---*/
                [JLWatchHttp requestDialsID:id_str IsFree:YES Page:1 Size:2000 Result:^(NSArray * _Nonnull info) {
                    self.watchListFree = [NSMutableArray arrayWithArray:info];
                    NSLog(@"--->Watch for free：%lu",(unsigned long)self.watchListFree.count);
                    
                    /*--- 8-2. 根据pid、vid获取手表产品信息(付费表盘) ---*/
                    [JLWatchHttp requestDialsID:id_str IsFree:NO Page:1 Size:2000 Result:^(NSArray * _Nonnull info) {
                        self.watchListPay = [NSMutableArray arrayWithArray:info];
                        NSLog(@"--->Watch for pay：%lu",(unsigned long)self.watchListPay.count);

                        
                        /*--- 加载表盘图标 ---*/
                        [JL_Tools subTask:^{
                            self.watchList = [NSMutableArray new];
                            if (self.watchListFree.count > 0) [self.watchList addObjectsFromArray:self.watchListFree];
                            if (self.watchListPay.count > 0) [self.watchList addObjectsFromArray:self.watchListPay];

                            for (NSDictionary *dict in self.watchList) {
                                NSString *name = dict[@"name"];
                                NSString *version = dict[@"version"];
                                NSString *iconUrl = dict[@"icon"];
                                
                                NSString *fileName = [NSString stringWithFormat:@"%@_%@",[name uppercaseString],version];
                                NSLog(@"Server watch --->%@ isPay:%@",fileName,dict[@"status"]);
                                NSString *filePath = [JL_Tools findPath:NSLibraryDirectory MiddlePath:kJL_WATCH_FACE File:fileName];
                                if (filePath.length  == 0) {
                                    filePath = [JL_Tools createOn:NSLibraryDirectory MiddlePath:kJL_WATCH_FACE File:fileName];
                                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]];
                                    [JL_Tools writeData:data fillFile:filePath];
                                    NSLog(@"0 --->Download watch icon:%@",fileName);
                                }
                            }
                            
                            [JL_Tools mainTask:^{
                                if (result) result();
                            }];
                            
                        }];
                    }];
                }];
                
            } else {
                /*--- 旧版本表盘API获取，无付费信息的表盘 ---*/
                NSArray *versionArray = [model.flashInfo.mFlashMatchVersion componentsSeparatedByString:@","];
                NSString *vid_str = [NSString stringWithFormat:@"%d",vid];
                NSString *pid_str = [NSString stringWithFormat:@"%d",pid];
                
                [[User_Http shareInstance] requestWatchList:pid_str WithVid:vid_str
                                                   WithPage:@"1" WithSize:@"2000"
                                               WithVersions:versionArray
                                                     Result:^(NSArray * _Nonnull info) {
                    self.watchList = [NSMutableArray arrayWithArray:info];
                    NSLog(@"--->Watch number：%lu",(unsigned long)self.watchList.count);

                    [JL_Tools subTask:^{
                        for (NSDictionary *dict in self.watchList) {
                            NSString *name = dict[@"name"];
                            NSString *version = dict[@"version"];
                            NSString *iconUrl = dict[@"icon"];
                            
                            NSString *fileName = [NSString stringWithFormat:@"%@_%@",[name uppercaseString],version];
                            NSString *filePath = [JL_Tools findPath:NSLibraryDirectory MiddlePath:kJL_WATCH_FACE File:fileName];
                            if (filePath.length  == 0) {
                                filePath = [JL_Tools createOn:NSLibraryDirectory MiddlePath:kJL_WATCH_FACE File:fileName];
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]];
                                [JL_Tools writeData:data fillFile:filePath];
                                NSLog(@"1 --->Download watch icon:%@",fileName);
                            }
                        }
                        [JL_Tools mainTask:^{
                            if (result) result();
                        }];
                    }];
                }];
            }
            
        }else{
            NSLog(@"Err: Watch info null 0.");
            if (result) result();
        }
        
    }];
}

+(NSData *)getDataOfWatchIcon:(NSString*)name{
    NSString *ver = [kJL_DIAL_CACHE getVersionOfWatch:name];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",[name uppercaseString],ver];
    NSString *filePath = [JL_Tools findPath:NSLibraryDirectory MiddlePath:kJL_WATCH_FACE File:fileName];
    
    NSData *iconData = nil;
    if (filePath.length > 0) {
        iconData = [NSData dataWithContentsOfFile:filePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    }
    return iconData;
}



@end
