//
//  DialModel.m
//  JieliJianKang
//
//  Created by 李放 on 2022/5/9.
//

#import "DialModel.h"

@implementation DialModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    DialModel *model = [[self class] allocWithZone:zone];
    model.iconUrl       = self.iconUrl;
    model.bigIconUrl    = self.bigIconUrl;
    model.watchName     = self.watchName;
    model.mStatus       = self.mStatus;
    model.mPrice        = self.mPrice;
    model.dialIntroduce = self.dialIntroduce;
    model.dict          = self.dict;
    return model;
}

@end
