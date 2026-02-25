//
//  LocalMusicVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/11.
//

#import "LocalMusicVC.h"
#import "JL_RunSDK.h"
#import "MindListView.h"
#import "TransferView.h"

@interface LocalMusicVC () <MindListMusicDelegate, TransferViewDelegate> {
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIView  *subTitleView;
    __weak IBOutlet UILabel *subTitle;
    __weak IBOutlet UIButton *selectAllBtn;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    MindListView *mindListView;
    TransferView *transView;
    float sw;
    float sh;
}

@end

@implementation LocalMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [mindListView scrollToNowMusic];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)addNote{
    [JL_Tools add:@"CLEAN_MUSIC_LIST" Action:@selector(showSelectAllBtn) Own:self];
    [JL_Tools add:@"CLEAN_MUSIC_LIST2" Action:@selector(showCancelBtn) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    sw = [DFUITools screen_2_W];
    sh = [DFUITools screen_2_H];
    
    selectAllBtn.frame  = CGRectMake(sw-16-44, kJL_HeightStatusBar, 44, 44);
    selectAllBtn.hidden = NO;
    
    cancelBtn.frame  = CGRectMake(sw-16-44, kJL_HeightStatusBar, 44, 44);
    cancelBtn.hidden = YES;
    
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    subTitle.text = kJL_TXT("本地音乐");
    subTitle.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    subTitle.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    mindListView = [[MindListView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+15, [DFUITools screen_2_W],  [DFUITools screen_2_H]-kJL_HeightNavBar-15)];
    mindListView.delegate = self;
    [self.view addSubview:mindListView];
    
    transView = [[TransferView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    transView.delegate = self;
    [self.view addSubview:transView];
    transView.hidden = YES;
}



- (IBAction)actionExitAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelBtn:(UIButton *)sender {
    cancelBtn.hidden = YES;
    selectAllBtn.hidden = NO;
    [mindListView cancelMusic];
}

- (IBAction)selectAllBtn:(UIButton *)sender {
    cancelBtn.hidden = NO;
    selectAllBtn.hidden = YES;
    [mindListView selectAll];
}

-(void)showSelectAllBtn{
    cancelBtn.hidden = YES;
    selectAllBtn.hidden = NO;
}

-(void)showCancelBtn{
    cancelBtn.hidden = NO;
    selectAllBtn.hidden = YES;
}

#pragma mark - MindListMusicDelegate

-(void)editMusic{
//    selectAllBtn.hidden = NO;
//    cancelBtn.hidden = YES;
}

-(void)transferMusicWithSelectArray:(NSArray<NSString *> *)selectArray {
    transView.hidden = NO;
    transView.totalCount = (int)selectArray.count;
    transView.selectArray = selectArray;
}

#pragma mark - TransferViewDelegate

- (void)transferAllMusicFinish {
    if ([self.delegate respondsToSelector:@selector(transferAllMusicFinish)]) {
        [self.delegate transferAllMusicFinish];
    }
}

@end
