//
//  WatchLocalView.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/22.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "WatchMarket.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WatchLocalViewDelegate <NSObject>
@optional
-(void)onWatchLocalViewDidMoreBtn;

@end


@interface WatchLocalView : UIView

@property (strong,nonatomic) NSArray *dataArray;
@property (assign,nonatomic) BOOL isEdit;
@property (assign,nonatomic) BOOL isOperate;
@property (assign,nonatomic) BOOL isShowLbSmall;
@property (assign,nonatomic) BOOL isShowLbBig;
@property (weak,nonatomic)id<WatchLocalViewDelegate>delegate;
@property (weak,nonatomic)UIViewController *superVC;

- (void)setTitleText:(NSString*)text;

- (instancetype)initByFrame:(CGRect)frame;
- (void)reloadViewData;

@end

NS_ASSUME_NONNULL_END
