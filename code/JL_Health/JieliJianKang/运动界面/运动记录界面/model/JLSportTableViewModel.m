//
//  JLSportTableViewModel.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/11/17.
//

#import "JLSportTableViewModel.h"

@implementation JLSportTableViewModel

- (instancetype)initWithType:(JLSportTableViewModelType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

@end
