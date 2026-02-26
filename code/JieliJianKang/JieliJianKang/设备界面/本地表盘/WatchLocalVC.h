//
//  WatchLocalVC.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/1.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "PhotoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WatchLocalVC : UIViewController

@property(nonatomic,strong)PhotoView                   *mPhotoView;

-(void)loadWatchForPayment:(BOOL)isFree;

-(void)installDial:(UIImage *)image;

@end



NS_ASSUME_NONNULL_END
