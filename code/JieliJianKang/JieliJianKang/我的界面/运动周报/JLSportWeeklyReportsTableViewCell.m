//
//  JLSportWeeklyReportsTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/16.
//

#import "JLSportWeeklyReportsTableViewCell.h"

@interface JLSportWeeklyReportsTableViewCell () <PGBarChartDataSource>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) NSMutableArray<PGBarChartDataModel *> *barChartDataModelArray;

@end

@implementation JLSportWeeklyReportsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _barChartDataModelArray = [NSMutableArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithBarChartDataModelArray:(NSMutableArray<PGBarChartDataModel *> *)barChartDataModelArray withGoalStep:(int)goalStep {
    self.containerView.layer.cornerRadius = 12;
    [self.containerView removeSubviews];
    
    _barChartDataModelArray = barChartDataModelArray;
    PGBarChart *barChart = [[PGBarChart alloc] initWithFrame:CGRectMake(0, 0, self.containerView.width, self.containerView.height)];
    barChart.barNormalColor = kDF_RGBA(163, 134, 249, 1.0);
    barChart.barWidth = 14;
    barChart.bottomLabelFontSize = 12;
    barChart.bottomLabelFontColor = [JLColor colorWithString:@"#A0A0A0"];
    barChart.verticalFontColor = kDF_RGBA(150, 150, 150, 1.0);
    barChart.verticalFontSize = 12;
    barChart.bottomLineHeight = 1;
    barChart.bottomLineColor = [JLColor colorWithString:@"#A0A0A0"];
    barChart.leftLineWidth = 1;
    barChart.leftBackgroundColor = kDF_RGBA(230, 230, 230, 1.0);
    barChart.horizontalLineHeight = 1;
    barChart.horizontalLineBackgroundColor = kDF_RGBA(230, 230, 230, 10);
    barChart.lineCap = PGBarLineCapRound;
    barChart.goalNum = goalStep;
    barChart.goalNumText = [NSString stringWithFormat:kJL_TXT("目标%d步"), goalStep];
    [barChart setDataSource:self];
    [barChart setBottomLineHeight:0.8f];
    [barChart setBottomLineColor:[JLColor colorWithString:@"#E7E7E7"]];
    [self.containerView addSubview:barChart];
}

#pragma mark - PGBarChartDataSource

- (NSArray *)charDataModels {
    return self.barChartDataModelArray;
}

@end
