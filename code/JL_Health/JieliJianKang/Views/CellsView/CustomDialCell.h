//
//  CustomDialCell.h
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CustomDialCell;



@interface CustomDialCellModel : NSObject

@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)NSString *filePath;
@property(nonatomic,strong)NSString *originPath;
@property(nonatomic,strong)UIImage *originImage;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,readonly)NSDate *date;

@end

@protocol CustomDialCellDelegate <NSObject>

- (void)customDialCell:(CustomDialCell *)cell didSelectModel:(CustomDialCellModel *)model;

- (void)customDialCell:(CustomDialCell *)cell didEditModel:(CustomDialCellModel *)model;

- (void)customDialCell:(CustomDialCell *)cell didDeleteModel:(CustomDialCellModel *)model;

@end

@interface CustomDialCell : UICollectionViewCell

@property (strong, nonatomic)  UIView *centerView;
@property (strong, nonatomic)  UIImageView *centerImgv;
@property (strong, nonatomic)  UIButton *confirmBtn;
@property (strong, nonatomic)  UIButton *deleteBtn;

@property (weak, nonatomic) id<CustomDialCellDelegate> delegate;
@property(nonatomic,strong)CustomDialCellModel *model;

@end

NS_ASSUME_NONNULL_END
