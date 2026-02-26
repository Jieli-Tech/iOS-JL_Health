//
//  HeartBeatDataView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HeartBeatDataView;
@protocol HeartBeatDataViewDelegate <NSObject>

-(void)didSelected:(HeartBeatDataView *)hbdv;

@end

@interface HeartBeatDataView : UIView

-(void)hbMsgLabel:(NSString *)main Units:(NSString *)u;

@property(nonatomic, weak)id<HeartBeatDataViewDelegate> delegate;
@property(nonatomic, strong) UILabel *heartLab;
-(void)shadows:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
