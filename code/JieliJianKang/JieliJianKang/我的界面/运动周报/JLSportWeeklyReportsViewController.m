//
//  JLSportWeeklyReportsViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/15.
//

#import "JLSportWeeklyReportsViewController.h"
#import "JLSportWeeklyReportsSelectorTableViewCell.h"
#import "JLSportWeeklyReportsDataTableViewCell.h"
#import "JLSportMonlyReportsTableViewCell.h"
#import "JLSportWeeklyReportsTableViewCell.h"
#import "JLSqliteStep.h"
#import "NSDate+Tools.h"
#import "User_Http.h"
#import "PGBarChartDataModel.h"

@interface JLSportWeeklyReportsViewController () <JLSportWeeklyReportsSelectorTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *mTitleName;
@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSDate *currentWeekStartDate;
@property (strong, nonatomic) NSDate *currentWeekEndDate;

@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) JLSportWeeklyReportsSelectorTableViewCell *sportWeeklyReportsSelectorTableViewCell;
@property (strong, nonatomic) JLSportWeeklyReportsDataTableViewCell *sportWeeklyReportsDataTableViewCell;

@property (nonatomic, assign) NSInteger lastLastLastAllStep;   // 上上上周总步数
@property (nonatomic, assign) NSInteger lastLastAllStep;   // 上上周总步数

@property (nonatomic, assign) NSInteger lastWeekAchieveGoalStepDaysNum;   // 上周完成目标天数
@property (nonatomic, assign) NSInteger lastAllStep;   // 上周总步数
@property (nonatomic, assign) double lastTotalMileage;   // 上周总里程
@property (nonatomic, assign) double lastTotalConsumption;   // 上周总消耗

@property (nonatomic, assign) NSInteger achieveGoalStepDaysNum;   // 当周完成目标天数
@property (nonatomic, assign) NSInteger allStep;   // 总步数
@property (nonatomic, assign) double totalMileage;   // 总里程
@property (nonatomic, assign) double totalConsumption;   // 总消耗

@property (assign, nonatomic) NSInteger maxWeakAllStep;

@property (strong, nonatomic) NSMutableArray<PGBarChartDataModel *> *barChartDataModelArray;

@end

@implementation JLSportWeeklyReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mTitleName.text = kJL_TXT("运动周报");
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportWeeklyReportsSelectorTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportWeeklyReportsSelectorTableViewCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportWeeklyReportsDataTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportWeeklyReportsDataTableViewCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportMonlyReportsTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportMonlyReportsTableViewCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportWeeklyReportsTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportWeeklyReportsTableViewCell.class)];
    
    _currentDate = [NSDate date];
    StartAndEndDate *model = [_currentDate thisWeek];
    _currentWeekStartDate = model.start;
    _currentWeekEndDate = model.end;
//    NSLog(@"_currentDate:%@, start:%@, end:%@, %d", _currentDate, _currentWeekStartDate, _currentWeekEndDate, [User_Http shareInstance].userInfo.step);
    
    _index = 0;
    _barChartDataModelArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadDataWithStartDate:_currentWeekStartDate withEndDate:_currentWeekEndDate];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Private Methods

- (void)reloadDataWithStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    
    __weak typeof(self) weakSelf = self;
    [JLSqliteStep s_checkoutWtihStartDate:startDate.beforeWeek.beforeWeek.beforeWeek withEndDate:endDate.beforeWeek.beforeWeek.beforeWeek Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lastLastLastAllStep = 0;
            weakSelf.maxWeakAllStep = 0;
            // 计算上上上周总步数
            for (JL_Chart_MoveSteps *chart in charts) {
                weakSelf.lastLastLastAllStep += chart.allStep;
            }
            if (weakSelf.lastLastLastAllStep > weakSelf.maxWeakAllStep) {
                weakSelf.maxWeakAllStep = weakSelf.lastLastLastAllStep;
            }
        });
    }];
    [JLSqliteStep s_checkoutWtihStartDate:startDate.beforeWeek.beforeWeek withEndDate:endDate.beforeWeek.beforeWeek Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lastLastAllStep = 0;
            // 计算上上周总步数
            for (JL_Chart_MoveSteps *chart in charts) {
                weakSelf.lastLastAllStep += chart.allStep;
            }
            if (weakSelf.lastLastAllStep > weakSelf.maxWeakAllStep) {
                weakSelf.maxWeakAllStep = weakSelf.lastLastAllStep;
            }
        });
    }];
    // 需要先获取上一周的数据做对比
    [JLSqliteStep s_checkoutWtihStartDate:startDate.beforeWeek withEndDate:endDate.beforeWeek Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lastWeekAchieveGoalStepDaysNum = 0;
            weakSelf.lastAllStep = 0;
            weakSelf.lastTotalMileage = 0;
            weakSelf.lastTotalConsumption = 0;
            // 计算上周总步数，总里程，总消耗
            for (JL_Chart_MoveSteps *chart in charts) {
                weakSelf.lastAllStep += chart.allStep;
                NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
                if ([unitStr isEqualToString:@("英制")]) {
                    weakSelf.lastTotalMileage += (chart.totalMileage * 0.621);
                } else {
                    weakSelf.lastTotalMileage += chart.totalMileage;
                }
                weakSelf.lastTotalConsumption += chart.totalConsumption;
                if (chart.allStep >= [User_Http shareInstance].userInfo.step) {
                    weakSelf.lastWeekAchieveGoalStepDaysNum++;
                }
            }
            if (weakSelf.lastAllStep > weakSelf.maxWeakAllStep) {
                weakSelf.maxWeakAllStep = weakSelf.lastAllStep;
            }
        });
    }];
    [JLSqliteStep s_checkoutWtihStartDate:startDate withEndDate:endDate Result:^(NSArray<JL_Chart_MoveSteps *> * _Nonnull charts) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.achieveGoalStepDaysNum = 0;
            weakSelf.allStep = 0;
            weakSelf.totalMileage = 0;
            weakSelf.totalConsumption = 0;
            // 计算本周总步数，总里程，总消耗
            for (int i = 0; i < charts.count; i++) {
                JL_Chart_MoveSteps *chart = charts[i];
                weakSelf.allStep += chart.allStep;
                NSString *unitStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
                if ([unitStr isEqualToString:@("英制")]) {
                    weakSelf.totalMileage += (chart.totalMileage*0.621);
                } else {
                    weakSelf.totalMileage += chart.totalMileage;
                }
                weakSelf.totalConsumption += chart.totalConsumption;
                if (chart.allStep >= [User_Http shareInstance].userInfo.step) {
                    weakSelf.achieveGoalStepDaysNum++;
                }
            }
            if (weakSelf.allStep > weakSelf.maxWeakAllStep) {
                weakSelf.maxWeakAllStep = weakSelf.allStep;
            }
            // 绘制每天的折线图
            NSArray *bottomArray = @[kJL_TXT("我的周一"), kJL_TXT("我的周二"), kJL_TXT("我的周三"), kJL_TXT("我的周四"), kJL_TXT("我的周五"), kJL_TXT("我的周六"), kJL_TXT("我的周日")];
            [weakSelf.barChartDataModelArray removeAllObjects];
            for (int i = 0; i < 7; i++) {
                NSInteger finalStep = 0;
                for (JL_Chart_MoveSteps *chart in charts) {
                    if (([chart.stepCountlist.firstObject.startDate witchWeekDay] - 1) == i) {
                        finalStep = chart.allStep;
                    }
                }
                PGBarChartDataModel *dataModel = [[PGBarChartDataModel alloc] initWithLabel:bottomArray[i] value:finalStep index:i unit:@""];
                [weakSelf.barChartDataModelArray addObject:dataModel];
            }
            
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)setNextButtonStatus {
    if (_index >= 0) {
        [_sportWeeklyReportsSelectorTableViewCell setNextBtnEnable:NO];
    } else {
        [_sportWeeklyReportsSelectorTableViewCell setNextBtnEnable:YES];
    }
}

- (IBAction)backBtnFunc:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - JLSportWeeklyReportsSelectorTableViewCellDelegate

- (void)onClickLastWeekBtnFunc {
    _currentDate = [_currentDate beforeWeek];
    StartAndEndDate *model = [_currentDate thisWeek];
    _currentWeekStartDate = model.start;
    _currentWeekEndDate = model.end;
//    NSLog(@"_currentDate:%@, start:%@, end:%@", _currentDate, _currentWeekStartDate, _currentWeekEndDate);
    
    _index--;
    [self setNextButtonStatus];
    
    [self reloadDataWithStartDate:_currentWeekStartDate withEndDate:_currentWeekEndDate];
}

- (void)onClickNextWeekBtnFunc {
    _currentDate = [_currentDate nextWeek];
    StartAndEndDate *model = [_currentDate thisWeek];
    _currentWeekStartDate = model.start;
    _currentWeekEndDate = model.end;
//    NSLog(@"_currentDate:%@, start:%@, end:%@", _currentDate, _currentWeekStartDate, _currentWeekEndDate);
    
    _index++;
    [self setNextButtonStatus];
    
    [self reloadDataWithStartDate:_currentWeekStartDate withEndDate:_currentWeekEndDate];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        JLSportWeeklyReportsDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportWeeklyReportsDataTableViewCell.class)];
        if (cell == nil) {
            cell = [[JLSportWeeklyReportsDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportWeeklyReportsDataTableViewCell.class)];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.step = self.allStep;
        cell.stepChange = self.allStep - self.lastAllStep;
        cell.distance = self.totalMileage;
        cell.distanceChange = self.totalMileage - self.lastTotalMileage;
        cell.calories = self.totalConsumption;
        cell.caloriesChange = self.totalConsumption - self.lastTotalConsumption;
        
        return cell;
    } else if (indexPath.row == 2) {
        JLSportMonlyReportsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportMonlyReportsTableViewCell.class)];
        if (cell == nil) {
            cell = [[JLSportMonlyReportsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportMonlyReportsTableViewCell.class)];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell configureCellWithTextArray:@[[NSString stringWithFormat:@"%@-%@", self.currentWeekStartDate.beforeWeek.beforeWeek.beforeWeek.toMMdd2, self.currentWeekEndDate.beforeWeek.beforeWeek.beforeWeek.toMMdd2], [NSString stringWithFormat:@"%@-%@", self.currentWeekStartDate.beforeWeek.beforeWeek.toMMdd2, self.currentWeekEndDate.beforeWeek.beforeWeek.toMMdd2], [NSString stringWithFormat:@"%@-%@", self.currentWeekStartDate.beforeWeek.toMMdd2, self.currentWeekEndDate.beforeWeek.toMMdd2], [NSString stringWithFormat:@"%@-%@", self.currentWeekStartDate.toMMdd2, self.currentWeekEndDate.toMMdd2]] withDataArray:@[@(self.lastLastLastAllStep), @(self.lastLastAllStep), @(self.lastAllStep), @(self.allStep)] withMaxData:self.maxWeakAllStep];
        return cell;
    } else if (indexPath.row == 3) {
        
        JLSportWeeklyReportsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportWeeklyReportsTableViewCell.class)];
        if (cell == nil) {
            cell = [[JLSportWeeklyReportsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportWeeklyReportsTableViewCell.class)];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell configureCellWithBarChartDataModelArray:self.barChartDataModelArray withGoalStep:[User_Http shareInstance].userInfo.step];
        return cell;
    }
    JLSportWeeklyReportsSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportWeeklyReportsSelectorTableViewCell.class)];
    if (cell == nil) {
        cell = [[JLSportWeeklyReportsSelectorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportWeeklyReportsSelectorTableViewCell.class)];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = self;
    _sportWeeklyReportsSelectorTableViewCell = cell;
    _sportWeeklyReportsSelectorTableViewCell.title = [NSString stringWithFormat:@"%@-%@", self.currentWeekStartDate.toMMdd3, self.currentWeekEndDate.toMMdd3];
    _sportWeeklyReportsSelectorTableViewCell.achieveGoalDays = self.achieveGoalStepDaysNum;
    _sportWeeklyReportsSelectorTableViewCell.compareLastWeekAchieveUpDays = self.achieveGoalStepDaysNum - self.lastWeekAchieveGoalStepDaysNum;
    [self setNextButtonStatus];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 116;
    } else if (indexPath.row == 2) {
        return 160;
    } else if (indexPath.row == 3) {
        return 170;
    }
    return 235;
}

@end
