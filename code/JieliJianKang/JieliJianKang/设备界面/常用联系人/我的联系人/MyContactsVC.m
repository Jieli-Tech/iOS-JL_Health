//
//  MyContactsVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/17.
//

#import "MyContactsVC.h"
#import "JL_RunSDK.h"
#import "JHContactManager.h"
#import "JHTableViewCell.h"
#import "ChineseToPinyin.h"
#import <ContactsUI/ContactsUI.h>
#import "MyContactsVC.h"
#import "MyPhoneVC.h"
#import "DeleteView.h"
#import "JLUI_Effect.h"
#import "ContactsTool.h"
#import "JLPopMenuView.h"
#import "JLFileTransferHelper.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

typedef NS_ENUM(NSInteger, LYFTableViewType) {
    /// 顶部
    LYFTableViewTypeTop,
    /// 底部
    LYFTableViewTypeBottom
};

@interface MyContactsVC() <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, DeleteViewDelegate, MyPhoneVCDelegate> {
    
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    // 记录手指所在的位置
    CGPoint longLocation;
    // 对被选中的cell的截图
    UIView *snapshotView;
    // 被选中的cell的原始位置
    NSIndexPath *oldIndexPath;
    // 被选中的cell的新位置
    NSIndexPath *newestIndexPath;
    // 定时器
    CADisplayLink *scrollTimer;
    // 滚动方向
    LYFTableViewType scrollType;
    
    NSMutableArray *mSelectArray;   // 删除选中联系人数组
    NSMutableArray<JHPersonModel * > *persons;  // tableview数据源
    NSMutableArray<JHPersonModel * > *personsOrigianlArray;  // tableview数据源，for 排序保存原来联系人顺序
    
    //JL_ManagerM *mCmdManager;
    JLModel_Device *modelDevice;
    JL_Timer *threadTimer_0;
    JL_Timer *threadTimer_1;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleName;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

// 联系人视图相关
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 无联系人视图相关
@property (weak, nonatomic) IBOutlet UIView *noContactsContainerView;
@property (weak, nonatomic) IBOutlet UILabel *noContactsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noContactTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) DeleteView *deleteView;

@property (assign, nonatomic) JLContactsFuncType funType; //0:添加 1:排序 2：移除

@end

@implementation MyContactsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNote];
    
    titleHeight.constant = kJL_HeightNavBar;
    // 初始化界面
    [self configureNoContactsContainerView];
    [self configureContactsView];
    
    mSelectArray = [NSMutableArray array];
    
    self.leftBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.titleName.text = kJL_TXT("常用联系人");
    
    [DFUITools showText:kJL_TXT("读取联系人") onView:self.view delay:1.0];
    [JL_Tools delay:0.8 Task:^{
        [self getContactsList];
        self.tableView.frame = CGRectMake(0, kJL_HeightNavBar+8, [UIScreen mainScreen].bounds.size.width , self->persons.count*70);
    }];
    
    modelDevice = [kJL_BLE_CmdManager outputDeviceModel];
    threadTimer_0 = [[JL_Timer alloc] init];
    threadTimer_1 = [[JL_Timer alloc] init];
}

#pragma mark - UI Configure Methods

/**
 *  初始化联系人界面
 */
- (void)configureContactsView {
    self.view.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = kDF_RGBA(247, 247, 247, 1.0);
    self.tableView.scrollEnabled = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = kDF_RGBA(247, 247, 247, 1.0);
    
    if ([kJL_GET isEqualToString:@"zh-Hans"] || [kJL_GET isEqual:@"auto"]) {
        UILabel *tableFooterLabel = [[UILabel alloc] init];
        tableFooterLabel.textAlignment = NSTextAlignmentLeft;
        tableFooterLabel.numberOfLines = 2;
        tableFooterLabel.text = kJL_TXT("最多可为您的手表添加10位常用联系人。您设置的常用联系人将自动同步至设备。");
        tableFooterLabel.textColor = kDF_RGBA(114, 114, 114, 1.0);
        tableFooterLabel.font = [UIFont fontWithName:@"PingFang SC" size: 14];
        tableFooterLabel.frame = CGRectMake(16, 16, [UIScreen mainScreen].bounds.size.width-32, 40);
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 60)];
        tableFooterView.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
        self.tableView.tableFooterView = tableFooterView;
        [self.tableView.tableFooterView addSubview:tableFooterLabel];
    }else{
        DFLabel *tableFooterLabel = [[DFLabel alloc] init];
        tableFooterLabel.labelType = DFLeftRight;
        tableFooterLabel.contentMode = UIViewContentModeLeft;
        tableFooterLabel.textAlignment = NSTextAlignmentLeft;
        tableFooterLabel.numberOfLines = 2;
        tableFooterLabel.text = kJL_TXT("最多可为您的手表添加10位常用联系人。您设置的常用联系人将自动同步至设备。");
        tableFooterLabel.textColor = kDF_RGBA(114, 114, 114, 1.0);
        tableFooterLabel.font = [UIFont fontWithName:@"PingFang SC" size: 14];
        tableFooterLabel.frame = CGRectMake(16, 16, [UIScreen mainScreen].bounds.size.width-32, 40);
        UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 60)];
        tableFooterView.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
        self.tableView.tableFooterView = tableFooterView;
        [self.tableView.tableFooterView addSubview:tableFooterLabel];
    }
   
    
    // 设置删除联系人界面
    self.deleteView = [[DeleteView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.deleteView.titleLab.numberOfLines = 1;
    self.deleteView.type = 0;
    self.deleteView.delegate = self;
    self.deleteView.titleLab.text = kJL_TXT("是否删除所选联系人");
    [self.view addSubview:self.deleteView];
    self.deleteView.hidden = YES;
}

/**
 *  设置无联系人视图
 */
- (void)configureNoContactsContainerView {
    self.noContactsTitleLabel.text = kJL_TXT("没有常用联系人");
    self.noContactTipsLabel.text = kJL_TXT("为您的手表设置常用联系人，便于快速发起通话，所设置的联系人将自动同步至设备。");
    [self.addButton setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
    self.addButton.layer.borderWidth = 1.0;
    self.addButton.layer.borderColor = kDF_RGBA(128, 91, 235, 1.0).CGColor;
    self.addButton.layer.masksToBounds = YES;
    self.addButton.layer.cornerRadius = 15;
    self.moreBtn.hidden = YES;
}

/**
 *  根据联系人人数展示联系人视图
 */
- (void)displayContactsView {
    if ((persons != nil) && (persons.count > 0)) {
        // 重新排序
        if (self.funType == JLContactsFuncTypeSort) {
            [persons removeAllObjects];
            for (int i = 0; i < personsOrigianlArray.count; i++) {
                JHPersonModel *model = personsOrigianlArray[i];
                [persons addObject:model];
            }
        } else {
            [personsOrigianlArray removeAllObjects];
            for (int i = 0; i < persons.count; i++) {
                JHPersonModel *model = persons[i];
                [personsOrigianlArray addObject:model];
            }
        }
        self.noContactsContainerView.hidden = YES;
        self.moreBtn.hidden = NO;
        [self.tableView reloadData];
    } else {
        self.noContactsContainerView.hidden = NO;
        self.moreBtn.hidden = YES;
    }
    for (JHPersonModel *personModel in mSelectArray) {
        personModel.contactsSelect = NO;
    }
    [mSelectArray removeAllObjects];
    self.funType = JLContactsFuncTypeAdd;
    self.leftBtn.hidden = YES;
    self.rightBtn.hidden = YES;
    self.backBtn.hidden = NO;
    self.titleName.text = kJL_TXT("常用联系人");
}

#pragma mark - 获取联系人列表
- (void)getContactsList {
    NSMutableData *mData = [NSMutableData new];
    persons = [NSMutableArray<JHPersonModel * > new];
    personsOrigianlArray = [NSMutableArray<JHPersonModel * > new];

    if (modelDevice.smallFileWayType == JL_SmallFileWayTypeNO) {
        /*--- 原来通讯流程 ---*/
        [kJL_BLE_CmdManager.mFileManager setCurrentFileHandleType:[JLFileTransferHelper getContactTargetDev]];
        [kJL_BLE_CmdManager.mFileManager cmdFileReadContentWithName:@"CALL.txt" Result:^(JL_FileContentResult result, uint32_t size, NSData * _Nullable data,float progress) {
            if (result == JL_FileContentResultStart) {
                NSLog(@"---> 读取【Call.txt】开始.");
            } else if (result == JL_FileContentResultReading) {
                NSLog(@"---> 读取【Call.txt】Reading");
                if (data.length > 0) {
                    [mData appendData:data];
                }
            } else if(result == JL_FileContentResultEnd) {
                NSLog(@"---> 读取【Call.txt】结束");
                if (mData == nil || mData.length < 40) {
                    return;
                }
                [self outputContactsListData:mData];
                [self displayContactsView];
            } else if (result == JL_FileContentResultCancel) {
                NSLog(@"---> 读取【Call.txt】取消");
            } else if (result == JL_FileContentResultFail) {
                NSLog(@"---> 读取【Call.txt】失败");
            } else if (result == JL_FileContentResultNull) {
                NSLog(@"---> 读取【Call.txt】文件为空");
                [self displayContactsView];
            } else if (result == JL_FileContentResultDataError) {
                NSLog(@"---> 读取【Call.txt】数据出错");
            }
        }];
    }else{
        
        [JL_Tools subTask:^{
            __block JLModel_SmallFile *smallFile = nil;
            
            
            
            /*--- 查询小文件列表 ---*/
            [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileQueryType:JL_SmallFileTypeContacts
                                                      Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                if (array.count > 0) smallFile = array[0];
                
                [self->threadTimer_0 threadContinue];
            }];
            [self->threadTimer_0 threadWait];
            
            if (smallFile == nil) return;

            /*--- 读取小文件通讯录 ---*/
            [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileRead:smallFile
                                                 Result:^(JL_SmallFileOperate status,
                                                          float progress, NSData * _Nullable data) {
                if (status == JL_SmallFileOperateDoing) {
                    NSLog(@"---> 小文件读取【Call.txt】开始：%lu",(unsigned long)data.length);
                }
                if (status != JL_SmallFileOperateDoing &&
                    status != JL_SmallFileOperateSuceess) {
                    NSLog(@"---> 小文件读取【Call.txt】失败~");
                }
                
                if (data.length > 0) [mData appendData:data];
                if (status == JL_SmallFileOperateSuceess) {
                    NSLog(@"---> 小文件读取【Call.txt】成功！");
                    if (mData.length >= 40) {
                        [JL_Tools mainTask:^{
                            [self outputContactsListData:mData];
                            [self displayContactsView];
                        }];
                    }
                }
            }];
        }];
        
    }
}

-(void)outputContactsListData:(NSData*)mData{
    for (int i = 0; i <= mData.length - 40; i += 40) {
        NSData *buf_name = [JL_Tools data:mData R:i L:20];
        NSData *buf_number = [JL_Tools data:mData R:i+20 L:20];
        NSString *nameStr = [[NSString alloc] initWithData:buf_name encoding:NSUTF8StringEncoding];
        nameStr = [nameStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        nameStr = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *numberStr = [[NSString alloc] initWithData:buf_number encoding:NSUTF8StringEncoding];
        numberStr = [numberStr stringByReplacingOccurrencesOfString:@"\0"withString:@""];
        numberStr = [numberStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        JHPersonModel *model = [[JHPersonModel alloc] init];
        model.fullName = nameStr;
        model.phoneNum = numberStr;
        
        [self->persons addObject:model];
        [self->personsOrigianlArray addObject:model];
    }
}



#pragma mark 发送生成的联系人数据
- (void)syncContactsListToDevice {

    NSString *path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"CALL.TXT"];
    [JL_Tools writeData:[ContactsTool setContactsToData:persons] fillFile:path];
    
    
    if (modelDevice.smallFileWayType == JL_SmallFileWayTypeNO) {
        /*--- 原来通讯流程 ---*/
        if ([JLFileTransferHelper getContactTargetDev] == JL_CardTypeFLASH2) {
            [JLFileTransferHelper sendContactFileToFlashWithFileName:@"CALL.TXT" withResult:^(JLFileTransferOperateType type, float progress) {
                if (type == JLFileTransferOperateTypeStart) {
                    [JLUI_Effect startLoadingView:kJL_TXT("同步中...") Delay:8.0];
                }
                if (type == JLFileTransferOperateTypeSuccess) {
                    NSLog(@"CALL.TXT 传输成功");
                    [JLUI_Effect setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                }
            }];
        } else {
            [JLFileTransferHelper sendContactFileWithFileName:@"CALL.TXT" withResult:^(JLFileTransferOperateType type, float progress) {
                if (type == JLFileTransferOperateTypeStart) {
                    [JLUI_Effect startLoadingView:kJL_TXT("同步中...") Delay:8.0];
                }
                if (type == JLFileTransferOperateTypeSuccess) {
                    NSLog(@"CALL.TXT 传输成功");
                    [JLUI_Effect setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                }
            }];
        }
    } else {
        /*--- 小文件方式传输通讯录 ---*/
        [self smallFileSyncContactsListWithPath:path];
    }
}

-(void)smallFileSyncContactsListWithPath:(NSString*)path{
    [JLUI_Effect startLoadingView:kJL_TXT("同步中...") Delay:8.0];
    [JL_Tools subTask:^{
        __block JLModel_SmallFile *smallFile = nil;
        
        /*--- 查询小文件列表 ---*/
        [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileQueryType:JL_SmallFileTypeContacts
                                                  Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
            if (array.count > 0) smallFile = array[0];
            [self->threadTimer_1 threadContinue];
        }];
        [self->threadTimer_1 threadWait];
        
        
        /*--- 先删通讯录 ---*/
        if (smallFile != nil) {
            __block JL_SmallFileOperate status_del = 0;
            [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileDelete:smallFile
                                                         Result:^(JL_SmallFileOperate status) {
                status_del = status;
                [self->threadTimer_1 threadContinue];
            }];
            [self->threadTimer_1 threadWait];
            
            if (status_del != JL_SmallFileOperateSuceess) {
                [JL_Tools mainTask:^{
                    NSLog(@"--->小文件 CALL.TXT 传输失败");
                    [JLUI_Effect setLoadingText:kJL_TXT("同步失败！") Delay:0.5f];
                }];
                return;
            }
        }
        
        /*--- 小文件传输文件 ---*/
        NSData *pathData = [NSData dataWithContentsOfFile:path];
        [kJL_BLE_CmdManager.mSmallFileManager cmdSmallFileNew:pathData Type:JL_SmallFileTypeContacts
                                                  Result:^(JL_SmallFileOperate status, float progress,
                                                           uint16_t fileID) {
            [JL_Tools mainTask:^{


                if (status == JL_SmallFileOperateSuceess) {
                    NSLog(@"--->小文件 CALL.TXT 传输成功");
                    [JLUI_Effect setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                }
                if (status != JL_SmallFileOperateSuceess &&
                    status != JL_SmallFileOperateDoing){
                    NSLog(@"--->小文件 CALL.TXT 传输失败");
                    [JLUI_Effect setLoadingText:kJL_TXT("同步失败！") Delay:0.5f];
                }
            }];
        }];
        

        
    }];
}


#pragma mark - Button Methods

- (IBAction)actionExit:(UIButton *)sender {
    if (self.funType == JLContactsFuncTypeSort) {
        [self displayContactsView];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionMore:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    NSArray<JLPopMenuViewItemObject *> *arr = @[
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("添加") withImageName:@"icon_add_nol" withTapBlock:^{
            MyPhoneVC *vc = [[MyPhoneVC alloc] init];
            vc.originalContactArray = self->persons;
            vc.delegate = self;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }],
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("排序") withImageName:@"icon_reorder_nol" withTapBlock:^{
            self.funType = JLContactsFuncTypeSort;
            self.titleName.text = kJL_TXT("联系人排序");
            self.moreBtn.hidden = YES;
            self.rightBtn.hidden = NO;
            [self.rightBtn setTitle:kJL_TXT("完成") forState:UIControlStateNormal];
            [self.rightBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
            [self.tableView reloadData];
        }],
        [[JLPopMenuViewItemObject alloc] initWithName:kJL_TXT("移除") withImageName:@"icon_delete_nol" withTapBlock:^{
            self.funType = JLContactsFuncTypeDelete;
            self.moreBtn.hidden = YES;
            self.backBtn.hidden = YES;
            self.leftBtn.hidden = NO;
            self.rightBtn.hidden = NO;
            [self.rightBtn setTitle:kJL_TXT("删除") forState:UIControlStateNormal];
            [self.rightBtn setTitleColor:kDF_RGBA(224, 65, 76, 1.0) forState:UIControlStateNormal];
            [self.leftBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
            [self.tableView reloadData];
        }],
    ];
    JLPopMenuView *popMenuView = [[JLPopMenuView alloc] initWithStartPoint:CGPointMake(sender.x + sender.width - 155, sender.y + sender.height-10) withItemObjectArray:arr];
    [self.view addSubview:popMenuView];
    popMenuView.hidden = NO;
}

- (IBAction)rightBtnAction:(UIButton *)sender {
    if (self.funType == JLContactsFuncTypeSort) { //排序(完成)
        self.funType = JLContactsFuncTypeAdd;

        self.moreBtn.hidden = NO;
        self.rightBtn.hidden = YES;
        self.titleName.text = kJL_TXT("常用联系人");
        [self.tableView reloadData];
        
        [self syncContactsListToDevice];
    }
    if (self.funType == JLContactsFuncTypeDelete) { //移除(删除)
        if (mSelectArray.count == 0) {
            [DFUITools showText:kJL_TXT("请先选择联系人") onView:self.view delay:1.5];
            return;
        }
        self.deleteView.hidden = NO;
    }
}

- (IBAction)addBtnFunc:(id)sender {
    MyPhoneVC *vc = [[MyPhoneVC alloc] init];
    vc.originalContactArray = self->persons;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  取消按钮
 */
- (IBAction)leftBtnAction:(UIButton *)sender {
    [self displayContactsView];
}

#pragma mark - DeleteViewDelegate

- (void)didCancelAction:(UIButton *)btn {
    [self displayContactsView];
}

- (void)didDeleteAction:(UIButton *)btn {
    if (persons.count > 0 && mSelectArray.count > 0) {
        [persons removeObjectsInArray:mSelectArray];
    }
    
    if (mSelectArray.count > 0) {
        for (JHPersonModel *personModel in mSelectArray) {
            personModel.contactsSelect = NO;
        }
        [mSelectArray removeAllObjects];
    }
    
    [self syncContactsListToDevice];
    
    [self displayContactsView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JHTableViewCell class])];
    if (cell == nil) {
        cell = [[JHTableViewCell alloc] initWithMyStyle:JHTableViewCellStyleContacts reuseIdentifier:NSStringFromClass([JHTableViewCell class])];
    }

    JHPersonModel *personModel = persons[indexPath.row];
    cell.personModel = personModel;
    cell.backgroundColor = [UIColor whiteColor];
    cell.personModel.fullName = personModel.fullName;
    cell.personModel.phoneNum = personModel.phoneNum;
    cell.funType = self.funType;
    cell.contentView.gestureRecognizers = nil;
    
    if (self.funType == JLContactsFuncTypeSort) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [cell.contentView addGestureRecognizer:longPress];
    } else if (self.funType == JLContactsFuncTypeDelete) {
        if (personModel.contactsSelect) {
            cell.selectImv.image = [UIImage imageNamed:@"icon_music_sel"];
        } else {
            cell.selectImv.image = [UIImage imageNamed:@"icon_music_unsel"];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JHPersonModel *personModel = persons[indexPath.row];
    
    if(personModel.contactsSelect) {
        personModel.contactsSelect = NO;
        [mSelectArray removeObject:persons[indexPath.row]];
    } else {
        personModel.contactsSelect = YES;
        [mSelectArray addObject:persons[indexPath.row]];
    }
    
    if (self.funType == JLContactsFuncTypeDelete) {
        if(mSelectArray.count == 0){
            self.titleName.text = kJL_TXT("未选择");
        } else {
            NSString *str;
            if([kJL_GET hasPrefix:@"zh"]){
                str = [NSString stringWithFormat:@"%@%d%@",kJL_TXT("已选择"),(int)mSelectArray.count,kJL_TXT("个")];
            }else{
                str = [NSString stringWithFormat:@"%@ %d %@",kJL_TXT("已选择"),(int)mSelectArray.count,kJL_TXT("个")];
            }
            self.titleName.text = str;
        }
    }
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [JHTableViewCell getCellHeight:JHTableViewCellStyleContacts];
}

#pragma mark - MyPhoneVCDelegate

- (void)transferCallFileFinished {
    [self getContactsList];
}

#pragma mark - 当截图到了新的位置，先改变数据源，然后将cell移动过去
- (void)cellRelocatedToNewIndexPath:(NSIndexPath *)indexPath {
    //更新数据源并返回给外部
    [self updateData];
    //交换移动cell位置
    [self.tableView moveRowAtIndexPath:oldIndexPath toIndexPath:indexPath];
    //更新cell的原始indexPath为当前indexPath
    oldIndexPath = indexPath;
    
    JHTableViewCell *cell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
    cell.hidden = YES;
}

- (void)updateData {
    //通过DataSource代理获得原始数据源数组
    NSMutableArray *tempArray = [persons mutableCopy];
    
    //判断原始数据源是否为多重数组
    if ([self arrayCheck:tempArray]) {
        //是嵌套数组
        if (oldIndexPath.section == newestIndexPath.section) {//在同一个section内
            [self moveObjectInMutableArray:tempArray[oldIndexPath.section] fromIndex:oldIndexPath.row toIndex:newestIndexPath.row];
        } else {
            //不在同一个section内
            id originalObj = tempArray[oldIndexPath.section][oldIndexPath.item];
            [tempArray[newestIndexPath.section] insertObject:originalObj atIndex:newestIndexPath.item];
            [tempArray[oldIndexPath.section] removeObjectAtIndex:oldIndexPath.item];
        }
    } else { //不是嵌套数组
        [self moveObjectInMutableArray:tempArray fromIndex:oldIndexPath.row toIndex:newestIndexPath.row];
    }
}

#pragma mark - 检测是否是多重数组
- (BOOL)arrayCheck:(NSArray *)array {
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 将可变数组中的一个对象移动到该数组中的另外一个位置
- (void)moveObjectInMutableArray:(NSMutableArray *)array fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex < toIndex) {
        for (NSInteger i = fromIndex; i < toIndex; i ++) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    } else {
        for (NSInteger i = fromIndex; i > toIndex; i --) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
    
    persons = array;
}

#pragma mark - 开始自动滚动
- (void)startAutoScroll {
    CGFloat pixelSpeed = 4;
    if (scrollType == LYFTableViewTypeTop) {//向下滚动
        if (self.tableView.contentOffset.y > 0) {//向下滚动最大范围限制
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - pixelSpeed)];
            snapshotView.center = CGPointMake(snapshotView.center.x, snapshotView.center.y - pixelSpeed);
        }
    } else {                                               //向上滚动
        if (self.tableView.contentOffset.y + self.tableView.bounds.size.height < self.tableView.contentSize.height) {//向下滚动最大范围限制
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + pixelSpeed)];
            snapshotView.center = CGPointMake(snapshotView.center.x, snapshotView.center.y + pixelSpeed);
        }
    }
//     当把截图拖动到边缘，开始自动滚动，如果这时手指完全不动，则不会触发‘UIGestureRecognizerStateChanged’，对应的代码就不会执行，导致虽然截图在tableView中的位置变了，但并没有移动那个隐藏的cell，用下面代码可解决此问题，cell会随着截图的移动而移动
    newestIndexPath = [self.tableView indexPathForRowAtPoint:snapshotView.center];
    if (newestIndexPath && ![newestIndexPath isEqual:oldIndexPath]) {
        [self cellRelocatedToNewIndexPath:newestIndexPath];
    }
}

#pragma mark - 拖拽结束，显示cell，并移除截图
- (void)didEndDraging {
    JHTableViewCell *cell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
    cell.hidden = NO;
    cell.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self->snapshotView.center = cell.center;
        self->snapshotView.alpha = 0;
        self->snapshotView.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [self->snapshotView removeFromSuperview];
        self->snapshotView = nil;
        self->oldIndexPath = nil;
        self->newestIndexPath = nil;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - 创建定时器
- (void)startAutoScrollTimer {
    if (!scrollTimer) {
        scrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [scrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - 销毁定时器
- (void)stopAutoScrollTimer {
    if (scrollTimer) {
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
}

#pragma mark - 对cell进行截图，并且隐藏
- (void)snapshotCellAtIndexPath:(NSIndexPath *)indexPath {
    JHTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    /// 截图
    UIView *snapshot = [self snapshotView:cell];
    /// 添加在UITableView上
    [self.tableView addSubview:snapshot];
    snapshotView = snapshot;
    /// 隐藏cell
    cell.hidden = YES;
    CGPoint center = snapshotView.center;
    center.y = longLocation.y;
    /// 移动截图
    [UIView animateWithDuration:0.2 animations:^{
        self->snapshotView.transform = CGAffineTransformMakeScale(1.03, 1.03);
        self->snapshotView.alpha = 0.98;
        self->snapshotView.center = center;
    }];
}

#pragma mark - 截图对应的cell
- (UIView *)snapshotView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

#pragma mark - 长按手势
- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {
    UIGestureRecognizerState longPressState = longPress.state;
    //长按的cell在tableView中的位置
    longLocation = [longPress locationInView:self.tableView];
    //手指按住位置对应的indexPath，可能为nil
    newestIndexPath = [self.tableView indexPathForRowAtPoint:longLocation];
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{
            //手势开始，对被选中cell截图，隐藏原cell
            oldIndexPath = [self.tableView indexPathForRowAtPoint:longLocation];
            if (oldIndexPath) {
                [self snapshotCellAtIndexPath:oldIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{//点击位置移动，判断手指按住位置是否进入其它indexPath范围，若进入则更新数据源并移动cell
            //截图跟随手指移动
            CGPoint center = snapshotView.center;
            center.y = longLocation.y;
            snapshotView.center = center;
            if ([self checkIfSnapshotMeetsEdge]) {
                [self startAutoScrollTimer];
            }else{
                [self stopAutoScrollTimer];
            }
            //手指按住位置对应的indexPath，可能为nil
            newestIndexPath = [self.tableView indexPathForRowAtPoint:longLocation];
            if (newestIndexPath && ![newestIndexPath isEqual:oldIndexPath]) {
                [self cellRelocatedToNewIndexPath:newestIndexPath];
            }
            break;
        }
        default: {
            //长按手势结束或被取消，移除截图，显示cell
            [self stopAutoScrollTimer];
            [self didEndDraging];
            break;
        }
    }
}

#pragma mark - 检查截图是否到达边缘，并作出响应
- (BOOL)checkIfSnapshotMeetsEdge {
    CGFloat minY = CGRectGetMinY(snapshotView.frame);
    CGFloat maxY = CGRectGetMaxY(snapshotView.frame);
    if (minY < self.tableView.contentOffset.y) {
        scrollType = LYFTableViewTypeTop;
        return YES;
    }
    if (maxY > self.tableView.bounds.size.height + self.tableView.contentOffset.y) {
        scrollType = LYFTableViewTypeBottom;
        return YES;
    }
    return NO;
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)dealloc{
    [self removeNote];
}

@end
