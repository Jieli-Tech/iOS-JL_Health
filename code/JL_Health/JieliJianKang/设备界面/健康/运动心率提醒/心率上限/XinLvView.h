//
//  XinLvView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/7/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol XinLvDelegate <NSObject>

-(void)xinLvAction:(NSString *) selectValue;
@end

@interface XinLvView : UIView
@property(nonatomic,weak)id<XinLvDelegate> delegate;
@property(nonatomic, assign) NSString *selectMValue;
@end

NS_ASSUME_NONNULL_END
