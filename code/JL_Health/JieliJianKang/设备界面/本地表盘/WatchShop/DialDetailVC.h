//
//  DialDetailVC.h
//  JieliJianKang
//
//  Created by 李放 on 2022/5/10.
//

#import <UIKit/UIKit.h>
#import "DialModel.h"
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import "JLPhoneUISetting.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialDetailVC : UIViewController

@property (strong, nonatomic)DialModel *dialModel;
@end

NS_ASSUME_NONNULL_END
