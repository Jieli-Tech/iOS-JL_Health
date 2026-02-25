//
//  ContactVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/24.
//

#import "ContactVC.h"
#import "JLHeadFile.h"
#import "TipView.h"

#import "PersonModel.h"
#import "ContactsTool.h"
#import "JLFileTransferHelper.h"

@interface ContactVC ()<UITableViewDelegate,UITableViewDataSource>{
    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;
    
    
    __weak IBOutlet UITableView *subTableView;
    NSInteger       selectIndex;
    NSMutableArray  *dataArray;
    
    JL_Timer *threadTimer_0;
    JL_Timer *threadTimer_1;
    
}

@end

@implementation ContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    selectIndex = -1;
    threadTimer_0 = [[JL_Timer alloc] init];
    threadTimer_1 = [[JL_Timer alloc] init];

    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    bt_ble = bleSDK.bt_ble;
    
    mCmdManager = self->bt_ble.mAssist.mCmdManager;
    
    [self setupUI];
}

-(void)setupUI{
    subTableView.tableFooterView = [UIView new];
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    subTableView.rowHeight  = 50.0;
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnGetContact:(id)sender {

    

    JLModel_Device *deviceModel = [mCmdManager outputDeviceModel];
    NSMutableData *mData = [NSMutableData new];
    if (deviceModel.smallFileWayType == JL_SmallFileWayTypeNO) {
        /*--- 原来通讯流程 ---*/
        [mCmdManager.mFileManager setCurrentFileHandleType:[JLFileTransferHelper getContactTargetDev:deviceModel]];
        [mCmdManager.mFileManager cmdFileReadContentWithName:@"CALL.txt" Result:^(JL_FileContentResult result,
                                                                                  uint32_t size, NSData * _Nullable
                                                                                  data,float progress) {
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
                [JL_Tools mainTask:^{
                    [self outputContactsListData:mData];
                    [self->subTableView reloadData];
                }];

            } else if (result == JL_FileContentResultCancel) {
                NSLog(@"---> 读取【Call.txt】取消");
            } else if (result == JL_FileContentResultFail) {
                NSLog(@"---> 读取【Call.txt】失败");
            } else if (result == JL_FileContentResultNull) {
                NSLog(@"---> 读取【Call.txt】文件为空");
            } else if (result == JL_FileContentResultDataError) {
                NSLog(@"---> 读取【Call.txt】数据出错");
            }
        }];
    }else{
        
        [JL_Tools subTask:^{
            __block JLModel_SmallFile *smallFile = nil;
            
            /*--- 查询小文件列表 ---*/
            [self->mCmdManager.mSmallFileManager cmdSmallFileQueryType:JL_SmallFileTypeContacts
                                                      Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
                if (array.count > 0) smallFile = array[0];
                [self->threadTimer_0 threadContinue];
            }];
            [self->threadTimer_0 threadWait];
            
            if (smallFile == nil) return;
            
            

            /*--- 读取小文件通讯录 ---*/
            [self->mCmdManager.mSmallFileManager cmdSmallFileRead:smallFile
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
                            [self->subTableView reloadData];
                        }];
                    }
                }
            }];
        }];
    }
}

- (IBAction)btnAddContact:(id)sender {
    PersonModel *model = [PersonModel new];
    model.fullName = @"张三李四";
    model.phoneNum = @"123456789";
    [dataArray addObject:model];
    
    [self syncContactsListToDevice];
}

- (IBAction)btnDelContact:(id)sender {
    if (selectIndex >= 0) {
        [dataArray removeObjectAtIndex:selectIndex];
        [self syncContactsListToDevice];
        selectIndex = -1;
    }
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
    PersonModel *model = dataArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",model.fullName,model.phoneNum];

    if (indexPath.row == selectIndex) {
        cell.textLabel.textColor = [UIColor blueColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectIndex = indexPath.row;
    [tableView reloadData];
        
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
        
        PersonModel *model = [[PersonModel alloc] init];
        model.fullName = nameStr;
        model.phoneNum = numberStr;
        
        [dataArray addObject:model];
    }
}

- (void)syncContactsListToDevice {
    JLModel_Device *deviceModel = [mCmdManager outputDeviceModel];

    NSString *path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"CALL.TXT"];
    [JL_Tools writeData:[ContactsTool setContactsToData:dataArray] fillFile:path];
    
    
    if (deviceModel.smallFileWayType == JL_SmallFileWayTypeNO) {
        /*--- 原来通讯流程 ---*/
        if ([JLFileTransferHelper getContactTargetDev:deviceModel] == JL_CardTypeFLASH2) {
            [JLFileTransferHelper sendContactFileToFlashWithFileName:@"CALL.TXT"
                                                         withManager:mCmdManager
                                                          withResult:^(JLFileTransferOperateType type, float progress) {
                if (type == JLFileTransferOperateTypeStart) {
                    [TipView startLoadingView:kJL_TXT("同步中...") Delay:8.0];
                }
                if (type == JLFileTransferOperateTypeSuccess) {
                    NSLog(@"CALL.TXT 传输成功");
                    [TipView setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                    [JL_Tools mainTask:^{
                        [self->subTableView reloadData];
                    }];
                }
            }];
        } else {
            [JLFileTransferHelper sendContactFileWithFileName:@"CALL.TXT"
                                                  withManager:mCmdManager
                                                   withResult:^(JLFileTransferOperateType type, float progress) {
                if (type == JLFileTransferOperateTypeStart) {
                    [TipView startLoadingView:kJL_TXT("同步中...") Delay:8.0];
                }
                if (type == JLFileTransferOperateTypeSuccess) {
                    NSLog(@"CALL.TXT 传输成功");
                    [TipView setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                    [JL_Tools mainTask:^{
                        [self->subTableView reloadData];
                    }];
                }
            }];
        }
    } else {
        /*--- 小文件方式传输通讯录 ---*/
        [self smallFileSyncContactsListWithPath:path];
    }
}

-(void)smallFileSyncContactsListWithPath:(NSString*)path{
    [TipView startLoadingView:kJL_TXT("同步中...") Delay:8.0];
    [JL_Tools subTask:^{
        __block JLModel_SmallFile *smallFile = nil;
        
        /*--- 查询小文件列表 ---*/
        [self->mCmdManager.mSmallFileManager cmdSmallFileQueryType:JL_SmallFileTypeContacts
                                                  Result:^(NSArray<JLModel_SmallFile *> * _Nullable array) {
            if (array.count > 0) smallFile = array[0];
            [self->threadTimer_1 threadContinue];
        }];
        [self->threadTimer_1 threadWait];
        
        
        /*--- 先删通讯录 ---*/
        if (smallFile != nil) {
            __block JL_SmallFileOperate status_del = 0;
            [self->mCmdManager.mSmallFileManager cmdSmallFileDelete:smallFile
                                                         Result:^(JL_SmallFileOperate status) {
                status_del = status;
                [self->threadTimer_1 threadContinue];
            }];
            [self->threadTimer_1 threadWait];
            
            if (status_del != JL_SmallFileOperateSuceess) {
                [JL_Tools mainTask:^{
                    NSLog(@"--->小文件 CALL.TXT 传输失败");
                    [TipView setLoadingText:kJL_TXT("同步失败！") Delay:0.5f];
                }];
                return;
            }
        }
        
        /*--- 小文件传输文件 ---*/
        NSData *pathData = [NSData dataWithContentsOfFile:path];
        [self->mCmdManager.mSmallFileManager cmdSmallFileNew:pathData Type:JL_SmallFileTypeContacts
                                                  Result:^(JL_SmallFileOperate status, float progress,
                                                           uint16_t fileID) {
            [JL_Tools mainTask:^{


                if (status == JL_SmallFileOperateSuceess) {
                    NSLog(@"--->小文件 CALL.TXT 传输成功");
                    [TipView setLoadingText:kJL_TXT("同步完成！") Delay:0.5f];
                    [JL_Tools mainTask:^{
                        [self->subTableView reloadData];
                    }];
                }
                if (status != JL_SmallFileOperateSuceess &&
                    status != JL_SmallFileOperateDoing){
                    NSLog(@"--->小文件 CALL.TXT 传输失败");
                    [TipView setLoadingText:kJL_TXT("同步失败！") Delay:0.5f];
                }
            }];
        }];
    }];
}




@end
