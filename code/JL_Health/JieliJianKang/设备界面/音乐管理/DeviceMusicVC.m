//
//  DeviceMusicVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceMusicVC.h"
#import "TabCollectionCell.h"
#import "SongListCell.h"
#import "DMusicHandler.h"
#import "MJRefresh.h"
#import "LocalMusicVC.h"
#import "DeleteView.h"

@interface DeviceMusicVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, DMHandlerDelegate, DeleteViewDelegate, LocalMusicVCDelegate>{
    UIView *sd_1_view; //SD卡1的view
    UIView *sd_2_view; //SD卡2的view
    UILabel *sdFirstTitle; //SD卡1的Label
    UILabel *sdSecondTitle; //SD卡2的Label
    NSArray *titleArray;
    NSMutableArray *itemArray;
    uint32_t clusNow;
    DeleteView *deleteView;
    NSInteger deleteRow; //删除指定的歌曲
    __weak IBOutlet NSLayoutConstraint *titleHeight;
}
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UICollectionView *TabCollectView;
@property (weak, nonatomic) IBOutlet UITableView *FileTableView;
@property (weak, nonatomic) IBOutlet UIView *nullView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIButton *addMusicBtn;

@end

@implementation DeviceMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[DMusicHandler sharedInstance] setType:0];
    [self addNote];
    [self initUI];
    
    if (deleteView) {
        [deleteView removeFromSuperview];
    }
    deleteView = [[DeleteView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    deleteView.titleLab.numberOfLines = 1;
    deleteView.type = 0;
    deleteView.delegate = self;
    deleteView.titleLab.text = kJL_TXT("是否删除所选歌曲");
    [self.view addSubview:deleteView];
    deleteView.hidden = YES;
}

- (void)backBtnAction:(id)sender {
    [self removeNote];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateMusicState{

    JLModel_Device *currentModel = [kJL_BLE_CmdManager outputDeviceModel];
    if(currentModel.playStatus == JL_MusicStatusPause){
        [self.FileTableView reloadData];
    }
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"playStatus" Action:@selector(updateMusicState) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)dealloc{
    [self removeNote];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {
       [self backBtnAction:nil];
    }
}


-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    self.tipsLab.text = kJL_TXT("空文件夹");
    
    [[DMusicHandler sharedInstance] setDelegate:self];
    if (kJL_BLE_EntityM) {
        [[DMusicHandler sharedInstance] setNowEntity:kJL_BLE_EntityM];
    }
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    fl.minimumLineSpacing = 0;
    fl.minimumInteritemSpacing = 0;
    self.TabCollectView.collectionViewLayout = fl;
    self.TabCollectView.delegate = self;
    self.TabCollectView.dataSource = self;
    [self.TabCollectView registerNib:[UINib nibWithNibName:@"TabCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"TabCollectionCell"];
    [self.TabCollectView setShowsHorizontalScrollIndicator:NO];
    
    self.FileTableView.delegate = self;
    self.FileTableView.dataSource = self;
    self.FileTableView.rowHeight = 50;
    self.FileTableView.tableFooterView = [UIView new];
    self.FileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (self->itemArray.count > 0) {
            [[DMusicHandler sharedInstance] requestModelBy:20];
        } else {
            [weakSelf loadModeData];
            [self.FileTableView.mj_footer endRefreshing];
        }
    }];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:kJL_TXT("松手开始加载") forState:MJRefreshStatePulling];
    [footer setTitle:kJL_TXT("加载中...") forState:MJRefreshStateRefreshing];
    self.FileTableView.mj_footer = footer;
    
    _titleLab.text = kJL_TXT("音乐管理");
    
    [self loadModeData];
    
    [self.addMusicBtn setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
    [self.addMusicBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [self.addMusicBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    [self.addMusicBtn setBackgroundColor:[UIColor clearColor]];
    //[self.addMusicBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    self.addMusicBtn.layer.cornerRadius = self.addMusicBtn.height / 2;
}

- (void)loadModeData {
    NSArray *suportArray = self.devel.cardArray;
    switch (self.type) {
        case JLDeviceMusicVCTypeUSB:{//USB
            [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeUSB];
        }break;
        case JLDeviceMusicVCTypeSD:{//SD card
            if([suportArray containsObject:@(JL_CardTypeSD_0)]){
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
            }else if ([suportArray containsObject:@(JL_CardTypeSD_1)]){
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_1];
            }else if ([suportArray containsObject:@(JL_CardTypeSD_0)]&&[suportArray containsObject:@(JL_CardTypeSD_1)]){
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
                [self initWithTitile];
            }
        }break;
            
        default:
            break;
    }
}


-(void)initWithTitile{
    //SD卡0和SD卡1同时存在
    sdFirstTitle = [[UILabel alloc] init];
    sdFirstTitle.frame = CGRectMake(118.5,_headView.frame.size.height/2+17/2,55,17);
    sdFirstTitle.numberOfLines = 0;
    [self.view addSubview:sdFirstTitle];
    
    NSMutableAttributedString *sdFirstStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    sdFirstTitle.attributedText = sdFirstStr;
    
    UITapGestureRecognizer *sdFirstRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sdFirstClick)];
    [sdFirstTitle addGestureRecognizer:sdFirstRecognizer];
    sdFirstTitle.userInteractionEnabled=YES;
    
    sd_1_view = [[UIView alloc] init];
    sd_1_view.frame = CGRectMake(sdFirstTitle.frame.origin.x+8.5,sdFirstTitle.frame.origin.y+sdFirstTitle.frame.size.height+8.5,35,3);
    sd_1_view.backgroundColor = [UIColor colorWithRed:134/255.0 green:101/255.0 blue:243/255.0 alpha:1.0];
    sd_1_view.layer.cornerRadius = 1.5;
    [self.view addSubview:sd_1_view];
    
    sdSecondTitle = [[UILabel alloc] init];
    sdSecondTitle.frame = CGRectMake(sdFirstTitle.frame.origin.x+sdFirstTitle.frame.size.width+44,_headView.frame.size.height/2+17/2,55,17);
    sdSecondTitle.numberOfLines = 0;
    [self.view addSubview:sdSecondTitle];
    
    NSMutableAttributedString *sdSecondStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:0.7]}];
    
    sdSecondTitle.attributedText = sdSecondStr;
    
    UITapGestureRecognizer *sdSecondTitleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sdSecondClick)];
    [sdSecondTitle addGestureRecognizer:sdSecondTitleRecognizer];
    sdSecondTitle.userInteractionEnabled=YES;
    
    sd_2_view = [[UIView alloc] init];
    sd_2_view.frame = CGRectMake(sdSecondTitle.frame.origin.x+8.5,sdSecondTitle.frame.origin.y+sdSecondTitle.frame.size.height+8.5,35,3);
    sd_2_view.backgroundColor = [UIColor colorWithRed:134/255.0 green:101/255.0 blue:243/255.0 alpha:1.0];
    sd_2_view.layer.cornerRadius = 1.5;
    [self.view addSubview:sd_2_view];
    sd_2_view.hidden = YES;
}

- (IBAction)backBtnFunc:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sdFirstClick{
    sd_1_view.hidden = NO;
    sd_2_view.hidden = YES;
    
    NSMutableAttributedString *sdFirstStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    sdFirstTitle.attributedText = sdFirstStr;
    
    NSMutableAttributedString *sdSecondStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:0.7]}];
    
    sdSecondTitle.attributedText = sdSecondStr;
    self.type = JLDeviceMusicVCTypeSD;
    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
}

-(void)sdSecondClick{
    sd_1_view.hidden = YES;
    sd_2_view.hidden = NO;
    
    NSMutableAttributedString *sdFirstStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    sdSecondTitle.attributedText = sdFirstStr;
    NSMutableAttributedString *sdSecondStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:0.7]}];
    sdFirstTitle.attributedText = sdSecondStr;
    self.type = JLDeviceMusicVCTypeUnknown;
    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_1];
}

- (IBAction)addMusicBtnFunc:(id)sender {
    LocalMusicVC *vc = [[LocalMusicVC alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
    
}

#pragma mark ///CollectionView delegate
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TabCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TabCollectionCell" forIndexPath:indexPath];
    if (titleArray.count == 1 || indexPath.row == (titleArray.count-1)) {
        cell.nextImgv.hidden = YES;
    }else{
        cell.nextImgv.hidden = NO;
    }
    JLModel_File *model = titleArray[indexPath.row];
    cell.titleLab.text = model.folderName;
    cell.titleLab.textColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1];
    if (indexPath.row == titleArray.count-1 && titleArray.count != 1) {
        cell.titleLab.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1];
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(titleArray!=nil && titleArray.count>indexPath.row){
        JLModel_File *model = titleArray[indexPath.row];
        [[DMusicHandler sharedInstance] tabArraySelect:model];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_File *model = titleArray[indexPath.row];
    CGFloat width = [self getWidthWithText:model.folderName height:46 font:14]+15;
    return CGSizeMake(width, 46);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return titleArray.count;
}

#pragma mark ///TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SongListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songListCell"];
    if (cell == nil) {
        cell = [[SongListCell alloc] init];
        cell.songName.frame = CGRectMake(53,cell.frame.size.height/2-15, [UIScreen mainScreen].bounds.size.width-80, 20);
        cell.artistLab.hidden = YES;
        cell.numberLab.hidden = YES;
    }
    
    JLModel_File *model = itemArray[indexPath.row];
    if(model.fileType ==JL_BrowseTypeFile){
        cell.songName.text = [NSString stringWithFormat:@" %@",model.fileName];
    }
    cell.songName.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
    if (model.fileType == JL_BrowseTypeFolder) {
        //cell.animateImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_file"];
    }else{

        JLModel_Device *currentModel = [kJL_BLE_CmdManager outputDeviceModel];
        if (model.fileClus == currentModel.currentClus) {
            cell.songName.textColor = kColor_0000;
            cell.animateImgv.animationImages = @[[UIImage imageNamed:@"Theme.bundle/list_play_01"],
                                               [UIImage imageNamed:@"Theme.bundle/list_play_02"],
                                               [UIImage imageNamed:@"Theme.bundle/list_play_03"],
                                               [UIImage imageNamed:@"Theme.bundle/list_play_04"]];
            cell.animateImgv.animationDuration = 0.7;
            cell.animateImgv.animationRepeatCount = 0;
            if(currentModel.playStatus == JL_MusicStatusPlay){
                [cell.animateImgv startAnimating];
            }
            
            if(currentModel.playStatus == JL_MusicStatusPause || currentModel.currentFunc == JL_FunctionCodeBT
               || currentModel.currentFunc == JL_FunctionCodeLINEIN){
                [cell.animateImgv stopAnimating];
                [cell.animateImgv setImage:[UIImage imageNamed:@"Theme.bundle/list_play_01"]];
            }
        }else{
            [cell.animateImgv stopAnimating];
            cell.animateImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_music"];//文件
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(itemArray!=nil && itemArray.count>indexPath.row){
        JLModel_File *model = itemArray[indexPath.row];
        [[DMusicHandler sharedInstance] requestWith:model Number:20];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kJL_TXT("删除");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    deleteView.hidden = NO;
    deleteRow = indexPath.row;
}

#pragma mark ///数据返回
-(void)dmHandleWithPlayItemOK{
    [self.FileTableView reloadData];
}
-(void)dmHandleWithTabTitleArray:(NSArray<JLModel_File *> *)modelA{
    titleArray = modelA;
    [self.TabCollectView reloadData];
    if (titleArray.count>0) {
        [self.TabCollectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:titleArray.count-1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:YES];
    }
}
- (void)dmHandleWithItemModelArray:(NSArray<JLModel_File *> *)modelB {

    for (JLModel_File *model in modelB) {
        if ([model.fileName.lowercaseString isEqualToString:@"download"]) {
            [JL_Tools mainTask:^{
                [[DMusicHandler sharedInstance] requestWith:model Number:20];
            }];
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [JL_Tools mainTask:^{
        NSMutableArray *finalArray = [NSMutableArray array];
        for (JLModel_File *model in modelB) {
            if (model.fileType == JL_BrowseTypeFile) {
                [finalArray addObject:model];
            }
        }
        [weakSelf.FileTableView.mj_footer endRefreshing];
        self->itemArray = [finalArray mutableCopy];
        if (self->itemArray.count > 0) {
            weakSelf.nullView.hidden = YES;
        } else {
            weakSelf.nullView.hidden = NO;
        }
        [weakSelf.FileTableView reloadData];
    }];
}
- (void)dmLoadFailed:(DM_ERROR)err{
    switch (err) {
        case DM_ERROR_Max_Fold:{
            [DFUITools showText:kJL_TXT("超出可读层级") onView:self.view delay:2];
        }break;
            
        default:
            break;
    }
}
- (void)dmCardMessageDismiss:(NSArray *)nowArray{
    if ([nowArray containsObject:@(self.type)]) {
        if (self.type == 1) {
            if ([nowArray containsObject:@(JL_CardTypeSD_0)]&&[nowArray containsObject:@(JL_CardTypeSD_1)]){
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
                if (!sd_1_view) {
                    [self initWithTitile];
                }else{
                    sd_1_view.hidden = NO;
                    sd_2_view.hidden = NO;
                    _titleLab.hidden = YES;
                }
            }else{
                if (sd_1_view) {
                    sd_1_view.hidden = YES;
                    sd_2_view.hidden = YES;
                }
                if([nowArray containsObject:@(JL_CardTypeSD_0)]){
                    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
                }else if ([nowArray containsObject:@(JL_CardTypeSD_1)]){
                    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_1];
                }
            }
        }
    }else{
        [self backBtnAction:nil];
    }
}

#pragma mark - LocalMusicVCDelegate

- (void)transferAllMusicFinish {
    /*--- 清除设备音乐缓存 ---*/

    [kJL_BLE_CmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_0];
    [kJL_BLE_CmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_1];
    
    [self loadModeData];
}

#pragma mark 删除指定的歌曲
-(void)deleteMySongs:(NSInteger) row{
    if(itemArray!=nil && itemArray.count>row){
        JLModel_File *model = itemArray[row];
        [itemArray removeObjectAtIndex:row];

        [JL_Tools subTask:^{
            [kJL_BLE_CmdManager.mFileManager cmdDeleteFileModels:@[model]];
            [JL_Tools mainTask:^{
                [DFUITools showText:kJL_TXT("删除成功") onView:self.view delay:1.0];
                

                [kJL_BLE_CmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_0];
                [kJL_BLE_CmdManager.mFileManager cmdCleanCacheType:JL_CardTypeSD_1];
                
                [self loadModeData];
            }];
        }];
    }
}

-(void)didCancelAction:(UIButton *)btn{
    
}

-(void)didDeleteAction:(UIButton *)btn{
    [self deleteMySongs:deleteRow];
}
@end
