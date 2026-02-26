//
//  JLSportMonlyReportsTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLSportMonlyReportsTableViewCell : UITableViewCell

- (void)configureCellWithTextArray:(NSArray *)timeLabArray withDataArray:(NSArray *)realDataArray withMaxData:(NSInteger)maxData;

@end

NS_ASSUME_NONNULL_END
