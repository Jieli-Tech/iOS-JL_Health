//
//  JLSportMonlyReportsTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/16.
//

#import "JLSportMonlyReportsTableViewCell.h"
#import <CoreDraw/CoreDraw.h>
#import "SportView.h"

@interface JLSportMonlyReportsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation JLSportMonlyReportsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithTextArray:(NSArray *)timeLabArray withDataArray:(NSArray *)realDataArray withMaxData:(NSInteger)maxData {
    self.containerView.layer.cornerRadius = 12;
    [self.containerView removeSubviews];
    
    SportView *sportView = [[SportView alloc] initWithFrame:CGRectMake(5, 0, self.containerView.width - 20, self.containerView.height)];
    [self.containerView addSubview:sportView];
    sportView.textArray = timeLabArray;
    NSMutableArray *arr = [NSMutableArray array];
    for (NSNumber *num in realDataArray) {
        [arr addObject:@([num integerValue]/maxData*100)];
    }
    sportView.dataArray = arr;
    sportView.realDataArray = realDataArray;
    [sportView loadUI];
}

@end
