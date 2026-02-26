//
//  MoreSettingCell.h
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import <UIKit/UIKit.h>
#import "HealthFuncCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SettingSwitchPtl <NSObject>

-(void)settingSwitchBack:(NSString *)mainStr onStatus:(BOOL)status;

@end

@interface MoreSettingCell : UITableViewCell

@property(nonatomic,strong)DFLabel *mainLab;

@property(nonatomic,strong)DFLabel *secLab;

@property(nonatomic,strong)DFLabel *rightLab;

@property(nonatomic,strong)UIImageView *imgv;

@property(nonatomic,strong)UISwitch *swView;

-(void)weatherHaveDetail:(BOOL)status;

+(instancetype)cellWithTable:(UITableView *)tableView;

@property(nonatomic,weak)id<SettingSwitchPtl> delegate;

@end



@interface MoreSettingObjc : HealthCellObj

@property(nonatomic,assign)BOOL hasSwView;

@property(nonatomic,assign)BOOL swStatus;


@end

NS_ASSUME_NONNULL_END
