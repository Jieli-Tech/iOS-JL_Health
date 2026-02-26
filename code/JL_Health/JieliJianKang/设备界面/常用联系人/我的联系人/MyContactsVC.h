//
//  MyContactsVC.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JLContactsFuncType) {
    JLContactsFuncTypeAdd = 0,
    JLContactsFuncTypeSort = 1,
    JLContactsFuncTypeDelete = 2,
};

@interface MyContactsVC : UIViewController

@end

NS_ASSUME_NONNULL_END
