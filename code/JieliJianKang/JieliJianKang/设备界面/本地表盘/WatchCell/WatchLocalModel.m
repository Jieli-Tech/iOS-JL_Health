//
//  WatchLocalModel.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/4/9.
//

#import "WatchLocalModel.h"

@implementation WatchLocalModel

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    WatchLocalModel *model = [[self class] allocWithZone:zone];
    model.mName      = self.mName;
    model.mVersionStr= self.mVersionStr;
    model.mVersionNum= self.mVersionNum;
    model.mInfoDict  = self.mInfoDict;
    model.mWatchType = self.mWatchType;
    return model;
}
@end
