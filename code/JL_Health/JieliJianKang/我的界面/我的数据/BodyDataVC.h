//
//  BodyDataVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/2/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BodyDataObject;

@interface BodyDataVC : UIViewController

@property(nonatomic,strong)NSArray<BodyDataObject *> *huodongDataArray; //活动统计
@property(nonatomic,strong)NSArray<BodyDataObject *> *jiankangDataArray; //健康状况
@end

NS_ASSUME_NONNULL_END
