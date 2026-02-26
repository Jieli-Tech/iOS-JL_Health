//
//  IndexPlate.h
//  AiRuiSheng
//
//  Created by kaka on 2021/2/23.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

#define kMIN_GAP  10.0


@interface IndexPlate : UIView
@property(nonatomic,assign)NSInteger startPiont;

- (instancetype)initWithIndex:(NSInteger)index WithHeight:(float)height;
- (UIImage *)snapshotImage;


@end
