//
//  JLSportHistoryViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/13.
//

#import "JLSportHistoryViewController.h"
#import "JLSportHistoryListTableViewCell.h"
#import "JLSportHistoryDetailViewController.h"
#import "MJRefresh.h"
#import "JLSqliteSportRunningRecord.h"

@interface JLSportHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *noRecordView;
@property (weak, nonatomic) IBOutlet UILabel *noRecordLabel;

@property (assign, nonatomic) NSInteger recordIndex;
@property (strong, nonatomic) NSMutableArray<JL_SportRecord_Chart *> *dataArray;

@end

@implementation JLSportHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    
    self.dataArray = [NSMutableArray array];
    
    self.titleLabel.text = kJL_TXT("运动记录");
    self.noRecordLabel.text = kJL_TXT("无记录");
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [JLColor colorWithString:@"#F6F7F8"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(JLSportHistoryListTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLSportHistoryListTableViewCell.class)];
    self.noRecordView.frame = CGRectMake(0, 0, self.tableView.width, self.tableView.height - 88);
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf refreshData];
        });
    }];
    [footer setTitle:kJL_TXT("上拉加载更多...") forState:MJRefreshStateIdle];
    [footer setTitle:kJL_TXT("松手开始加载") forState:MJRefreshStatePulling];
    [footer setTitle:kJL_TXT("加载中...") forState:MJRefreshStateRefreshing];
    self.tableView.mj_footer = footer;
    
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Private Methods
- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    [JLSqliteSportRunningRecord s_checkoutWtihStartIndex:weakSelf.recordIndex needResultCount:10 withIsASC:NO Result:^(NSArray<JL_SportRecord_Chart *> * _Nonnull charts) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            if (charts.count > 0) {
                weakSelf.recordIndex += charts.count;
                [weakSelf.dataArray addObjectsFromArray:charts];
                [weakSelf.tableView reloadData];
            }
            if (charts.count < 10) {
                weakSelf.tableView.mj_footer = nil;
            }
            if (weakSelf.dataArray.count <= 0) {
                weakSelf.tableView.tableHeaderView = self.noRecordView;
            } else {
                weakSelf.tableView.tableHeaderView = [UIView new];
            }
        });
    }];
}

#pragma mark - IBAction Methods

- (IBAction)backBtnFunc:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    JLSportHistoryListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLSportHistoryListTableViewCell.class)];
    if (cell == nil) {
        cell = [[JLSportHistoryListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLSportHistoryListTableViewCell.class)];
    }
    [cell configureCell];
    
    JL_SportRecord_Chart *chart = self.dataArray[indexPath.row];
    cell.chart = chart;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JL_SportRecord_Chart *chart = self.dataArray[indexPath.row];
    JLSportHistoryDetailViewController *detailViewController = [[JLSportHistoryDetailViewController alloc] init];
//    [JLSqliteSportRunningRecord s_checkoutWithSportID:chart.sport_id Result:^(JL_SportRecord_Chart * _Nullable chart) {
        detailViewController.chart = chart;
        [JLApplicationDelegate.navigationController pushViewController:detailViewController animated:YES];
//    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108;
}

@end
