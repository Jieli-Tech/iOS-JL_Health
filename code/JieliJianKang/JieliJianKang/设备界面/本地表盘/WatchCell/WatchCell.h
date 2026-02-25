//
//  WatchCell.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/22.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, WatchCellType) {
    WatchCellTypeUsed       = 0x00, //正在使用
    WatchCellTypeUnUsed     = 0x01, //闲置(已存在设备中)
    WatchCellTypeUpdate     = 0x02, //更新
    WatchCellTypeDownload   = 0x03, //下载
    WatchCellTypePay        = 0x04, //需要购买
};

@class WatchCell;
@protocol WatchCellDelegate <NSObject>
@optional
-(void)onWatchCell:(WatchCell*)cell didSelectIndex:(NSInteger)index;
-(void)onWatchCell:(WatchCell*)cell didDeleteIndex:(NSInteger)index;
-(void)onWatchCell:(WatchCell*)cell didEditIndex:(NSInteger)index;
@end

@interface WatchCell : UICollectionViewCell
@property (weak, nonatomic) id<WatchCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton   *subEditBtn;
@property (weak, nonatomic) IBOutlet UIButton   *subBtn;
@property (assign,nonatomic)NSInteger           subIndex;
@property (weak, nonatomic) IBOutlet UILabel    *subLabel;
@property (weak, nonatomic) IBOutlet UILabel    *subLabel_1;
@property (weak, nonatomic) IBOutlet UIButton   *subDeleteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;
@property (assign,nonatomic)WatchCellType       subType;
@property (strong,nonatomic)NSDictionary        *infoDict;
@property (assign,nonatomic)float               buyPrice;
@end

NS_ASSUME_NONNULL_END
