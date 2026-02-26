//
//  IndexPlate.h
//  AiRuiSheng
//
//  Created by DFung on 2017/3/8.
//  Copyright © 2017年 DFung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

#define kMIN_GAP    35.0
#define kMIN_SCALE  1.0


@interface IndexPlate : UIView
@property(nonatomic,assign)NSInteger startPiont;

- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height;
- (UIImage *)snapshotImage;


@end
