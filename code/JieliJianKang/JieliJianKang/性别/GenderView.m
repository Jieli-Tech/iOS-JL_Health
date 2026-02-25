//
//  GenderView.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import "GenderView.h"
#import "JL_RunSDK.h"
#import "GenderCell.h"

@interface GenderView()<UITableViewDelegate,UITableViewDataSource>{
    UIView *bgView;
    UIView *view1; //选择性别
    UILabel *genderLabel; //性别
    
    float sw;
    float sh;
    
    NSArray *funArray;
    UITableView *mTableView;
    NSInteger clickIndex;
}
@end

@implementation GenderView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
        [self initUI];
    }
    return self;
}

-(void)initUI{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
        
    view1 = [[UIView alloc] initWithFrame:CGRectMake(16, 240, sw-32, 180)];
    [self addSubview:view1];
    view1.backgroundColor = kDF_RGBA(255, 255, 255, 1);
    view1.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    view1.layer.shadowOffset = CGSizeMake(0,1);
    view1.layer.shadowOpacity = 1;
    view1.layer.shadowRadius = 10;
    view1.layer.cornerRadius = 16;
    
    genderLabel = [[UILabel alloc] init];
    genderLabel.frame = CGRectMake((sw-32)/2-45/2,20,70,25);
    genderLabel.numberOfLines = 0;
    genderLabel.text = kJL_TXT("性别");
    genderLabel.font =  [UIFont fontWithName:@"PingFangSC" size:18];
    genderLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    [view1 addSubview:genderLabel];
    
    funArray = @[kJL_TXT("男"),kJL_TXT("女")];
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, genderLabel.frame.origin.y+genderLabel.frame.size.height+27, sw-32-10, 100)];
    mTableView.rowHeight = 50;
    mTableView.delegate = self;
    mTableView.dataSource =self;
    mTableView.scrollEnabled = NO;
    [mTableView setSeparatorColor:[UIColor clearColor]];
    [mTableView registerNib:[UINib nibWithNibName:@"GenderCell" bundle:nil] forCellReuseIdentifier:@"GenderCell"];
    [view1 addSubview:mTableView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GenderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GenderCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[GenderCell alloc] init];
    }

    cell.mCellLabel.text = funArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(clickIndex == indexPath.row){
        cell.mCellImv.hidden = NO;
    }else{
        cell.mCellImv.hidden = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.hidden = YES;
    if ([_delegate respondsToSelector:@selector(didSelectGender:)]) {
        [_delegate didSelectGender:(int)indexPath.row];
    }

    clickIndex = indexPath.row;
    [mTableView reloadData];
}

-(void)setSelectValue:(int )selectValue{
    clickIndex = selectValue;
    [mTableView reloadData];
}

@end
