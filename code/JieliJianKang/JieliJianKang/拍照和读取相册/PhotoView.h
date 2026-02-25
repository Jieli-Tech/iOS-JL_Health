//
//  PhotoView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PhotoDelegate <NSObject>

-(void)takePhoto;
-(void)takePicture;
@end

@interface PhotoView : UIView
@property(nonatomic,weak)id<PhotoDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
