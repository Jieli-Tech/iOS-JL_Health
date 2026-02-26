//
//  CutImageViewController.h
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/23.
//

#import <UIKit/UIKit.h>
#import "UIImage+Rotate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CropImageDelegate <NSObject>

- (void)cropImageDidFinishedWithImage:(UIImage *)image;

@end

@interface CutImageViewController : UIViewController

@property (nonatomic, weak) id <CropImageDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)originalImage delegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
