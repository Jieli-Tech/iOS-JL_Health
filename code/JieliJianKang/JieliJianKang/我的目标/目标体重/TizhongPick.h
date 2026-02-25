//
//  TizhongPick.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/8.
//

#import <UIKit/UIKit.h>

#define kTizhongPickGAP  40.0


NS_ASSUME_NONNULL_BEGIN

@class TizhongPick;
@protocol TizhongPickDelegate <NSObject>
@optional
-(void)onTizhongPick:(TizhongPick*)view didChange:(NSInteger)point;
-(void)onTizhongPick:(TizhongPick*)view didSelect:(NSInteger)point;
@end

@interface TizhongPick : UIView
@property(nonatomic,weak)id<TizhongPickDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame
                   StartPoint:(NSInteger)sPoint
                     EndPoint:(NSInteger)ePoint;

-(void)setTizhongPickPoint:(NSInteger)point;
@end

NS_ASSUME_NONNULL_END
