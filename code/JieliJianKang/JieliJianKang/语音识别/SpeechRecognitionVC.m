//
//  SpeechRecognitionVC.m
//  JieliJianKang
//
//  Created by 李放 on 2023/7/27.
//

#import "SpeechRecognitionVC.h"
#import "AIClound.h"
#import "DeleteRecordView.h"
#import "SpeechCell.h"
#import "JYTextView.h"
#import "MJRefresh.h"
#import "AICloundMessageModel.h"
#import "JLSqliteAICloundMessageRecord.h"
#import "JL_Talk.h"
#import "JYBubbleMenuView.h"

@interface SpeechRecognitionVC () <DeleteRecordViewDelegate,UITableViewDelegate,UITableViewDataSource,SpeechCellDelegate,
AICloundDelegate>{
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIButton *deleteBtn;
    __weak IBOutlet UILabel *cancelLabel;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    float       sw;
    
    UIImageView *noRecoredImageView;
    UILabel *noRecordLabel;
        
    UITableView *listTable;
        
    NSMutableArray *selectArray; //选中的数据
    NSMutableArray *selectTimeArray;
    
    BOOL mulChooseRecords;
    
    UIView *bottomView;
    UIView *bottomLineView;
    MJRefreshNormalHeader *header;
    CGFloat targetHeight;
    
    DeleteRecordView *deleteAllRecordView;
    DeleteRecordView *selectDelectRecordView;
    
    BOOL startAI;
}

@property(strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<AICloundMessageModel *>* dataSources;
@end

@implementation SpeechRecognitionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(startAI == NO){
        [[AIClound sharedMe] loadMore:^(NSArray<AICloundMessageModel *> * _Nonnull chatMessages) {
            self.dataSources = [chatMessages mutableCopy];

            if(self.dataSources.count>0){
                self->noRecoredImageView.hidden = YES;
                self->noRecordLabel.hidden = YES;
                self->deleteBtn.hidden = NO;
                self->listTable.hidden = NO;
                [self->listTable reloadData];

                if(self.dataSources.count>2){
                    [self scrollTableToFoot:YES];
                }else {
                    [self->_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                }
            }
        }];
    }
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(255, 255, 255, 1.0);
    sw = [DFUITools screen_2_W];
    
    mulChooseRecords = NO;
    
    startAI = NO;
    
    selectArray = [NSMutableArray array];
    selectTimeArray = [NSMutableArray array];
    
    _dataSources = [NSMutableArray new];
        
    __weak typeof(self) weakSelf = self;
    
    backBtn.frame  = CGRectMake(16, kJL_HeightStatusBar, 44, 44);
    cancelLabel.frame  = CGRectMake(16, kJL_HeightStatusBar-10,
                                    44, 44);
    UITapGestureRecognizer *canceltapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelMulChoose)];
    [cancelLabel addGestureRecognizer:canceltapGestureRecognizer];
    cancelLabel.userInteractionEnabled=YES;
    cancelLabel.hidden = YES;
    
    titleHeight.constant = kJL_HeightNavBar;
    titleName.text = kJL_TXT("AI云服务");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    deleteBtn.frame  = CGRectMake([UIScreen mainScreen].bounds.size.width-50, kJL_HeightStatusBar, 100, 22);
    deleteBtn.titleLabel.hidden = YES;
    [deleteBtn addTarget:self action:@selector(deleteAllRecords:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.hidden = YES;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+10, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kJL_HeightNavBar)];
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
        
    header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.scrollView.mj_header endRefreshing];
        });
        if(self->startAI==NO){
            [[AIClound sharedMe] loadMore:^(NSArray<AICloundMessageModel *> * _Nonnull chatMessages) {
                self.dataSources = [chatMessages mutableCopy];
                
                [self->listTable reloadData];
                
                if(self.dataSources.count>2){
                    [self scrollTableToFoot:YES];
                }else {
                    [self->_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                }
            }];
        }
    }];
    [header setTitle:kJL_TXT("下拉加载更多...") forState:MJRefreshStateIdle];
    [header setTitle:kJL_TXT("松手开始加载") forState:MJRefreshStatePulling];
    [header setTitle:kJL_TXT("加载中...") forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    _scrollView.mj_header = header;
    
    CGRect rect = CGRectMake(sw/2-186/2,kJL_HeightStatusBar+150,186,186);
    noRecoredImageView = [[UIImageView alloc] initWithFrame:rect];
    noRecoredImageView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *image = [UIImage imageNamed:@"icon_no_record"];
    noRecoredImageView.image = image;
    [_scrollView addSubview:noRecoredImageView];
    noRecoredImageView.hidden = NO;

    noRecordLabel = [[UILabel alloc] init];
    noRecordLabel.frame = CGRectMake(noRecoredImageView.frame.origin.x+48,
                                     noRecoredImageView.frame.origin.y+noRecoredImageView.frame.size.height+23,sw,21);
    noRecordLabel.numberOfLines = 0;
    noRecordLabel.text = kJL_TXT("暂无对话记录");
    noRecordLabel.font =  [UIFont fontWithName:@"PingFangSC" size:18];
    noRecordLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
    [_scrollView addSubview:noRecordLabel];
    noRecordLabel.hidden = NO;

    bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height-81,[UIScreen mainScreen].bounds.size.width,1)];
    bottomLineView.backgroundColor = kDF_RGBA(0, 0, 0, 0.1);
    [self.view addSubview:bottomLineView];
    bottomLineView.hidden = YES;

    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height-80,[UIScreen mainScreen].bounds.size.width,80)];
    [self.view addSubview:bottomView];
    bottomView.hidden = YES;

    CGRect deleteSelectItemRect = CGRectMake([UIScreen mainScreen].bounds.size.width/2-22/2,4,22,22);
    UIImageView *deleteSelectImv = [[UIImageView alloc] initWithFrame:deleteSelectItemRect];
    deleteSelectImv.contentMode = UIViewContentModeScaleToFill;
    UIImage *deleteImage = [UIImage imageNamed:@"icon_delete_nol"];
    deleteSelectImv.image = deleteImage;
    [bottomView addSubview:deleteSelectImv];

    UITapGestureRecognizer *deleteSelectRecordsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSelectRecords)];
    [deleteSelectImv addGestureRecognizer:deleteSelectRecordsGestureRecognizer];
    deleteSelectImv.userInteractionEnabled = YES;

    UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-20/2,deleteSelectImv.frame.origin.y+deleteSelectImv.frame.size.height+4,20,14)];
    [bottomView addSubview:deleteLabel];
    deleteLabel.text = kJL_TXT("删除");
    deleteLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 10];
    [deleteLabel sizeToFit];

    listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kJL_HeightStatusBar)];
    listTable.tableFooterView = [UIView new];
    listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTable.allowsMultipleSelection = YES;
    listTable.dataSource = self;
    listTable.delegate = self;
    listTable.tableFooterView = [UIView new];
    [listTable setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    [_scrollView addSubview:listTable];
    listTable.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickScreen)];
    tap.cancelsTouchesInView = NO;
    [listTable addGestureRecognizer:tap];
    
    targetHeight+=[UIScreen mainScreen].bounds.size.height-kJL_HeightStatusBar;

    [_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, targetHeight)];

    AIClound *aiClound = [AIClound sharedMe];
    aiClound.aiCloundDelegate = self;
}

//选中cell时数据的相关操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(mulChooseRecords){
//        if(self.dataSources.count%2!=0){
//            [DFUITools showText:@"还没有收到AI回复,暂时不支持该操作" onView:[DFUITools getWindow] delay:1.5];
//            return;
//        }
        if(indexPath.row%2!=0){
            if(self.dataSources.count>indexPath.row){
                AICloundMessageModel *model = self.dataSources[indexPath.row];
                model.index = indexPath.row;
                if([selectArray containsObject:self.dataSources[indexPath.row]]){
                    [selectArray removeObject:model];
                }else{
                    [selectArray addObject:model];
                }
            }
            
            if(self.dataSources.count>indexPath.row-1){
                AICloundMessageModel *model2 = self.dataSources[indexPath.row-1];
                model2.index = indexPath.row+1;
                if([selectArray containsObject:self.dataSources[indexPath.row-1]]){
                    [selectArray removeObject:model2];
                }else{
                    [selectArray addObject:model2];
                }
            }
        }else{
            if(self.dataSources.count>indexPath.row){
                AICloundMessageModel *model = self.dataSources[indexPath.row];
                model.index = indexPath.row;
                if([selectArray containsObject:self.dataSources[indexPath.row]]){
                    [selectArray removeObject:model];
                }else{
                    [selectArray addObject:model];
                }
            }
            
            if(self.dataSources.count>indexPath.row+1){
                AICloundMessageModel *model2 = self.dataSources[indexPath.row+1];
                model2.index = indexPath.row+1;
                if([selectArray containsObject:self.dataSources[indexPath.row+1]]){
                    [selectArray removeObject:model2];
                }else{
                    [selectArray addObject:model2];
                }
            }
        }
        [tableView reloadData];
    }
}

#pragma mark <- tableview delegate ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSources.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataSources.count>indexPath.row){
        AICloundMessageModel *aiCloundMessageModel = self.dataSources[indexPath.row];
        CGFloat h = [SpeechCell cellHeight:aiCloundMessageModel Index:indexPath.row];
        return h;
    }else{
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SpeechCell *cell = [tableView dequeueReusableCellWithIdentifier:[SpeechCell ID]];
    if (cell == nil) {
        cell = [[SpeechCell alloc] init];
    }
    
    if(mulChooseRecords==NO){
        cell.chooseImv.hidden = YES;
        cell.aiLabel.type=2;
        [selectArray removeAllObjects];
    }else{
        cell.chooseImv.hidden = NO;
        cell.chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_nol"];
    }
    
    if(mulChooseRecords){
        if([selectArray containsObject:self.dataSources[indexPath.row]]){
            AICloundMessageModel *model = self.dataSources[indexPath.row];
            [cell setInfo:model Index:indexPath.row WithMulSelect:mulChooseRecords WithArray:selectArray];
            cell.speechCellDelegate = self;
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.mainTableView = tableView;
            cell.aiLabel.type=1;
            cell.chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_sel"];
        }else{
            AICloundMessageModel *model = self.dataSources[indexPath.row];
            [cell setInfo:model Index:indexPath.row WithMulSelect:mulChooseRecords WithArray:selectArray];
            cell.speechCellDelegate = self;
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.mainTableView = tableView;
            cell.aiLabel.type=2;
            cell.chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_nol"];
        }
    }else{
        if(self.dataSources.count>indexPath.row){
            AICloundMessageModel *model = self.dataSources[indexPath.row];
            [cell setInfo:model Index:indexPath.row WithMulSelect:mulChooseRecords WithArray:selectArray];
            cell.speechCellDelegate = self;
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.mainTableView = tableView;
        }
    }
    return cell;
}

- (IBAction)backBtn:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
    [selectArray removeAllObjects];
    [selectTimeArray removeAllObjects];
}

-(void)didCancelAllAction:(UIButton *)btn{
    
}

-(void)didDeleteAllAction:(UIButton *)btn{
    [self.dataSources removeAllObjects];
    [selectArray removeAllObjects];
    [selectTimeArray removeAllObjects];
    [JYBubbleMenuView.shareMenuView removeFromSuperview];
    
    [listTable reloadData];
    
    [JLSqliteAICloundMessageRecord clean];
    
    listTable.hidden = YES;
    noRecoredImageView.hidden = NO;
    noRecordLabel.hidden = NO;
    deleteBtn.hidden = YES;
    [JL_Tools post:@"STOP_TTS" Object:nil];
}

-(void)didCancelAction:(UIButton *)btn{
    
}

-(void)didDeleteAction:(UIButton *)btn{
    [JLSqliteAICloundMessageRecord s_delete:selectTimeArray];
    
    [JYBubbleMenuView.shareMenuView removeFromSuperview];
    [self hideTextSelection];
    
    [self.dataSources removeObjectsInArray:selectArray];
    
    if(self->_dataSources.count>0){
        self->noRecoredImageView.hidden = YES;
        self->noRecordLabel.hidden = YES;
        self->deleteBtn.hidden = NO;
        self->listTable.hidden = NO;
    }else{
        self->noRecoredImageView.hidden = NO;
        self->noRecordLabel.hidden = NO;
        self->deleteBtn.hidden = YES;
        self->listTable.hidden = YES;
    }
    
    [listTable reloadData];

    [selectArray removeAllObjects];
    [selectTimeArray removeAllObjects];
    [JL_Tools post:@"STOP_TTS" Object:nil];
}

-(void)didSelectTitle:(NSString *) selectTitle{
    if([selectTitle isEqualToString:kJL_TXT("多选")]){
        mulChooseRecords = YES;
        
        bottomView.hidden = NO;
        bottomLineView.hidden = NO;
        cancelLabel.hidden = NO;
        backBtn.hidden = YES;
        deleteBtn.hidden = YES;
        
        _scrollView.frame = CGRectMake(0, kJL_HeightNavBar+10, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kJL_HeightNavBar-kJL_HeightTabBar);
        listTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kJL_HeightStatusBar-kJL_HeightTabBar);
    }else{
        mulChooseRecords = NO;
        
        bottomView.hidden = YES;
        bottomLineView.hidden = YES;
        cancelLabel.hidden = YES;
        backBtn.hidden = NO;
        deleteBtn.hidden = NO;
    }
    
    [self->listTable reloadData];
}

-(void)hideTextSelection{
    mulChooseRecords = NO;
    bottomView.hidden = YES;
    bottomLineView.hidden = YES;
    cancelLabel.hidden = YES;
    backBtn.hidden = NO;
    deleteBtn.hidden = NO;
    
    _scrollView.frame = CGRectMake(0, kJL_HeightNavBar+10, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kJL_HeightNavBar);
    listTable.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.height-kJL_HeightStatusBar);
    [listTable reloadData];
}

#pragma mark 删除所选的记录
-(void)deleteSelectRecords{
    if(selectArray.count==0){
        [JL_Tools mainTask:^{
            [DFUITools showText:@"请先选择要删除的记录" onView:[DFUITools getWindow] delay:1.5];
        }];
        return;
    }
    
    selectDelectRecordView = [[DeleteRecordView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
    selectDelectRecordView.titleLab.numberOfLines = 1;
    selectDelectRecordView.delegate = self;
    selectDelectRecordView.titleLab.text = kJL_TXT("是否删除");
    selectDelectRecordView.titleLab.textAlignment = NSTextAlignmentCenter;
    selectDelectRecordView.type = 1;
    [self.view addSubview:selectDelectRecordView];
    
    for(AICloundMessageModel *model in selectArray){
        NSTimeInterval timestamp = [model.date timeIntervalSince1970];
        [selectTimeArray addObject:[NSNumber numberWithInteger:(NSInteger)timestamp]];
    }
}

#pragma mark 删除所有记录
-(void)deleteAllRecords:(UIButton *)btn{
//    if(self.dataSources.count%2!=0){
//        [DFUITools showText:@"还没有收到AI回复,暂时不支持该操作" onView:[DFUITools getWindow] delay:1.5];
//        return;
//    }
    deleteAllRecordView = [[DeleteRecordView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], [DFUITools screen_2_H])];
    deleteAllRecordView.delegate = self;
    deleteAllRecordView.titleLab.text = kJL_TXT("该对话所有内容将被删除，且无法撤\n销，是否删除");
    deleteAllRecordView.titleLab.textAlignment = NSTextAlignmentCenter;
    deleteAllRecordView.type = 0;
    [self.view addSubview:deleteAllRecordView];
}

-(void)deleteLastItem{
    if(self.dataSources.count>0){
        AICloundMessageModel *model = [self.dataSources objectAtIndex:self.dataSources.count-1];
        if(model.role==1){
            [self.dataSources removeObject:model];
            [self->listTable reloadData];
            if(self.dataSources.count==0){
                listTable.hidden = YES;
                noRecoredImageView.hidden = NO;
                noRecordLabel.hidden = NO;
                deleteBtn.hidden = YES;
            }
        }
    }
}

-(void)update:(AICloundMessageModel *)aiCloundMessageModel{
    if(selectDelectRecordView!=NULL && selectDelectRecordView.isHidden==NO){
        selectDelectRecordView.hidden = YES;
    }
    
    if(deleteAllRecordView!=NULL && deleteAllRecordView.isHidden==NO){
        deleteAllRecordView.hidden = YES;
    }
    
    [self didSelectTitle:@""];
    
    if([aiCloundMessageModel.text isEqualToString:@"识别中..."]){
        if(self.dataSources.count>self.dataSources.count-1 && aiCloundMessageModel.aiCloudState==1 && aiCloundMessageModel.role==1){
            AICloundMessageModel *model = [self.dataSources objectAtIndex:self.dataSources.count-1];
            if(model.role==2){
                return;
            }
            model.text = @"识别中...";
            [self->listTable reloadData];
            [JL_Tools delay:2.6 Task:^{
                NSTimeInterval timestamp = [model.date timeIntervalSince1970];
                NSMutableArray *selectTimeArray = [NSMutableArray array];
                [selectTimeArray addObject:[NSNumber numberWithInteger:(NSInteger)timestamp]];
                //[JLSqliteAICloundMessageRecord s_delete:selectTimeArray];

                if(model.role==2){
                    return;
                }
                
                for(AICloundMessageModel *myModel in self.dataSources){
                    if(myModel.date == model.date && myModel.role==1){
                        if([model.text isEqualToString:@"识别中..."]){
                            [self.dataSources removeObject:model];
                        }
                        if(self.dataSources.count==0){
                            self->listTable.hidden = YES;
                            self->noRecoredImageView.hidden = NO;
                            self->noRecordLabel.hidden = NO;
                            self->deleteBtn.hidden = YES;
                        }else{
                            [self->listTable reloadData];
                            [self scrollTableToFoot:YES];
                        }
                        return;
                    }
                }
            }];
        }
    }
}

-(void)initMyData:(AICloundMessageModel *) aiCloundMessageModel{
    startAI = YES;
    
    if(selectDelectRecordView!=NULL && selectDelectRecordView.isHidden==NO){
        selectDelectRecordView.hidden = YES;
    }
    
    if(deleteAllRecordView!=NULL && deleteAllRecordView.isHidden==NO){
        deleteAllRecordView.hidden = YES;
    }
    
    [self didSelectTitle:@""];
    
    [[AIClound sharedMe] loadMore:^(NSArray<AICloundMessageModel *> * _Nonnull chatMessages) {
        self.dataSources = [chatMessages mutableCopy];
        
        if(self.dataSources.count>0){
            self->noRecoredImageView.hidden = YES;
            self->noRecordLabel.hidden = YES;
            self->deleteBtn.hidden = NO;
            self->listTable.hidden = NO;
            [self->listTable reloadData];
            
            if(self.dataSources.count>2){
                [self scrollTableToFoot:YES];
            }else {
                [self->_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        }
    }];
    
    AICloundMessageModel *model = aiCloundMessageModel;
        
    if(model!=NULL && model.text.length>0){
       [self.dataSources addObject:model];
        
        if(model.aiCloudState == 2){
            NSDate *lastModelDate;
            for(int i=0;i<self.dataSources.count;i++){
                if(i==0){
                    model.isFirstPage = YES;
                    lastModelDate = model.date;
                }else{
                    if([self getCurrentMin:model.date WithLastDate:lastModelDate]>10){
                        model.isFirstPage = YES;
                        lastModelDate = model.date;
                    }else{
                        model.isFirstPage = NO;
                    }
                }
            }
            
            if(self.dataSources.count>self.dataSources.count-2){
                AICloundMessageModel *myModel = [self.dataSources objectAtIndex:self.dataSources.count-2];
                AICloundMessageModel *myModel2 = [self.dataSources objectAtIndex:self.dataSources.count-1];
                if(myModel.role==2){
                    return;
                }

                if(myModel2.text.length>0){
                    [self.dataSources removeObject:myModel];
                }
            }
        }
        
        if(self->_dataSources.count>0){
            self->noRecoredImageView.hidden = YES;
            self->noRecordLabel.hidden = YES;
            self->deleteBtn.hidden = NO;
            self->listTable.hidden = NO;
            
            [self->listTable reloadData];

            if(self.dataSources.count>2){
                [self scrollTableToFoot:YES];
            }else {
                [self->_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        }
    }
}

-(void)initAIData:(AICloundMessageModel *) aiCloundMessageModel{
    if(selectDelectRecordView!=NULL && selectDelectRecordView.isHidden==NO){
        selectDelectRecordView.hidden = YES;
    }
    
    if(deleteAllRecordView!=NULL && deleteAllRecordView.isHidden==NO){
        deleteAllRecordView.hidden = YES;
    }
    
    [self didSelectTitle:@""];
    
    AICloundMessageModel *model = aiCloundMessageModel;

    if(model.text!=NULL && model.text.length>0){
        [self.dataSources addObject:model];

        if(self.dataSources.count>0){
            self->noRecoredImageView.hidden = YES;
            self->noRecordLabel.hidden = YES;
            self->deleteBtn.hidden = NO;
            self->listTable.hidden = NO;
            [self->listTable reloadData];

            if(self.dataSources.count>2){
                [self scrollTableToFoot:YES];
            }else {
                [self->_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        }
    }
}

-(void)cancelMulChoose{
    [self hideTextSelection];
}

#pragma mark - 滑到最底部
- (void)scrollTableToFoot:(BOOL)animated {
    NSInteger s = [listTable numberOfSections]; //有多少组
    if (s<1) return; //无数据时不执行 要不会crash
    NSInteger r = [listTable numberOfRowsInSection:s-1]; //最后一组有多少行
    if (r<1) return; NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1]; //取最后一行数据
    [listTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popViewControllerAnimated:YES];
        [JL_Tools post:@"STOP_TTS" Object:nil];
    }
}

-(void)clickScreen{
    [JYBubbleMenuView.shareMenuView removeFromSuperview];
}

-(void)noteRecord:(NSNotification*)note {
    if(self.dataSources.count==0){
        listTable.hidden = YES;
        noRecoredImageView.hidden = NO;
        noRecordLabel.hidden = NO;
        deleteBtn.hidden = YES;
    }
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


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:@"NO_RECORED" Action:@selector(noteRecord:) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [JL_Tools remove:@"NO_RECORED" Own:self];
}

@end
