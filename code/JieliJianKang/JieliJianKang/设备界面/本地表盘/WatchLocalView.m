//
//  WatchLocalView.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/22.
//

#import "WatchLocalView.h"
#import "WatchCell.h"

@interface WatchLocalView()<UICollectionViewDelegate,UICollectionViewDataSource,WatchCellDelegate,LanguagePtl>{
    UICollectionView    *subCollectView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIButton *allLabel;
}
@end

@implementation WatchLocalView

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"WatchLocalView"];
    if (self) {
        //self.backgroundColor = [UIColor blueColor];
        self.frame = frame;
        [[LanguageCls share] add:self];
        CGFloat itemW = (frame.size.width-42-32)/3;
        CGFloat itemH = itemW+45;

        self.isEdit = YES;
        
//        [allLabel setTitle:kJL_TXT("全部") forState:UIControlStateNormal];
//        titleLabel.text = kJL_TXT("本地表盘");
        
        [allLabel setTitle:kJL_TXT("更多>") forState:UIControlStateNormal];
        titleLabel.text = kJL_TXT("系统表盘");
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(itemW, itemH);
        layout.sectionInset = UIEdgeInsetsMake(0, 21, 0, 21);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 18;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 45, frame.size.width, itemH);
        
        subCollectView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        subCollectView.backgroundColor = [UIColor clearColor];
        subCollectView.delegate = self;
        subCollectView.dataSource = self;
        subCollectView.alwaysBounceHorizontal = YES;
        subCollectView.showsHorizontalScrollIndicator = NO;
        
        UINib *nib = [UINib nibWithNibName:@"WatchCell" bundle:nil];
        [subCollectView registerNib:nib forCellWithReuseIdentifier:@"WatchCell"];
        [self addSubview:subCollectView];
    }
    return self;
}
- (void)setTitleText:(NSString*)text{
    titleLabel.text = text;
}


- (IBAction)btn_AllWatch:(id)sender {
    
    /*--- 审核测试 ---*/
    UserProfile *pf = [[User_Http shareInstance] userPfInfo];
    if ([pf.mobile isEqual:kStoreIAP_MOBILE]||
        [pf.email isEqual:kStoreIAP_MOBILE]) {
        if ([_delegate respondsToSelector:@selector(onWatchLocalViewDidMoreBtn)]) {
            [_delegate onWatchLocalViewDidMoreBtn];
        }
        return;
    }
    
    if (kJL_BLE_EntityM == nil) {
        [DFUITools showText:kJL_TXT("请连设备") onView:self delay:1.0];
        return;
    }
        
    JLModel_Device *model = [kJL_BLE_CmdManager outputDeviceModel];
    uint32_t flashSize = model.flashInfo.mFlashSize;
    uint32_t fatsSize  = model.flashInfo.mFatfsSize;
    if (flashSize == 0 || fatsSize == 0) {
        [DFUITools showText:kJL_TXT("先获取FLASH信息") onView:self delay:1.0];
        return;
    }
    
    //[JL_Tools post:@"kUI_WATCH_LOCAL" Object:nil];
    
    if ([_delegate respondsToSelector:@selector(onWatchLocalViewDidMoreBtn)]) {
        [_delegate onWatchLocalViewDidMoreBtn];
    }

}

-(void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    [subCollectView reloadData];
}

-(void)setIsOperate:(BOOL)isOperate{
    _isOperate = isOperate;
    [subCollectView reloadData];
}

-(void)setIsShowLbSmall:(BOOL)isShowLbSmall{
    _isShowLbSmall = isShowLbSmall;
    [subCollectView reloadData];
}

-(void)setIsShowLbBig:(BOOL)isShowLbBig{
    _isShowLbBig = isShowLbBig;
    [subCollectView reloadData];
}


- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [subCollectView reloadData];
}

- (void)reloadViewData{
    [subCollectView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *watchTxt = self.dataArray[indexPath.row];
    
    WatchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WatchCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    cell.subIndex = indexPath.row;
    cell.subLabel.text = watchTxt;
    cell.subLabel_1.text = watchTxt;

    cell.subBtn.hidden      = YES;
    cell.subEditBtn.hidden  = YES;
    cell.subLabel.hidden    = YES;
    cell.subLabel_1.hidden  = YES;
    
    
    cell.delegate = self;
    
    NSData *iconData = [WatchMarket getDataOfWatchIcon:watchTxt];
    if (iconData.length == 0) {
        cell.subImageView.image = [UIImage imageNamed:@"watch_img_05"];
    } else {
        cell.subImageView.image = [UIImage imageWithData:iconData];
    }
    
    if (self.isEdit == YES) {
        NSString *watchName = [kJL_DIAL_CACHE currentWatchName];
        if ([watchTxt isEqual:watchName]) {
            cell.subType = WatchCellTypeUsed;
            cell.subEditBtn.hidden = NO;
        } else {
            cell.subType = WatchCellTypeUnUsed;
        }
    }else{
        cell.subEditBtn.hidden = YES;
    }
    
    if (self.isOperate) cell.subBtn.hidden = NO;
    if (self.isShowLbSmall) cell.subLabel.hidden = NO;
    if (self.isShowLbBig) cell.subLabel_1.hidden = NO;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - WatchCellDelegate

-(void)onWatchCell:(WatchCell *)cell didSelectIndex:(NSInteger)index{
    NSLog(@"Cell Select ---> %ld",(long)index);
    
    if (cell.subType == WatchCellTypeUnUsed) {
        NSString *watchTxt = self.dataArray[index];
        [self setWatchFace:watchTxt];
    }
}



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
            }
        }];
    }];
}


- (void)languageChange {
    [allLabel setTitle:kJL_TXT("更多>") forState:UIControlStateNormal];
    titleLabel.text = kJL_TXT("本地表盘");
}

@end
