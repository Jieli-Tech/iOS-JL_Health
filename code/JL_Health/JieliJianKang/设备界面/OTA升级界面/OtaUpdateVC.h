//
//  OtaUpdateVC.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/9.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "OtaView.h"


NS_ASSUME_NONNULL_BEGIN

@interface OtaUpdateVC : UIViewController

@property(nonatomic,assign)int funcType;

-(void)actionToUpdate;


@end

NS_ASSUME_NONNULL_END
