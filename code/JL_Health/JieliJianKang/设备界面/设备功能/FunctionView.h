//
//  FunctionView.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/23.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "DevicesSubView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FunctionView : UIView

@property(nonatomic,assign)CGFloat viewHeight;

@property(nonatomic,weak)DevicesSubView *subView;

-(void)initByArray;
@end


NS_ASSUME_NONNULL_END
