//
//  WatchOperationVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/7.
//

#import "WatchOperationVC.h"
#import "JLHeadFile.h"
#import "TipView.h"

#import "DocumentView.h"

@interface WatchOperationVC ()<UITableViewDelegate,
                               UITableViewDataSource>
{
    __weak IBOutlet NSLayoutConstraint *H_TitleView;
    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UIProgressView *progressView;
    __weak IBOutlet UILabel *progressText;
    
    
    NSString *deviceText;
    NSString *selectText;
    NSArray *dataArray;
    
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UIButton *btnReplace;
    __weak IBOutlet UIButton *btnDel;
    
    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;
    
    DocumentView    *myDocumentView;
    
    JL_Timer        *testTimer;
}

@end

@implementation WatchOperationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI{
    H_TitleView.constant = kJL_HeightNavBar;
    
    subTableView.tableFooterView = [UIView new];
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    subTableView.rowHeight  = 50.0;
    
    testTimer = [[JL_Timer alloc] init];
    testTimer.subTimeout = 10.0;

    
    [self getListFile];
    

}

-(void)getListFile{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    bt_ble = bleSDK.bt_ble;
    
    /*--- 判断是否已连接设备 ---*/
    if (bt_ble.mBlePeripheral == nil) {
        [DFUITools showText:@"请先连设备!" onView:self.view delay:1.0];
        return;
    }
    mCmdManager = self->bt_ble.mAssist.mCmdManager;
    
    [TipView startLoadingView:@"获取文件列表..." Delay:30.0];
    [DialManager listFile:^(DialOperateType type, NSArray * _Nullable array) {

        
        [JL_Tools mainTask:^{
            [self->subTableView reloadData];
            [TipView removeLoading];
            [DFUITools showText:@"获取成功！" onView:self.view delay:1.0];
            
            [JL_Tools subTask:^{
                [self getWatchFace];
            }];
        }];
    }];
}

-(void)getWatchFace{
    [mCmdManager.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial
                                          Result:^(uint8_t flag, uint32_t size,
                                                   NSString * _Nullable path,
                                                   NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            NSString *txt = @"获取表盘成功!";
            if (flag != 0) txt = @"获取表盘失败~";
            [DFUITools showText:txt onView:self.view delay:1.0];

            if (flag == 0) {
                NSLog(@"当前表盘 ---> %@",path);
                self->deviceText = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
                [self->subTableView reloadData];
            }
            [self->testTimer cancelTimeout];
            [self->testTimer threadContinue];
        }];
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* IDCell = @"FatsCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
    }
    NSString *txt = dataArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.text = txt;
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    
    if ([txt isEqual:deviceText]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detailTextLabel.text = @"手表当前表盘";
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @" ";
    }
    if ([txt isEqual:selectText]) {
        cell.textLabel.textColor = [UIColor blueColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectText = dataArray[indexPath.row];
    [tableView reloadData];
        
}

- (IBAction)btnAddWatch:(id)sender {
    
    myDocumentView = [[DocumentView alloc] init];
    [self.view addSubview:myDocumentView];
    
    NSString *mPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:@""];
    [myDocumentView showWithPath:mPath Result:^(NSString * _Nonnull file) {
        NSString *path = [mPath stringByAppendingPathComponent:file];
        [self addWatchPath:path];
    }];
}

-(void)addWatchPath:(NSString*)path{
    
    __weak typeof(self) wSelf = self;
    [TipView startLoadingView:@"创建文件..." Delay:200.0];
    
    [self showProgressUI];
    progressText.text = @"正在添加表盘...";

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSLog(@"-->创建的文件:%@ 大小:%lld",[path lastPathComponent],(long long)data.length);
    NSString *fileName = [NSString stringWithFormat:@"/%@",[path lastPathComponent]];
    
    [DialManager addFile:fileName Content:data Result:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeNoSpace) {
            [TipView setLoadingText:@"空间不足~" Delay:0.5];
            [self closeProgressUI];
        }
        if (type == DialOperateTypeFail) {
            [TipView setLoadingText:@"创建文件失败！" Delay:0.5];
            [self closeProgressUI];
        }
        if (type == DialOperateTypeDoing) {
            NSString *txt = [NSString stringWithFormat:@"正在添加:%.1f%%",progress*100.0f];
            self->progressText.text = txt;
            self->progressView.progress = progress;
        }
        if (type == DialOperateTypeSuccess) {
            //NSDate *date = [NSDate new];
            //NSTimeInterval tm = [DFTime gapOfDateA:date DateB:date_add];
            //self->timeLabel.text = [NSString stringWithFormat:@"Time:%.1fs Speed:%.1fkb",tm,176.0f/tm];
            
            [self closeProgressUI];
            [TipView setLoadingText:@"创建文件成功！" Delay:0.5];
                                    
            /*--- 读取列表 ---*/
            [wSelf getListFile];
        }
    }];
}

- (IBAction)btnReplace:(id)sender {
    
    if (selectText.length == 0 || ![selectText hasPrefix:@"WATCH"]) {
        [DFUITools showText:@"请选择WATCH文件！" onView:self.view delay:1.0];
        return;
    }
    
    myDocumentView = [[DocumentView alloc] init];
    [self.view addSubview:myDocumentView];
    
    NSString *mPath = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:@""];
    [myDocumentView showWithPath:mPath Result:^(NSString * _Nonnull file) {
        NSString *path = [mPath stringByAppendingPathComponent:file];
        [self replaceWatch:path];
    }];
}

-(void)replaceWatch:(NSString*)path{
    __weak typeof(self) wSelf = self;
    [TipView startLoadingView:@"替换文件..." Delay:200.0];
    
    [self showProgressUI];
    progressText.text = @"正在替换表盘...";

    NSData *data = [NSData dataWithContentsOfFile:path];
    NSLog(@"-->替换的文件:%@ 大小:%lld",[path lastPathComponent],(long long)data.length);
    
    NSString *fileName = [NSString stringWithFormat:@"/%@",selectText];
    NSLog(@"-->原文件：%@",fileName);
    
    [DialManager repaceFile:fileName Content:data Result:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeNoSpace) {
            [TipView setLoadingText:@"空间不足~" Delay:0.5];
            [self closeProgressUI];
        }
        if (type == DialOperateTypeFail) {
            [TipView setLoadingText:@"替换文件失败！" Delay:0.5];
            [self closeProgressUI];
        }
        if (type == DialOperateTypeDoing) {
            NSString *txt = [NSString stringWithFormat:@"正在替换:%.1f%%",progress*100.0f];
            self->progressText.text = txt;
            self->progressView.progress = progress;
        }
        if (type == DialOperateTypeSuccess) {
            //NSDate *date = [NSDate new];
            //NSTimeInterval tm = [DFTime gapOfDateA:date DateB:date_add];
            //self->timeLabel.text = [NSString stringWithFormat:@"Time:%.1fs Speed:%.1fkb",tm,176.0f/tm];
            
            [self closeProgressUI];
            [TipView setLoadingText:@"替换文件成功！" Delay:0.5];
                                    
            /*--- 读取列表 ---*/
            [wSelf getListFile];
        }
    }];
}



- (IBAction)btnDelete:(id)sender {
    if (selectText.length == 0 || ![selectText hasPrefix:@"WATCH"]) {
        [DFUITools showText:@"请选择WATCH文件！" onView:self.view delay:1.0];
        return;
    }
    [TipView startLoadingView:@"删除文件..." Delay:20.0];
    NSString *path = [NSString stringWithFormat:@"/%@",selectText];
    
    [DialManager deleteFile:path Result:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeFail) {
            [TipView setLoadingText:@"删除文件失败！" Delay:0.5];
        }
        if (type == DialOperateTypeSuccess) {
            [TipView setLoadingText:@"删除文件成功！" Delay:0.5];
                                    
            /*--- 读取列表 ---*/
            [self getListFile];
        }
    }];
}

- (IBAction)btnChangeWatch:(id)sender {
    if (selectText.length == 0 || ![selectText hasPrefix:@"WATCH"]) {
        [DFUITools showText:@"请选择WATCH文件！" onView:self.view delay:1.0];
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"/%@",selectText];
    [mCmdManager.mFlashManager cmdWatchFlashPath:path Flag:JL_DialSettingSetDial
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            NSString *txt = @"设置表盘成功!";
            if (flag != 0) {
                txt = @"设置表盘失败~";
            }else{
                self->deviceText = self->selectText;
                [self->subTableView reloadData];
            }
            [DFUITools showText:txt onView:self.view delay:1.0];
        }];
    }];
}


-(void)showProgressUI{
    progressView.hidden = NO;
    progressText.hidden = NO;
    progressView.progress = 0.0f;
}

-(void)closeProgressUI{
    progressView.hidden = YES;
    progressText.hidden = YES;
    progressView.progress = 0.0f;
    self->myDocumentView = nil;
}



- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
