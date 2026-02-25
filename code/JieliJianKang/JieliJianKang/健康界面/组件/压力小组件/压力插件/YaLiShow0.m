//
//  YaLiShow0.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/29.
//

#import "YaLiShow0.h"
#import "JL_RunSDK.h"

@implementation YaLiShow0

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"YaLiShow0"];
    if (self) {
        self.frame = frame;
        self.layer.cornerRadius = 12.0;
    }
    return self;
}

@end
