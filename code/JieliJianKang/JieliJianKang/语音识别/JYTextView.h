//
//  JYTextView.h
//  JYImageTextCombine
//
//  Created by JackYoung on 2022/3/31.
//  Copyright © 2022 Jack Young. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, JYTextViewJYBubbleMenuViewDirectionPriorityType) {
    JYTextViewJYBubbleMenuViewDirectionPriorityType_Up,
    JYTextViewJYBubbleMenuViewDirectionPriorityType_Down
};


@protocol JYTextViewDelegate <NSObject>

-(void)didSelectTitle:(NSString *) selectTitle;
-(void)hideTextSelection;

@end

@interface JYTextView : UITextView

@property (nonatomic, copy)void (^selectBlock)(NSString *selectedButtonTitle);
@property (nonatomic, strong)UIViewController *fatherViewController;
@property (assign, nonatomic) id <JYTextViewDelegate> textViewDelegate;
@property(assign,nonatomic) int type;

-(void)setDirectionPriority:(JYTextViewJYBubbleMenuViewDirectionPriorityType) directionType;

//取消文本选中效果
- (void)hideTextSelection;


@end

NS_ASSUME_NONNULL_END
