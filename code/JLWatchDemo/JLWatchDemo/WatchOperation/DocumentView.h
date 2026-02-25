//
//  DocumentView.h
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^DocumentResult)(NSString *file);

@interface DocumentView : UIView

-(void)showWithPath:(NSString*)path Result:(DocumentResult)result;
-(void)showZipWithPath:(NSString*)path Result:(DocumentResult)result;

@end

NS_ASSUME_NONNULL_END
