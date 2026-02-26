//
//  EcDateSelectView.h
//  Example
//
//  Created by EzioChan on 2021/4/15.
//  Copyright © 2021 Zhuhia Jieli Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EcDtSltDelegate <NSObject>

-(void)ecDidDateSelected:(NSDate *)date;

@end

@interface EcDateSelectView : UIView

@property(nonatomic,weak)id <EcDtSltDelegate> delegate;


@property(nonatomic,assign)BOOL isWeek;

@end

NS_ASSUME_NONNULL_END
