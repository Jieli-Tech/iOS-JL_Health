//
//  WeightShow.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/30.
//

#import "WeightShow.h"
#import "JL_RunSDK.h"

@implementation WeightShow

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"WeightShow"];
    if (self) {
        self.frame = frame;
        self.layer.cornerRadius = 12.0;
        
    }
    return self;
}

@end
