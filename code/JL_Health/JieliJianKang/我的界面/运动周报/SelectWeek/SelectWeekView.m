//
//  SelectWeekView.m
//  ysyy_pat
//
//  Created by apple on 2016/10/11.
//  Copyright © 2016年 张博. All rights reserved.
//

#import "SelectWeekView.h"
#import "JL_RunSDK.h"

@interface SelectWeekView()<UITableViewDelegate,UITableViewDataSource>
{
    NSDate *_date;
}

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SelectWeekView
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _date = [NSDate date];
        
        self.dataArray = [self getWeek];
        
        [self setUI];
        
    }
    return self;
}

#pragma mark - 获取周
- (NSArray *)getWeek  {
    NSMutableArray *dataArr = [NSMutableArray array];
    
    for (int i = 0; i < 52; i++) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitDay
                                             fromDate:_date];
        // 得到星期几
        // 1(星期一) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
        NSInteger weekDay = [comp weekday];
        // 得到几号
        NSInteger day = [comp day];
        
//        NSInteger month = [comp month];
        
//        NSLog(@"weekDay:%ld   day:%ld  month : %ld",weekDay,day, month);
        
        // 计算当前日期和这周的星期一和星期天差的天数
        long firstDiff,lastDiff;
        if (weekDay == 1) {
            firstDiff = 0;
            lastDiff = 7;
        }else{
            firstDiff = [calendar firstWeekday] - weekDay  + 1;
            lastDiff = 8 - weekDay;
        }
        
//        NSLog(@"firstDiff:%ld   lastDiff:%ld",firstDiff,lastDiff);
        
        // 在当前日期(去掉了时分秒)基础上加上差的天数
        NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_date];
        [firstDayComp setDay:day + firstDiff];
        NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
        
        NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_date];
        [lastDayComp setDay:day + lastDiff];
        NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
        
        NSDateFormatter *formater = [EcTools cachedFm];
        [formater setDateFormat:@"yyyy-MM-dd"];
        
        NSString *str1 = [formater stringFromDate:firstDayOfWeek];
        NSString *str2 = [formater stringFromDate:lastDayOfWeek];
        
        NSString *weekStr = [NSString stringWithFormat:@"%@%@%@",str1,@"--",str2];
        
        [dataArr addObject:weekStr];
        
        NSDateComponents *tempComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_date];
        [tempComp setDay:day - 7];
        NSDate  *tempDate =  [calendar dateFromComponents:tempComp];
        
        _date = tempDate;
    }

    return dataArr;
}

#pragma mark - 布局
- (void)setUI {
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    topBgView.backgroundColor = [UIColor colorWithRed:246.f/ 255.f green:246.f/255.f blue:246.f/255.f alpha:1.f];
    [self addSubview:topBgView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 5, 40, 30);
    [cancelBtn setTitleColor:[UIColor colorWithRed:17.f/ 255.f green:103.f/255.f blue:207.f/255.f alpha:1.f]
 forState:UIControlStateNormal];
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [topBgView addSubview:cancelBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 150 - 20, 5, 150, 30)];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentRight;
    label.text = kJL_TXT("选择周间隔");
    label.textColor =  [UIColor colorWithRed:250.f/ 255.f green:156.f/255.f blue:49.f/255.f alpha:1.f];
    [topBgView addSubview:label];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, self.bounds.size.height - 40) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight  = 50;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:tableView];
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempStr = self.dataArray[indexPath.row];
    self.selectBlock(tempStr);
    [self dismiss];
}

#pragma mark - 显示/消失
- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    [window addSubview:self];
    /**
    //动画效果
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
    }];
    */
}

- (void)dismiss {

    /**
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
     */
    [self removeFromSuperview];
}


#pragma mark - 取消按钮点击
- (void)cancelButtonClick {
    [self dismiss];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


@end
