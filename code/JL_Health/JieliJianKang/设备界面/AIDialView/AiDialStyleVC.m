//
//  AiDialStyleVC.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/13.
//

#import "AiDialStyleVC.h"
#import "AiDialStyleCell.h"
#import "AIDialXFManager.h"


@interface AiDialStyleVC ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    UILabel *tipsLab;
    UICollectionView *collectView;
    NSArray *styleArr;
    NSArray *styleImgArr;
}
@end

@implementation AiDialStyleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kJL_TXT("AI表盘");
    [self initData];
    
    tipsLab = [UILabel new];
    tipsLab.text = @"风格选择";
    tipsLab.textColor = [JLColor colorWithString:@"#242424"];
    tipsLab.font = FontMedium(16);
    
    UICollectionViewFlowLayout *fl = [UICollectionViewFlowLayout new];
    CGFloat itemW = ([UIScreen mainScreen].bounds.size.width-40-15)/2;
    fl.itemSize = CGSizeMake(itemW, itemW+60);
    fl.minimumLineSpacing = 12;
    fl.minimumInteritemSpacing = 15;
    fl.scrollDirection = UICollectionViewScrollDirectionVertical;
    collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 40, 120, 160) collectionViewLayout:fl];
    
    collectView.delegate = self;
    collectView.dataSource = self;
    UINib *cell = [UINib nibWithNibName:@"AiDialStyleCell" bundle:nil];
    [collectView registerNib:cell forCellWithReuseIdentifier:@"AiDialStyleCell"];
    [collectView setShowsVerticalScrollIndicator:false];
    collectView.backgroundColor = [UIColor clearColor];
    
    
    [self.view addSubview:tipsLab];
    [self.view addSubview:collectView];
    
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.navigateView.mas_bottom).offset(13);
    }];
    [collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).inset(16);
        make.top.equalTo(tipsLab.mas_bottom).offset(13);
    }];
    
    [self addNote];
}



-(void)initData{
    styleImgArr = @[@"aiwatch_img_01",@"aiwatch_img_02",@"aiwatch_img_03",@"aiwatch_img_04",@"aiwatch_img_05",@"aiwatch_img_06"];
    styleArr = @[@"水墨画风格",@"写实风景风格",@"3D卡通风格",@"赛博朋克风格",@"折纸风格",@"水彩墨风格"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return styleArr.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AiDialStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AiDialStyleCell" forIndexPath:indexPath];
    cell.titleLab.text = styleArr[indexPath.row];
    cell.mainImgv.image = [UIImage imageNamed:styleImgArr[indexPath.row]];
    int selected = [[AIDialXFManager share] getType];
    if(selected == indexPath.row){
        [cell setSelectStatus:true];
    }else{
        [cell setSelectStatus:false];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [[AIDialXFManager share] saveTypeIndex:(int)indexPath.row];
    [[AIDialXFManager share] setAiDialStyle];
    
    [collectionView reloadData];
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

@end
