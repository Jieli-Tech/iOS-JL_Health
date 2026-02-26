//
//  WatchDialTitleView.h
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^WatchDialTitleSelCallBack)(int index);

@interface WatchDialTitleView : UIView

@property(nonatomic,strong)WatchDialTitleSelCallBack callback;

-(void)handleBtnClick:(int)index;

@end

NS_ASSUME_NONNULL_END
