//
//  DeviceCell.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/19.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DeviceCellDelegate <NSObject>
@optional
-(void)onDeviceCellSelectIndex:(NSInteger)index;
@end

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) id <DeviceCellDelegate>delegate;
@property (assign,nonatomic)NSInteger subIndex;
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (assign,nonatomic)BOOL    isConnect;

@end

NS_ASSUME_NONNULL_END
