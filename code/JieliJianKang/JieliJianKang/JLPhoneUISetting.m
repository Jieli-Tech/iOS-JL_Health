//
//  JLPhoneUISetting.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/3/3.
//

#import "JLPhoneUISetting.h"

@implementation JLPhoneUISetting

+(CGFloat)getNavHeight{
    CGFloat v = 44.0;
    v = v + [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    return  v;
}

@end
