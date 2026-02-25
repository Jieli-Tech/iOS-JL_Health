//
//  LocalMusicVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LocalMusicVCDelegate <NSObject>

-(void)transferAllMusicFinish;

@end

@interface LocalMusicVC : UIViewController

@property (weak, nonatomic) id<LocalMusicVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
