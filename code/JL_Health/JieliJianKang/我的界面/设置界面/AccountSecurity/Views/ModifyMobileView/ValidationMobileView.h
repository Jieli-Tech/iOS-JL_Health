//
//  ValidationMobileView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ValidationMobileViewPickDelegate <NSObject>
@optional
-(void)onValidationMobileCancel;
-(void)onValidationMobileSure;
@end

@interface ValidationMobileView : UIView

@property (nonatomic,assign)NSString *mobile;
@property(nonatomic,weak)id<ValidationMobileViewPickDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
