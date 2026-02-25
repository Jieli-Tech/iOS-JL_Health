//
//  SleepDetailCell.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SleepDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *actualLab;
@property (weak, nonatomic) IBOutlet UILabel *ReferenceLab;

@end

NS_ASSUME_NONNULL_END
