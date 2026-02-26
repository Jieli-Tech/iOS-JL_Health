//
//  DevicesViewCell.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol devCellDelegate <NSObject>

-(void)cellDidSelect:(NSInteger)itemIndex;

@end

@interface DevicesViewCell : UICollectionViewCell
@property (nonatomic,assign)NSInteger itemIndex;
@property (nonatomic,strong)NSString *deviceUUID;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *watchImgv;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UILabel *powerLab;
@property (weak, nonatomic) IBOutlet UIButton *reConnectBtn;
@property (weak, nonatomic) id<devCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
