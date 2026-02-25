//
//  WatchOwn.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2022/5/12.
//

#import "WatchOwn.h"
#import "WatchCell.h"
#import "JLUI_Effect.h"
#import "WatchMarket.h"
#import "MJRefresh.h"
#import "WatchLocalModel.h"
#import "JLWatchHttp.h"
#import "UIImageView+WebCache.h"

#import "DialModel.h"
#import "DialDetailVC.h"
#import "CustomWatchVC.h"
#import "WatchMoreVC.h"

NSString *kUI_WATCH_OWN_OPERATION = @"UI_WATCH_OWN_OPERATION";
NSString *kUI_WATCH_OWN_MORE = @"UI_WATCH_OWN_MORE";

@interface WatchOwn()<UICollectionViewDelegate,UICollectionViewDataSource,WatchCellDelegate>{
    BOOL                isManager;
    UIButton            *btnManager;
    UIButton            *btnMore;
    BOOL                mIsEdit;
    
    UICollectionView    *subCollectView;
    DFHttp1             *http1;
    //DialUICache         *mDialUICache;
    
    UIWindow            *win;
    
    UILabel *label;
    
    CGFloat width;
    CGFloat height;
}
@property(strong,nonatomic)NSMutableArray <WatchLocalModel*>*dataArray;
@end

@implementation WatchOwn

- (instancetype)initByFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.frame = frame;
        
        mIsEdit = NO;

        win   = [DFUITools getWindow];
        width = frame.size.width;
        height= frame.size.height;
        
        [self setupUI];
        
        
        isManager = NO;
        http1 = [[DFHttp1 alloc] init];
        [self setUIManager:isManager];
        
    }
    return self;
}




-(void)setupUI{
    label = [[UILabel alloc] init];
    label.frame = CGRectMake(20,10,self.frame.size.width,22);
    label.numberOfLines = 0;
    [self addSubview:label];

    UIFont *font = [UIFont fontWithName:@"PingFang SC" size: 16];
    UIColor *color = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("本地表盘") attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
    
    label.attributedText = string;
    label.textAlignment = NSTextAlignmentLeft;
    label.alpha = 1.0;
    
    
    btnManager = [[UIButton alloc] init];
    btnManager.frame = CGRectMake(width-80.0, 10, 80.0, 22);
    btnManager.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnManager addTarget:self action:@selector(btn_isManager:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnManager];
    
    btnMore = [[UIButton alloc] init];
    btnMore.frame = CGRectMake(width-80.0, 10, 80.0, 22);
    btnMore.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnMore setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnMore addTarget:self action:@selector(btn_More:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnMore];
    
    
    
    CGFloat itemW = 110.0;
    CGFloat itemH = itemW+40.0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    CGRect rect = CGRectMake(0, 40, width, height - 40);
    subCollectView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    subCollectView.backgroundColor = [UIColor clearColor];
    subCollectView.delegate = self;
    subCollectView.dataSource = self;
    subCollectView.alwaysBounceVertical = YES;
    subCollectView.showsVerticalScrollIndicator = NO;
    [subCollectView setMj_header:[MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWatchData)]];
    
    UINib *nib = [UINib nibWithNibName:@"WatchCell" bundle:nil];
    [subCollectView registerNib:nib forCellWithReuseIdentifier:@"WatchCell"];
    [self addSubview:subCollectView];
}


-(void)setSuperVC:(UIViewController *)superVC{
    
    _superVC = superVC;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WatchLocalModel *md = self.dataArray[indexPath.row];
    
    WatchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WatchCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.subIndex = indexPath.row;
    cell.delegate = self;
    
    cell.subLabel.text = md.mName;
    cell.subLabel_1.hidden = YES;
    
    UIImage *phimage = [UIImage imageNamed:@"watch_img_05"];
    if (md.mInfoDict && md.mInfoDict[@"icon"]) {
        [cell.subImageView sd_setImageWithURL:[NSURL URLWithString:md.mInfoDict[@"icon"]] placeholderImage:phimage];
    }else{
        NSData *imgData = [WatchMarket getDataOfWatchIcon:md.mName];
        if (imgData) {
            cell.subImageView.image = [UIImage imageWithData:imgData];
        }else{
            cell.subImageView.image = phimage;
        }
    }

    NSString *watchName = [kJL_DIAL_CACHE currentWatchName];
    if (md.mWatchType == WatchLocalTypeInDevice) {
        if ([md.mName isEqual:watchName]) {
            cell.subType = WatchCellTypeUsed;   //正在使用
            if (mIsEdit == YES) {//是否可编辑
                cell.subEditBtn.hidden = NO;
            }else{
                cell.subEditBtn.hidden = YES;
            }
        }else{
            cell.subType = WatchCellTypeUnUsed;   //可以使用
            cell.subEditBtn.hidden = YES;
        }
    }

    
    /*--- 需要更新 ---*/
    if (md.mWatchType == WatchLocalTypeUpdate) {
        cell.subType = WatchCellTypeUpdate;
    }
    /*--- 需要下载 ---*/
    if (md.mWatchType == WatchLocalTypeDownload) {
        cell.subType = WatchCellTypeDownload;
    }
    
    /*--- 需要购买 ---*/
    if (md.mWatchType == WatchLocalTypePay){
        cell.subType = WatchCellTypePay;
        cell.buyPrice= (float)([md.mInfoDict[@"price"] floatValue]/100.0);
    }
    
    if (isManager) {
        cell.subDeleteBtn.hidden = NO;
    }else{
        cell.subDeleteBtn.hidden = YES;
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}


#pragma mark - cellDelegate
-(void)onWatchCell:(WatchCell *)cell didSelectIndex:(NSInteger)index{
    if (isManager == YES) return;
    
    WatchLocalModel *md = self.dataArray[index];
    
    NSLog(@"Cell Select ---> %ld",(long)index);
    if (cell.subType == WatchCellTypeUnUsed) {
        [self setWatchFace:md.mName];
    }
    if (cell.subType == WatchCellTypeUpdate) {
        [self updateWatch:md];
    }
    if (cell.subType == WatchCellTypeDownload) {
        
        /*--- 审核测试 ---*/
        UserProfile *pf = [[User_Http shareInstance] userPfInfo];
        if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
            [pf.email isEqual:kStoreIAP_MOBILE]) {
            [DFUITools showText:@"已购买" onView:win delay:1.0];
            [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
            return;
        }
        
        [self addWatch:md];
    }
    if (cell.subType == WatchCellTypePay) {
        
        DialModel *model = [DialModel new];
        model.dict = md.mInfoDict;
        model.iconUrl = md.mInfoDict[@"icon"];                                  //表盘小图片
        model.bigIconUrl = md.mInfoDict[@"icon"];                               //表盘大图片
        model.watchName  = md.mInfoDict[@"name"];                               //表盘名字
        model.mPrice     = (float)([md.mInfoDict[@"price"] floatValue]/100.0);  //价格
        model.dialIntroduce  = @"杰理智能手表表盘";                                //表盘简介
        
        DialDetailVC *vc = [[DialDetailVC alloc] init];
        vc.dialModel = model;
        vc.modalPresentationStyle = 0;
        [self.superVC presentViewController:vc animated:YES completion:nil];
    }
    
}

-(void)onWatchCell:(WatchCell *)cell didEditIndex:(NSInteger)index{
    WatchLocalModel *md = self.dataArray[index];

    CustomWatchVC *vc = [[CustomWatchVC alloc] init];
    vc.watchName = md.mName;
    vc.modalPresentationStyle = 0;
    [self.superVC presentViewController:vc animated:YES completion:nil];
}



#pragma mark - 更新表盘
-(void)updateWatch:(WatchLocalModel*)md{
    [JLUI_Effect startLoadingView:kJL_TXT("更新表盘...") Delay:60.0*10];

    NSDictionary *infoDict = md.mInfoDict;
    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *version = infoDict[@"version"];
    NSString *id_str = infoDict[@"id"];
    
    
    if (kJL_DIAL_CACHE.isSupportPayment) {
        /*--- 8-6. 查询表盘下载链接，并下载表盘 ---*/
        [JLWatchHttp getDialDownloadUrlWithID:id_str Result:^(NSDictionary * _Nonnull info) {
            
            if (![info[@"data"] isEqual:[NSNull null]] && info) {
                NSString *url = info[@"data"][@"url"];
                
                NSString *path = [DialUICache getUpgradeFileName:name Version:version];
                if (path == nil) {
                    path = [DialUICache listUpgradeFileName:name Version:version];
                    NSLog(@"Replace-->%@ %@ Url:%@",name,version,url);
                    
                    [self replaceAndDownloadUrl:url Path:path Name:name Version:version Watch:md];
                }else{
                    /*--- 更新表盘 ---*/
                    [self onFatsReplaceResource:md];
                }
            }else{
                NSLog(@"Err: Watch Url null");
                [JL_Tools mainTask:^{
                    [JLUI_Effect removeLoadingView];
                }];
            }
        }];
    } else {
        /*--- 没有支付信息的表盘【更新】 ---*/
        NSString *path = [DialUICache getUpgradeFileName:name Version:version];
        if (path == nil) {
            
            NSString *url = infoDict[@"url"];
            path = [DialUICache listUpgradeFileName:name Version:version];
            NSLog(@"Replace 1 -->%@ %@ Url:%@",name,version,url);
            
            [self replaceAndDownloadUrl:url Path:path Name:name Version:version Watch:md];
        }else{
            /*--- 更新表盘 ---*/
            [self onFatsReplaceResource:md];
        }
    }
}



-(void)onFatsReplaceResource:(WatchLocalModel*)md{
    
    NSDictionary *infoDict = md.mInfoDict;
    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *version = infoDict[@"version"];
    
    NSString *wName = [NSString stringWithFormat:@"/%@",name];
    NSString *path = [DialUICache getUpgradeFileName:name Version:version];
    NSData *pathData = [NSData dataWithContentsOfFile:path];
    NSLog(@"-->更新的表盘大小:%lld",(long long)pathData.length);
    
    
    if (pathData == 0) {
        NSLog(@"--->Replace 表盘文件是空的。");
        [DFUITools showText:kJL_TXT("更新失败") onView:win delay:1.0];
        return;
    }
    
    [DialManager repaceFile:wName Content:pathData
                     Result:^(DialOperateType type, float progress)
    {
        if (type == DialOperateTypeNoSpace) {
            [JLUI_Effect setLoadingText:kJL_TXT("空间不足") Delay:0.5];
        }

        if (type == DialOperateTypeDoing) {
            NSString *txt = [NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("更新进度"),progress*100.0f];
            [JLUI_Effect setLoadingText:txt];
        }
        
        if (type == DialOperateTypeFail) {
            [JLUI_Effect setLoadingText:kJL_TXT("更新失败") Delay:0.5];
        }
        
        if (type == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("更新完成") Delay:0.5];

            /*--- 更新缓存 ---*/
            [kJL_DIAL_CACHE addVersion:version toWatch:name];

            NSString *ver= [version stringByReplacingOccurrencesOfString:@"W" withString:@""];
            int ver_num = [ver intValue];

            /*--- 更新model对应值，以便更新UI ---*/
            md.mVersionStr = version;
            md.mVersionNum = ver_num;
            md.mWatchType = WatchLocalTypeInDevice;//将model置零
            [self->subCollectView reloadData];
            
            [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
            
            [JL_Tools delay:1.0 Task:^{
                [self setWatchFace:md.mName];
            }];
        }
    }];
}


#pragma mark - 增加表盘
-(void)addWatch:(WatchLocalModel*)md{
    [JLUI_Effect startLoadingView:kJL_TXT("添加表盘...") Delay:60.0*10];

    NSDictionary *infoDict = md.mInfoDict;
    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *version = infoDict[@"version"];
    NSString *id_str = infoDict[@"id"];
    
    
    if (kJL_DIAL_CACHE.isSupportPayment){
        /*--- 8-6. 查询表盘下载链接，并下载表盘 ---*/
        [JLWatchHttp getDialDownloadUrlWithID:id_str Result:^(NSDictionary * _Nonnull info) {
            
            if (![info[@"data"] isEqual:[NSNull null]] && info) {
                NSString *url = info[@"data"][@"url"];
                
                NSString *path = [DialUICache getUpgradeFileName:name Version:version];
                if (path == nil) {
                    path = [DialUICache listUpgradeFileName:name Version:version];
                    NSLog(@"Add-->%@ %@ Url:%@",name,version,url);
                
                    [self addAndDownloadUrl:url Path:path Name:name Version:version Watch:md];
                }else{
                    /*--- 添加表盘 ---*/
                    [self onFatsAddResource:md];
                }
            }else{
                NSLog(@"Err: Watch Url null");
                [JL_Tools mainTask:^{
                    [JLUI_Effect removeLoadingView];
                }];
            }
        }];
    }else{
        
        /*--- 没有支付信息的表盘【新增】 ---*/
        NSString *path = [DialUICache getUpgradeFileName:name Version:version];
        if (path == nil) {
            
            NSString *url = infoDict[@"url"];
            path = [DialUICache listUpgradeFileName:name Version:version];
            NSLog(@"Add-->%@ %@ Url:%@",name,version,url);
            
            [self addAndDownloadUrl:url Path:path Name:name Version:version Watch:md];
        }else{
            /*--- 添加表盘 ---*/
            [self onFatsAddResource:md];
        }
    }
    

}

-(void)onFatsAddResource:(WatchLocalModel*)md{
    NSDictionary *infoDict = md.mInfoDict;
    NSString *name = [infoDict[@"name"] uppercaseString];
    NSString *version = infoDict[@"version"];
    
    NSString *wName = [NSString stringWithFormat:@"/%@",name];
    NSString *path = [DialUICache getUpgradeFileName:name Version:version];
    NSData *pathData = [NSData dataWithContentsOfFile:path];
    NSLog(@"-->添加表盘的大小:%lld",(long long)pathData.length);
    
    if (pathData == 0) {
        NSLog(@"--->Add 表盘文件是空的。");
        [DFUITools showText:kJL_TXT("更新失败") onView:win delay:1.0];
        return;
    }
    
    [DialManager addFile:wName Content:pathData
                  Result:^(DialOperateType type, float progress)
    {
        if (type == DialOperateTypeNoSpace) {
            [JLUI_Effect setLoadingText:kJL_TXT("空间不足") Delay:0.5];
        }
        if (type == DialOperateTypeFail) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加失败") Delay:0.5];
        }
        if (type == DialOperateTypeDoing) {
            NSString *txt = [NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("添加进度"),progress*100.0f];
            [JLUI_Effect setLoadingText:txt];
        }
        if (type == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("添加完成") Delay:0.5];

            /*--- 更新缓存 ---*/
            [kJL_DIAL_CACHE addWatchListObject:name];
            [kJL_DIAL_CACHE addVersion:version toWatch:name];

            [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];

            [JL_Tools delay:1.0 Task:^{
                [self setWatchFace:md.mName];
            }];
        }
    }];
}




#pragma mark - 删除表盘
-(void)onWatchCell:(WatchCell *)cell didDeleteIndex:(NSInteger)index{
    
    /*--- 测试删除购买记录 ---*/
    if (_mWatchUiType == WatchUITypeHistory) {
        
//        if (self.dataArray.count <= 2) {
//            [DFUITools showText:kJL_TXT("至少保留2个表盘") onView:win delay:1.0];
//            return;
//        }
                
        WatchLocalModel *md = self.dataArray[index];
        NSString *shopID = md.mInfoDict[@"id"];
        
        [JLWatchHttp requestPayRecordPage:1 Size:200 Result:^(NSArray * _Nonnull info) {
            
            NSString * recordId = nil;
            for (NSDictionary *dict in info) {
                NSString *spID = dict[@"shopid"];
                if ([spID isEqual:shopID]) {
                    recordId = dict[@"id"];
                    break;
                }
            }
            if (recordId.length == 0) return;
            
            [JLWatchHttp deleteHistoryDialRecordID:recordId Result:^(NSDictionary * _Nonnull info) {
                [JL_Tools mainTask:^{
                    if (![info[@"data"] isEqual:[NSNull null]] && info ) {
                        BOOL isPay = [info[@"data"] boolValue];
                        if (isPay == YES) {
                            /*--- 刷新服务器 ---*/
                            [[WatchMarket sharedMe] searchAllWatchResult:^{
                                [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
                            }];
                        }
                    }
                }];
            }];
        }];
  
        return;
    }
    

    int watchLastNum = 0;
    for (WatchLocalModel *md in self.dataArray) {
        if (md.mWatchType == WatchLocalTypeInDevice) {
            watchLastNum++;
        }
    }
    if (watchLastNum <= 2) {
        [DFUITools showText:kJL_TXT("至少保留2个表盘") onView:win delay:1.0];
        return;
    }
    
    
    WatchLocalModel *md = self.dataArray[index];
    NSString *name = md.mName;
    NSString *wName = [NSString stringWithFormat:@"/%@",name];
    
    
    [JLUI_Effect startLoadingView:kJL_TXT("删除表盘") Delay:60.0];
    NSLog(@"Cell Delete ---> %ld",(long)index);
    
    [DialManager deleteFile:wName Result:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeFail) {
            [JLUI_Effect setLoadingText:kJL_TXT("删除失败") Delay:0.5];
        }
        if (type == DialOperateTypeSuccess) {
            [JLUI_Effect setLoadingText:kJL_TXT("删除完成") Delay:0.5];
            
            /*--- 更新缓存 ---*/
            [kJL_DIAL_CACHE removeWatchListObject:name];
            [kJL_DIAL_CACHE removeVersionOfWatch:name];

            [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
        }
    }];
}

#pragma mark - 切换表盘
-(void)setWatchFace:(NSString*)face{

    NSString *path = [NSString stringWithFormat:@"/%@",face];
    
    [kJL_BLE_CmdManager.mFlashManager cmdWatchFlashPath:path Flag:JL_DialSettingSetDial
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            if (flag == 0) {
                [kJL_DIAL_CACHE setCurrrentWatchName:face];
                [self->subCollectView reloadData];
                
                [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
            }
        }];
    }];
}

#pragma mark - 表盘下载并替换
-(void)replaceAndDownloadUrl:(NSString*)url
                        Path:(NSString*)path
                        Name:(NSString*)name
                     Version:(NSString*)version
                       Watch:(WatchLocalModel*)md
{
    [[User_Http shareInstance] downloadUrl:url Path:path Result:^(float progress, JLHTTP_Result result) {
        [JL_Tools mainTask:^{
            if (result == JLHTTP_ResultDownload) {
                /*--- 下载文件中 ---*/
                NSString *txt = [NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("下载"),progress*100.0f];
                [JLUI_Effect setLoadingText:txt];
            }
            if (result == JLHTTP_ResultSuccess) {
                /*--- 更新表盘 ---*/
                [self onFatsReplaceResource:md];
            }
            if (result == JLHTTP_ResultFail) {
                NSLog(@"-->删除下载失败的表盘：%@ %@",name,version);
                [DFUITools showText:kJL_TXT("服务器开小差") onView:self->win delay:1.0];
                [JL_Tools removePath:path];
            }
        }];
    }];
}

#pragma mark - 表盘下载并新增
-(void)addAndDownloadUrl:(NSString*)url
                    Path:(NSString*)path
                    Name:(NSString*)name
                 Version:(NSString*)version
                   Watch:(WatchLocalModel*)md
{
    [[User_Http shareInstance] downloadUrl:url Path:path Result:^(float progress, JLHTTP_Result result) {
        [JL_Tools mainTask:^{
            if (result == JLHTTP_ResultDownload) {
                /*--- 下载文件中 ---*/
                NSString *txt = [NSString stringWithFormat:@"%@:%.1f%%",kJL_TXT("下载"),progress*100.0f];
                [JLUI_Effect setLoadingText:txt];
            }
            if (result == JLHTTP_ResultSuccess) {
                /*--- 添加表盘 ---*/
                [self onFatsAddResource:md];

            }
            if (result == JLHTTP_ResultFail) {
                NSLog(@"-->删除下载失败的表盘：%@ %@",name,version);
                [DFUITools showText:kJL_TXT("服务器开小差") onView:self->win delay:1.0];
                [JL_Tools removePath:path];
            }
        }];
    }];
}


#pragma mark - 加载数据
-(void)refreshWatchData{
    [[WatchMarket sharedMe] searchAllWatchResult:^{
        [JL_Tools post:kUI_WATCH_OWN_OPERATION Object:nil];
    }];
    [subCollectView.mj_header endRefreshing];
}



/*
    加载：服务器免费表盘。
 */
- (NSInteger)reloadMyWatchForFree:(int)count{
    NSArray *watchsOfServer = [[WatchMarket sharedMe] watchListFree];
    [self reloadShopWatch:watchsOfServer Count:count];
    return self.dataArray.count;
}

/*
    加载：服务器付费表盘。
 */
- (NSInteger)reloadMyWatchForPay:(int)count{
    NSArray *watchsOfServer = [[WatchMarket sharedMe] watchListPay];
    [self reloadShopWatch:watchsOfServer  Count:count];
    return self.dataArray.count;
}

-(void)reloadShopWatch:(NSArray*)watchsOfServer Count:(int)count{
    self.dataArray = [NSMutableArray new];
    NSArray *watchsOfDevice = [kJL_DIAL_CACHE getWatchList];
    
    for (NSDictionary *dict in watchsOfServer) {

        NSString *name = [dict[@"name"] uppercaseString];
        NSString *versionOfServer = dict[@"version"];
        versionOfServer = [versionOfServer stringByReplacingOccurrencesOfString:@"W" withString:@""];
        int ver_server = [versionOfServer intValue];

        
        if ([watchsOfDevice containsObject:name]) {
            /*--- 且存在于设备 ---*/
            NSString *versionOfDevice = [kJL_DIAL_CACHE getVersionOfWatch:name];
            versionOfDevice = [versionOfDevice stringByReplacingOccurrencesOfString:@"W" withString:@""];
            int ver_device = [versionOfDevice intValue];
            
            WatchLocalModel *md = [WatchLocalModel new];
            md.mVersionStr = versionOfDevice;
            md.mVersionNum = ver_device;
            md.mName       = name;
            md.mInfoDict   = dict;
            md.mWatchType  = WatchLocalTypeInDevice;
            
            if (ver_server > ver_device) {
                md.mWatchType  = WatchLocalTypeUpdate;
            }
            
            /*--- 限制加载个数 ---*/
            if (count == -1) {
                [self.dataArray addObject:md];
            }else{
                if (self.dataArray.count < count) {
                    [self.dataArray addObject:md];
                }else{
                    break;
                }
            }
            
        }else{
            /*--- 是否已购买 ---*/
            BOOL isPurchased = [dict[@"status"] boolValue];
            
            /*--- 不存在于设备 ---*/
            WatchLocalModel *md = [WatchLocalModel new];
            md.mVersionStr = versionOfServer;
            md.mVersionNum = ver_server;
            md.mName       = name;
            md.mInfoDict   = dict;
            
            if (isPurchased) {
                md.mWatchType = WatchLocalTypeDownload;//购买了下载
            }else{
                md.mWatchType = WatchLocalTypePay;
            }
            
            /*--- 限制加载个数 ---*/
            if (count == -1) {
                [self.dataArray addObject:md];
            }else{
                if (self.dataArray.count < count) {
                    [self.dataArray addObject:md];
                }else{
                    break;
                }
            }
        }
    }
    [subCollectView reloadData];
}

/*
    加载：设备里的所有表盘。
 */
- (NSInteger)reloadMyWatchInDevice{

    self.dataArray = [NSMutableArray new];
    
    NSArray *watchsOfDevice = [kJL_DIAL_CACHE getWatchList];
    for (NSString *name in watchsOfDevice) {
        NSString *ver = [kJL_DIAL_CACHE getVersionOfWatch:name];
        NSString *ver1= [ver stringByReplacingOccurrencesOfString:@"W" withString:@""];
        int ver_num = [ver1 intValue];
        
        WatchLocalModel *md = [WatchLocalModel new];
        md.mVersionStr = ver;
        md.mVersionNum = ver_num;
        md.mName       = name;
        md.mWatchType  = WatchLocalTypeInDevice;
        [self.dataArray addObject:md];
    }
    
    NSArray *watchsOfServer = [[WatchMarket sharedMe] watchList];
    for (NSDictionary *dict in watchsOfServer) {
        
        /*---- 过滤未购买的表盘 ----*/
        BOOL isPurchased = [dict[@"status"] boolValue];
        if (isPurchased == NO) continue;
        
        /*--- 已购买的表盘 ---*/
        NSString *name = [dict[@"name"] uppercaseString];
        NSString *version = dict[@"version"];
        
        NSString *ver1= [version stringByReplacingOccurrencesOfString:@"W" withString:@""];
        int ver_num = [ver1 intValue];
        
        int flag = 0;
        
        for (WatchLocalModel *mdOfDevice in self.dataArray) {
            NSString *nameOfDevice = mdOfDevice.mName;
            int verOfDevice = mdOfDevice.mVersionNum;
            
            if ([nameOfDevice isEqual:name]) {
                flag = 1;
                /*--- 设备原有的表盘 ---*/
                if (mdOfDevice.mWatchType == WatchLocalTypeInDevice && ver_num > verOfDevice) {
                    mdOfDevice.mInfoDict = dict;
                    mdOfDevice.mWatchType = WatchLocalTypeUpdate;
                    break;
                }
            }
        }
    }
    [subCollectView reloadData];
    return self.dataArray.count;
}

/*
    加载：购买过的表盘。
 */
- (NSInteger)reloadMyWatchInHistory{

    self.dataArray = [NSMutableArray new];
    
    NSArray *watchsOfDevice = [kJL_DIAL_CACHE getWatchList];
    NSArray *watchsOfServer = [[WatchMarket sharedMe] watchList];
    
    for (NSDictionary *dict in watchsOfServer) {
        /*---- 过滤未购买的表盘 ----*/
        BOOL isPurchased = [dict[@"status"] boolValue];
        if (isPurchased == NO) continue;
        
        /*--- 已购买的表盘 ---*/
        NSString *name = [dict[@"name"] uppercaseString];
        NSString *versionOfServer = dict[@"version"];
        versionOfServer = [versionOfServer stringByReplacingOccurrencesOfString:@"W" withString:@""];
        int ver_server = [versionOfServer intValue];

        
        if ([watchsOfDevice containsObject:name]) {
            /*--- 且存在于设备 ---*/
            NSString *versionOfDevice = [kJL_DIAL_CACHE getVersionOfWatch:name];
            versionOfDevice = [versionOfDevice stringByReplacingOccurrencesOfString:@"W" withString:@""];
            int ver_device = [versionOfDevice intValue];
            
            WatchLocalModel *md = [WatchLocalModel new];
            md.mVersionStr = versionOfDevice;
            md.mVersionNum = ver_device;
            md.mName       = name;
            md.mInfoDict   = dict;
            md.mWatchType  = WatchLocalTypeInDevice;
            
            if (ver_server > ver_device) {
                md.mWatchType  = WatchLocalTypeUpdate;
            }
            
            [self.dataArray addObject:md];
        }else{
            /*--- 不存在于设备 ---*/
            WatchLocalModel *md = [WatchLocalModel new];
            md.mVersionStr = versionOfServer;
            md.mVersionNum = ver_server;
            md.mName       = name;
            md.mInfoDict   = dict;
            md.mWatchType  = WatchLocalTypeDownload;
            [self.dataArray addObject:md];
        }
    }
    [subCollectView reloadData];
    return self.dataArray.count;
}

/*
    加载：旧版API，无购买信息的表盘。
 */
- (NSInteger)reloadMyWatchForNoPayment{
    self.dataArray = [NSMutableArray new];
    
    NSArray *watchsOfDevice = [kJL_DIAL_CACHE getWatchList];
    NSArray *watchsOfServer = [[WatchMarket sharedMe] watchList];
    
    for (NSString *name in watchsOfDevice) {
        /*--- 且存在于设备 ---*/
        NSString *versionOfDevice = [kJL_DIAL_CACHE getVersionOfWatch:name];
        versionOfDevice = [versionOfDevice stringByReplacingOccurrencesOfString:@"W" withString:@""];
        int ver_device = [versionOfDevice intValue];

        WatchLocalModel *md = [WatchLocalModel new];
        md.mVersionStr = versionOfDevice;
        md.mVersionNum = ver_device;
        md.mName = name;
        md.mWatchType = WatchLocalTypeInDevice;
        [self.dataArray addObject:md];
    }
    
    for (NSDictionary *dict in watchsOfServer) {
        
        NSString *name = [dict[@"name"] uppercaseString];
        NSString *versionOfServer = dict[@"version"];
        versionOfServer = [versionOfServer stringByReplacingOccurrencesOfString:@"W" withString:@""];
        int ver_server = [versionOfServer intValue];

        int flag = 0;
        
        for (WatchLocalModel *mdOfDevice in self.dataArray) {
            NSString *nameOfDevice = mdOfDevice.mName;
            int verOfDevice = mdOfDevice.mVersionNum;
            
            if ([nameOfDevice isEqual:name]) {
                flag = 1;
                /*--- 设备原有的表盘 ---*/
                if (mdOfDevice.mWatchType == WatchLocalTypeInDevice && ver_server > verOfDevice) {
                    mdOfDevice.mInfoDict = dict;
                    mdOfDevice.mWatchType = WatchLocalTypeUpdate;
                    break;
                }
                
                /*--- 设备原有的表盘(需要更新) ---*/
                if (mdOfDevice.mWatchType == WatchLocalTypeUpdate && ver_server > verOfDevice) {
                    NSString *ver_Update = mdOfDevice.mInfoDict[@"version"];
                    NSString *ver_Update1= [ver_Update stringByReplacingOccurrencesOfString:@"W" withString:@""];
                    int ver_Update1_num = [ver_Update1 intValue];
                    
                    if (ver_server > ver_Update1_num) {
                        mdOfDevice.mInfoDict = dict;
                        break;
                    }
                }
                
                /*--- 服务器的表盘 ---*/
                if (mdOfDevice.mWatchType == WatchLocalTypeDownload && ver_server > verOfDevice) {
                    mdOfDevice.mVersionStr = versionOfServer;
                    mdOfDevice.mVersionNum = ver_server;
                    mdOfDevice.mInfoDict = dict;
                    break;
                }
            }
        }
        
        if (flag == 0) {
            WatchLocalModel *md = [WatchLocalModel new];
            md.mVersionStr = versionOfServer;
            md.mVersionNum = ver_server;
            md.mName = name;
            md.mInfoDict = dict;
            md.mWatchType = WatchLocalTypeDownload;
            [self.dataArray addObject:md];
        }
    }
    [subCollectView reloadData];
    return self.dataArray.count;
}


#pragma mark - UI赋值
-(void)setMSubTitleText:(NSString *)mSubTitleText{
    UIFont *font = [UIFont fontWithName:@"PingFang SC" size: 16];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:mSubTitleText attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:kDF_RGBA(36, 36, 36, 1.0)}];
    label.attributedText = string;
    _mSubTitleText = mSubTitleText;
}

-(void)setMMoreBtnText:(NSString *)mMoreBtnText{
    [btnMore setTitle:mMoreBtnText forState:UIControlStateNormal];
    _mMoreBtnText = mMoreBtnText;
}


-(void)setMWatchUiType:(WatchUIType)mWatchUiType{
    if (mWatchUiType == WatchUITypeFree) {
        label.hidden = NO;
        btnManager.hidden = YES;
        btnMore.hidden = NO;
        mIsEdit = NO;
    }
    if (mWatchUiType == WatchUITypePay) {
        label.hidden = NO;
        btnManager.hidden = YES;
        btnMore.hidden = NO;
        mIsEdit = NO;
    }
    if (mWatchUiType == WatchUITypeDevice) {
        label.hidden = NO;
        btnManager.hidden = NO;
        btnMore.hidden = YES;
        mIsEdit = YES;
    }
    
    if (mWatchUiType == WatchUITypeHistory) {
        label.hidden = YES;
        btnManager.hidden = YES;
        btnMore.hidden = YES;
        mIsEdit = NO;
    }
    if (mWatchUiType == WatchUITypeNoPayment) {
        label.hidden = YES;
        btnManager.hidden = NO;
        btnMore.hidden = YES;
        mIsEdit = YES;
    }
    [subCollectView reloadData];
    _mWatchUiType = mWatchUiType;
}


- (void)btn_isManager:(id)sender {
    if (isManager == NO) {
        isManager = YES;
    }else{
        isManager = NO;
    }
    [self setUIManager:isManager];
}


-(void)setUIManager:(BOOL)is{
    if (is == YES) {
        //NSLog(@"btnManager yes.");
        [btnManager setTitle:@"" forState:UIControlStateNormal];
        [btnManager setImage:[UIImage imageNamed:@"product_icon_sure_nol"] forState:UIControlStateNormal];
    }else{
        //NSLog(@"btnManager no.");
        [btnManager setTitle:kJL_TXT("管理") forState:UIControlStateNormal];
        CGFloat width2 = [self getWidthWithText:kJL_TXT("管理") height:22 font:14]+15;
        btnManager.frame = CGRectMake(width-width2, 10, width2, 22);
        [btnManager setTitleColor:kDF_RGBA(85, 140, 255, 1) forState:UIControlStateNormal];
        [btnManager setImage:[UIImage imageNamed:@"nil"] forState:UIControlStateNormal];
    }

    [subCollectView reloadData];
}

-(void)btn_More:(UIButton*)btn{
    WatchMoreVC *vc = [[WatchMoreVC alloc] init];
    vc.modalPresentationStyle = 0;
    [self.superVC presentViewController:vc animated:YES completion:nil];
    [vc setWatchUiType:self.mWatchUiType];
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
}


@end
