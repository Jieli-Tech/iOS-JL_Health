//
//  MyPhoneVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/16.
//

#import <UIKit/UIKit.h>
@class JHPersonModel;

NS_ASSUME_NONNULL_BEGIN

@protocol MyPhoneVCDelegate<NSObject>

- (void)transferCallFileFinished;

@end

@interface MyPhoneVC : UIViewController

@property (weak, nonatomic) id<MyPhoneVCDelegate> delegate;
@property (weak, nonatomic) NSArray<JHPersonModel*> *originalContactArray;

@end

NS_ASSUME_NONNULL_END
