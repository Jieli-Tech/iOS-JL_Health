//
//  ChangeMobileView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ChangeMobileViewPickDelegate <NSObject>
@optional
-(void)onChangeMobileCancel;
-(void)onChangeMobileSure;
@end

@interface ChangeMobileView : UIView

@property (nonatomic,assign)NSString *mobile;
@property(nonatomic,weak)id<ChangeMobileViewPickDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
