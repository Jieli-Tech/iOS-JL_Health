//
//  ContrastNapView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/14.
//

#import "ContrastNapView.h"
#import "ContrastNapCell.h"

@implementation SleepNapModel

+(SleepNapModel *)makeNap:(NSDate *)start with:(JLWearSleepModel *)sleepModel{
    SleepNapModel *model = [SleepNapModel new];
    model.startDate = start;
    model.type = NapTimeType_Nap;
    model.length = sleepModel.duration;
    model.sleepModel = sleepModel;
    return model;
}
+(SleepNapModel *)makeAll:(NSTimeInterval)timer{
    SleepNapModel *model = [SleepNapModel new];
    model.type = NapTimeType_All;
    model.length = timer;
    return model;
}
+(SleepNapModel *)makeAve:(NSTimeInterval)timer{
    SleepNapModel *model = [SleepNapModel new];
    model.type = NapTimeType_Ave;
    model.length = timer;
    return model;
}

@end

@interface ContrastNapView()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tbView;
    NSArray<SleepNapModel *> *models;
}
@end

@implementation ContrastNapView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        tbView.rowHeight = 75.0;
        tbView.delegate = self;
        tbView.dataSource = self;
        tbView.backgroundColor = [UIColor whiteColor];
        [tbView registerNib:[UINib nibWithNibName:@"ContrastNapCell" bundle:nil] forCellReuseIdentifier:@"ContrastNapCell"];
        [tbView setUserInteractionEnabled:NO];
        [self addSubview:tbView];
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setArray:(NSArray<SleepNapModel *> *)model{
    models = model;
    if (model.count == 0) {
        self.hidden = YES;
    }else{
        self.hidden = NO;
    }
    [tbView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return models.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContrastNapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContrastNapCell" forIndexPath:indexPath];
    SleepNapModel *item = models[indexPath.row];
    if (item.type == NapTimeType_Nap) {
        cell.imgView.image = [UIImage imageNamed:@"sleep_small_nol"];
        cell.titleLab.text = kJL_TXT("零星小睡");
        NSDate *end = [NSDate dateWithTimeInterval:item.sleepModel.duration*60 sinceDate:item.startDate];
        NSString *titStr = [NSString stringWithFormat:@"%@-%@  %@",item.startDate.toHHmm,end.toHHmm,[self beString:item.sleepModel.duration]];
        cell.detailLab.text = titStr;
    }else if(item.type == NapTimeType_All){
        cell.imgView.image = [UIImage imageNamed:@"sleep_all_nol"];
        cell.titleLab.text = kJL_TXT("总睡眠");
        cell.detailLab.text = [self beString:item.length*60];
    }else{
        cell.imgView.image = [UIImage imageNamed:@"sleep_small_nol"];
        cell.titleLab.text = kJL_TXT("平均睡眠");
        cell.detailLab.text = [self beString:item.length*60];
    }
    return cell;
}

-(NSString *)beString:(NSInteger)length{
    int h = (int)length/3600;
    int m = ((int)length%3600)/60;
    if (h!=0) {
        return [NSString stringWithFormat:@"%d%@%d%@",h,kJL_TXT("小时"),m,kJL_TXT("分钟")];
    }else{
        return [NSString stringWithFormat:@"%d%@",m,kJL_TXT("分钟")];
    }
    
}





@end
