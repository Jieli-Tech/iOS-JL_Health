//
//  JLTapView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/9.
//

#import "JLTapView.h"

@implementation JLTapView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (void)innerInit {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBtnFunc:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBtnFunc:)];
    [self addGestureRecognizer:longPressGestureRecognizer];
}

- (void)tapBtnFunc:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)longPressBtnFunc:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
}

@end
