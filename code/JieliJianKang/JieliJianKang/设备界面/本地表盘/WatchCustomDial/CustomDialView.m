//
//  CustomDialView.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import "CustomDialView.h"
#import "CustomDialCell.h"
#import "CustomDialEditVC.h"

@interface CustomDialView ()<UICollectionViewDataSource,UICollectionViewDelegate,CustomDialCellDelegate>{
    UICollectionView *customerView;
    UICollectionViewFlowLayout *flowLayout;
    UILabel *titleLabel;
    UIButton *btnMore;
    
    BOOL isEditing;
    NSMutableArray *itemsArray;
    CustomDialCellModel *mCustomDialCellModel;
}
@end

@implementation CustomDialView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initData];

        titleLabel = [[UILabel alloc] init];
        titleLabel.text = kJL_TXT("自定义表盘");
        titleLabel.font = FontMedium(16);
        titleLabel.textColor = [JLColor colorWithString:@"#242424"];
        titleLabel.adjustsFontSizeToFitWidth = true;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(13);
            make.left.equalTo(self).offset(16);
            make.height.equalTo(@22);
        }];
        
        btnMore = [[UIButton alloc] init];
        [btnMore setTitle:kJL_TXT("管理") forState:UIControlStateNormal];
        [btnMore setTitleColor:[JLColor colorWithString:@"#558CFF"] forState:UIControlStateNormal];
        btnMore.titleLabel.font = FontMedium(13);
        [btnMore addTarget:self action:@selector(btnMoreClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnMore];
        [btnMore mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(self).offset(-16);
            make.height.equalTo(@20);
        }];
        
        CGFloat w = [UIScreen mainScreen].bounds.size.width / 3.1;
        
        flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(w, 146);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 0;
        customerView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [customerView registerClass:[CustomDialCell class] forCellWithReuseIdentifier:@"CustomDialCell"];
        customerView.delegate = self;
        customerView.dataSource = self;
        customerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:customerView];
        
        [customerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(20);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadData) name:@"ReloadCustomDial" object:nil];
        [self addNote];
    }
    
    return self;
}


-(void)initData{
    isEditing = false;
    
    itemsArray = [[NSMutableArray alloc] init];
    NSString *basicPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, true) firstObject];
    basicPath = [basicPath stringByAppendingPathComponent:@"CustomDial"];
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basicPath error:nil];
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    fmDate.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1 = [[(NSString *)obj1 componentsSeparatedByString:@"."] firstObject];
        NSString *str2 = [[(NSString *)obj2 componentsSeparatedByString:@"."] firstObject];
        NSDate *dt1 = [fmDate dateFromString:str1];
        NSDate *dt2 = [fmDate dateFromString:str2];
        return [dt1 compare:dt2] == NSOrderedAscending;
        
    }];
    
    CustomDialCellModel *model = [CustomDialCellModel new];
    model.index = 0;
    model.image = [UIImage imageNamed:@"watch_icon_add"];
    [itemsArray addObject:model];
    
    for (int i = 0;i<arr.count;i++) {
        NSString *str = arr[i];
        CustomDialCellModel *model = [CustomDialCellModel new];
        model.index = i+1;
        model.filePath = [basicPath stringByAppendingPathComponent:str];
        [itemsArray addObject:model];
    }
}


-(void)btnMoreClick{
    isEditing = !isEditing;
    if (isEditing){
        [btnMore setTitle:kJL_TXT("完成") forState:UIControlStateNormal];
    }else{
        [btnMore setTitle:kJL_TXT("管理") forState:UIControlStateNormal];
    }
    [customerView reloadData];
}

-(void)handleReloadData{
    [self initData];
    [customerView reloadData];
}

//MARK: - collectionview delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return itemsArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomDialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomDialCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.deleteBtn.hidden = !isEditing;
    cell.model = itemsArray[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        _superVC.mPhotoView.hidden = false;
    }
}


//MARK: - cell delegate
- (void)customDialCell:(CustomDialCell *)cell didEditModel:(CustomDialCellModel *)model{
    CustomDialEditVC *vc = [CustomDialEditVC new];
    vc.model = model;
    [_superVC.navigationController pushViewController:vc animated:true];
}

- (void)customDialCell:(CustomDialCell *)cell didSelectModel:(CustomDialCellModel *)model{
    if (model.index == 0) {
        _superVC.mPhotoView.hidden = false;
    }
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    fmDate.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString *str = [fmDate stringFromDate:model.date];
    NSString *localIndex = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerUsing"];
    if ([localIndex isEqualToString:str]){
        return;
    }else{
        if(model.index!=0){
            [_superVC installDial:model.image];
            mCustomDialCellModel = model;
        }
    }
    
}

- (void)customDialCell:(CustomDialCell *)cell didDeleteModel:(CustomDialCellModel *)model{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:model.filePath error:nil];
    [self initData];
    [customerView reloadData];
}


-(void)gotoSelectImageForDial{
    
}

-(void)installDialSuccess{
    if(mCustomDialCellModel!=NULL){
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:mCustomDialCellModel.filePath error:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_INSTALL_DIAL_SUCCESS Action:@selector(installDialSuccess) Own:self];
}

- (void)dealloc {
    [JL_Tools remove:kUI_INSTALL_DIAL_SUCCESS Own:self];
}

@end
