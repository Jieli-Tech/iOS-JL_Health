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


-(void)installDial:(UIImage *)image OriImage:(UIImage *_Nullable)originImage;

@end



NS_ASSUME_NONNULL_END
