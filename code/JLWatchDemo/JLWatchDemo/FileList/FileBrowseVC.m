//
//  FileBrowseVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/4/2.
//

#import "FileBrowseVC.h"

#import "JLHeadFile.h"
#import "TipView.h"

@interface FileBrowseVC ()<UITableViewDelegate,
                           UITableViewDataSource>{
    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UILabel *fileTitle;
    NSArray *dataArray;
    
    
    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;
    
    JLModel_File    *nowFileModel;
    JLModel_File    *lastFileModel;
}

@end

@implementation FileBrowseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    mCmdManager = bleSDK.bt_ble.mAssist.mCmdManager;
    
    [self getSystemInfo];
    [self addFileMonitor];
    
    [JL_Tools delay:1.0 Task:^{
        [self loadRootFiles];
    }];
}

-(void)setupUI{
    subTableView.tableFooterView = [UIView new];
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    subTableView.rowHeight  = 50.0;
}


-(void)getSystemInfo{
    //获取外部存储设备的信息
    [mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON
                     SelectionBit:0x04
                           Result:nil];
}

-(void)addFileMonitor{
    [mCmdManager.mFileManager cmdBrowseMonitorResult:^(NSArray * _Nullable array,
                                          JL_BrowseReason reason) {
        switch (reason) {
            case JL_BrowseReasonReading:{
                NSLog(@"---> 正在读取:%lu",(unsigned long)array.count);
                self->dataArray = array;
                [self->subTableView reloadData];
            }break;
            case JL_BrowseReasonCommandEnd:{
                NSLog(@"读取命令结束:%lu",(unsigned long)array.count);
            }break;
            case JL_BrowseReasonFolderEnd:{
                NSLog(@"---> 目录读取结束:%lu",(unsigned long)array.count);
                [DFUITools showText:@"当前目录加载完~" onView:self.view delay:1.0];
            }break;
            case JL_BrowseReasonBusy:{
                NSLog(@"设备在忙");
            }break;
            case JL_BrowseReasonDataFail:{
                NSLog(@"数据读取失败");
            }break;
            case JL_BrowseReasonPlaySuccess:{
                NSLog(@"---> 播放成功");
            }break;
            case JL_BrowseReasonUnknown:{
                NSLog(@"未知错误");
            }
            default:
                break;
        }
    }];
}

-(void)loadRootFiles{
    JLModel_Device *deviceModel = [mCmdManager outputDeviceModel];
    
    JLModel_File *fileModel = [JLModel_File new];
    fileModel.fileType      = JL_BrowseTypeFolder;
    fileModel.cardType      = JL_CardTypeSD_1;
    fileModel.fileHandle    = deviceModel.handleSD_1;
    fileModel.fileName      = @"SD Card";
    fileModel.folderName    = @"SD Card";
    fileModel.fileClus      = 0;
    
    lastFileModel= fileModel;
    nowFileModel = fileModel;
    
    //读取目录
    [mCmdManager.mFileManager cmdBrowseModel:nowFileModel Number:10 Result:nil];
    
    fileTitle.text = @"SDCard";
}


- (IBAction)btnBack:(id)sender {
    
    if (lastFileModel) {
        [mCmdManager.mFileManager cmdBrowseModel:lastFileModel Number:10 Result:nil];
        nowFileModel = lastFileModel;
        
        fileTitle.text = nowFileModel.fileName;
    }
}


- (IBAction)btnLoadMore:(id)sender {
    if (nowFileModel) {
        [mCmdManager.mFileManager cmdBrowseModel:nowFileModel Number:10 Result:nil];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell = @"BTCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
    }
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    JLModel_File *model = dataArray[indexPath.row];
    if (model.fileType == JL_BrowseTypeFolder) {
        NSString *txt = [NSString stringWithFormat:@"[文件夹] %@",model.fileName];
        cell.textLabel.text = txt;
    }else{
        NSString *txt = [NSString stringWithFormat:@"[文件] %@",model.fileName];
        cell.textLabel.text = txt;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JLModel_File *model = dataArray[indexPath.row];
    if (model.fileType == JL_BrowseTypeFolder) {
        lastFileModel = nowFileModel;
    }else{
        return;
    }
    
    [mCmdManager.mFileManager cmdBrowseModel:model Number:10 Result:nil];
    nowFileModel = model;
    
    fileTitle.text = nowFileModel.fileName;
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
