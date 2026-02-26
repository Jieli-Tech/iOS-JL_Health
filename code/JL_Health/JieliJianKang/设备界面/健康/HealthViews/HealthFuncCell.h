//
//  HealthFuncCell.h
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HealthFuncCell : UITableViewCell

@property(nonatomic,strong)UILabel *mainLab;

@property(nonatomic,strong)UILabel *secLab;

@property(nonatomic,strong)UILabel *rightLab;

@property(nonatomic,strong)UIImageView *imgv;

-(void)weatherHaveDetail:(BOOL)status;

+(instancetype)cellWithTable:(UITableView *)tableView;

@end


@interface HealthCellObj : NSObject

@property(nonatomic,strong)NSString *mainStr;

@property(nonatomic,strong)NSString *secStr;

@property(nonatomic,assign,readonly)BOOL supportSec;

@property(nonatomic,strong)NSMutableAttributedString *secStrAttr;

@property(nonatomic,strong)UIViewController *vc;

+(instancetype)initBasic:(NSString *)main Sec:(NSString *)sec;

@end

NS_ASSUME_NONNULL_END
