//
//  CustomWatchVC.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/16.
//

#import "CustomWatchVC.h"
#import "JLHeadFile.h"
#import "TipView.h"


@interface CustomWatchVC ()<UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate>{
    
    __weak IBOutlet UILabel *watchNameTxt;
    __weak IBOutlet UILabel *bgNameTxt;
    __weak IBOutlet UIImageView *subImageView;
    
    NSString        *mWatchName;
    NSString        *watchBinName;
    
    
    QCY_BLEApple    *bt_ble;
    JL_ManagerM     *mCmdManager;
    NSArray         *dataArray;
    
    JL_Timer        *actionTimer;
}

@end

@implementation CustomWatchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    actionTimer = [[JL_Timer alloc] init];
    
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
        self->dataArray = array;
        NSLog(@"Fats List ---> %@",self->dataArray);
        
        [JL_Tools mainTask:^{
            [TipView removeLoading];
            [DFUITools showText:@"获取成功！" onView:self.view delay:1.0];
            [self getWatchFace];
        }];
    }];
}

-(void)getWatchFace{
    [JL_Tools subTask:^{
        [self->mCmdManager.mFlashManager cmdWatchFlashPath:nil Flag:JL_DialSettingReadCurrentDial
                                              Result:^(uint8_t flag, uint32_t size,
                                                       NSString * _Nullable path,
                                                       NSString * _Nullable describe) {
            [JL_Tools mainTask:^{
                NSString *txt = @"获取表盘成功!";
                if (flag != 0) txt = @"获取表盘失败~";
                [DFUITools showText:txt onView:self.view delay:1.0];

                if (flag == 0) {
                    NSLog(@"当前表盘 ---> %@",path);
                    self->mWatchName = path;
                    self->watchNameTxt.text = [NSString stringWithFormat:@"表盘：%@",path];
                }else{
                    self->mWatchName = @"空";
                    self->watchNameTxt.text = [NSString stringWithFormat:@"表盘：%@",path];
                }
                [self->actionTimer threadContinue];
            }];
        }];
        
        
        [self->actionTimer threadWait];
        if (self->mWatchName.length == 0 || [self->mWatchName isEqual:@"/null"]) return;
        
                
        [self->mCmdManager.mFlashManager cmdWatchFlashPath:self->mWatchName Flag:JL_DialSettingGetDialName
                                                    Result:^(uint8_t flag, uint32_t size,
                                                             NSString * _Nullable path,
                                                             NSString * _Nullable describe) {
            [JL_Tools mainTask:^{
                NSString *txt = @"读取背景成功!";
                if (flag != 0) txt = @"读取背景失败~";
                [DFUITools showText:txt onView:self.view delay:1.0];
                
                if (flag == 0) {
                    NSLog(@"当前背景 ---> %@",path);
                    NSString *name = [path lastPathComponent].uppercaseString;
                    
                    self->bgNameTxt.text = [NSString stringWithFormat:@"背景：%@",name];
                    if ([path isEqual:@"null"]) {
                        [self newBgName:self->mWatchName];
                    }else{
                        self->watchBinName = name;// [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    }
                }else{
                    self->bgNameTxt.text = [NSString stringWithFormat:@"背景：%@",path];
                    
                    [self newBgName:self->mWatchName];
                }
            }];
        }];
    }];
}

-(void)newBgName:(NSString*)name{
    NSString *wName = [name stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([wName isEqual:@"WATCH"]) {
        watchBinName = @"BGP_W000";
    } else {
        NSString *txt = [wName stringByReplacingOccurrencesOfString:@"WATCH" withString:@""];
        NSInteger strLen = txt.length;
        if (strLen == 1) watchBinName = [NSString stringWithFormat:@"BGP_W00%@", txt];
        if (strLen == 2) watchBinName = [NSString stringWithFormat:@"BGP_W0%@", txt];
        if (strLen == 3) watchBinName = [NSString stringWithFormat:@"BGP_W%@", txt];
    }
}

- (IBAction)btn_takePhoto:(id)sender {
    //创建UIImagePickerController实例
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
//    UIImage *image1 = [UIImage imageWithContentsOfFile:[JL_Tools find:@"ImageTest.HEIC"]];
//    NSLog(@"图片分辨率 ---> w:%.1f h:%.1f",image1.size.width,image1.size.height);
//    NSData *imageData1 = [BitmapTool resizeImage:image1 andResizeTo:CGSizeMake(240, 240)];
//    [self changeImageToBin1:imageData1];
//    return;

    [TipView startLoadingView:@"添加照片..." Delay:60*8];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"图片分辨率 ---> w:%.1f h:%.1f",image.size.width,image.size.height);
    subImageView.image = image;

 
    JLModel_Device *model = [mCmdManager outputDeviceModel];
    uint16_t dev_W = model.flashInfo.mScreenWidth;
    uint16_t dev_H = model.flashInfo.mScreenHeight;
    if (dev_W == 0) dev_W = 240;
    if (dev_H == 0) dev_H = 240;
    
    NSData *imageData = [BitmapTool resizeImage:image andResizeTo:CGSizeMake(dev_W, dev_H)];
    [self changeImageToBin:imageData];
    
    if ([dataArray containsObject:watchBinName]) {
        [self replaceCustomWatch];//更新自定义图片
    } else {
        [self addCustomWatch];//增加自定义图片
    }
}

-(void)changeImageToBin:(NSData*)imageData{

    NSString *bmpPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];

    [JL_Tools removePath:bmpPath];
    [JL_Tools removePath:binPath];

    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:watchBinName];

    UIImage *image = [UIImage imageWithData:imageData];
    int width = image.size.width;
    int height = image.size.height;
    NSLog(@"压缩分辨率 ---> w:%df h:%df",width,height);

    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:image];
    [JL_Tools writeData:bitmap fillFile:bmpPath];

    JLModel_Device *model = [mCmdManager outputDeviceModel];
    if (model.sdkType == JL_SDKType701xWATCH) {
        /*--- BR28压缩算法 ---*/
        //br28_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        
        //带有alpha的图片转换
        br28_btm_to_res_path_with_alpha((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        NSLog(@"--->Br28 BIN【%@】is OK!", watchBinName);
    }else{
        /*--- BR23压缩算法 ---*/
        br23_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
        NSLog(@"--->Br23 BIN【%@】is OK!", watchBinName);
    }
}

//-(void)changeImageToBin1:(NSData*)imageData{
//
//    NSString *bmpPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
//    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"watchbin.bin"];
//
//    [JL_Tools removePath:bmpPath];
//    [JL_Tools removePath:binPath];
//
//    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"ios_test.bmp"];
//    [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"watchbin.bin"];
//
//    UIImage *image = [UIImage imageWithData:imageData];
//    int width = image.size.width;
//    int height = image.size.height;
//    NSLog(@"压缩分辨率 ---> w:%df h:%df",width,height);
//
//    NSData *bitmap = [BitmapTool convert_B_G_R_A_BytesFromImage:image];
//    [JL_Tools writeData:bitmap fillFile:bmpPath];
//
//    br28_btm_to_res_path((char*)[bmpPath UTF8String], width, height, (char*)[binPath UTF8String]);
//    NSLog(@"--->Br28 BIN【watchbin.bin】is OK!");
//}


- (void)addCustomWatch {
    NSString *wName = [NSString stringWithFormat:@"/%@", watchBinName];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];

    NSData *pathData = [NSData dataWithContentsOfFile:binPath];
    NSLog(@"-->添加自定义表盘的大小:%lld",(long long)pathData.length);

    [DialManager addFile:wName Content:pathData Result:^(DialOperateType type, float progress) {
        if (type == DialOperateTypeNoSpace) {
            [TipView setLoadingText:@"空间不足" Delay:0.5];
        }
        if (type == DialOperateTypeFail) {
            [TipView setLoadingText:@"添加失败" Delay:0.5];
        }
        if (type == DialOperateTypeDoing) {
            [TipView setLoadingText:[NSString stringWithFormat:@"%@:%.1f%%",@"添加进度",progress*100.0f]];
        }
        if (type == DialOperateTypeSuccess) {
            [TipView setLoadingText:@"添加完成" Delay:0.5];
            /*--- 更新缓存 ---*/
            [self activeCustomWatch];//设置自定义表盘
        }
    }];
}

- (void)replaceCustomWatch {
    NSString *wName = [NSString stringWithFormat:@"/%@",watchBinName];
    NSString *binPath = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:watchBinName];

    NSData *pathData = [NSData dataWithContentsOfFile:binPath];
    NSLog(@"-->跟新自定义表盘的大小:%lld",(long long)pathData.length);

    [DialManager repaceFile:wName Content:pathData
                     Result:^(DialOperateType type, float progress)
    {
        if (type == DialOperateTypeNoSpace) {
            [TipView setLoadingText:@"空间不足" Delay:0.5];
        }

        if (type == DialOperateTypeDoing) {
            NSString *txt = [NSString stringWithFormat:@"%@:%.1f%%",@"更新进度",progress*100.0f];
            [TipView setLoadingText:txt];
        }

        if (type == DialOperateTypeFail) {
            [TipView setLoadingText:@"更新失败" Delay:0.5];
        }

        if (type == DialOperateTypeSuccess) {
            [TipView setLoadingText:@"更新完成" Delay:0.5];
            [self activeCustomWatch];//设置自定义表盘
        }
    }];
}

- (void)activeCustomWatch {
    NSString *wName = [NSString stringWithFormat:@"/%@",watchBinName];
    [mCmdManager.mFlashManager cmdWatchFlashPath:wName Flag:JL_DialSettingActivateCustomDial
                                          Result:^(uint8_t flag, uint32_t size,
                                                   NSString * _Nullable path,
                                                   NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            [DFUITools showText:(flag != 0) ? @"设置失败" : @"设置成功" onView:self.view delay:1.0];
            
            self->bgNameTxt.text = [NSString stringWithFormat:@"背景：%@",self->watchBinName];
        }];
    }];
}


- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
