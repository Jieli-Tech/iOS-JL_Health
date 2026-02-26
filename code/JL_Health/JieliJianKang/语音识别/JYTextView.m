//
//  JYTextView.m
//  JYImageTextCombine
//
//  Created by JackYoung on 2022/3/31.
//  Copyright © 2022 Jack Young. All rights reserved.
//

#import "JYTextView.h"
#import "JYBubbleMenuView.h"
#import "JYBubbleButtonModel.h"
#import "AppDelegate.h"

@interface JYTextView()<UITextViewDelegate, UITextInputDelegate> {
    JYTextViewJYBubbleMenuViewDirectionPriorityType directionPriority;
    int mType;
}

@end

@implementation JYTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self resignFirstResponder];
        //self.tintColor = [UIColor greenColor];
        //self.font = [UIFont systemFontOfSize:15];
        //self.layer.cornerRadius = 5;
        self.clipsToBounds = true;
        self.editable = false;
        self.delegate = self;
        self.inputDelegate = self;
        
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress)]];
    }
    return self;
}

- (void)onLongPress {
    [self performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_textViewDelegate respondsToSelector:@selector(hideTextSelection)]) {
        [_textViewDelegate hideTextSelection];
    }
    [self hideTextSelection];
    [JYBubbleMenuView.shareMenuView removeFromSuperview];
}

- (void)hideTextSelection {
    [self setSelectedRange:NSMakeRange(0, 0)];//去掉选择的效果。
    
}

#pragma mark delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
//        [self.view endEditing:true];
        return NO;
    }

    return true;
}

- (void)selectionWillChange:(id<UITextInput>)textInput {
    NSLog(@"选择区域 _start_ 变化。。。隐藏");
}

- (void)selectionDidChange:(id<UITextInput>)textInput {
    NSLog(@"选择区域 _end_ 变化。。。显示");
}

-(void)setDirectionPriority:(JYTextViewJYBubbleMenuViewDirectionPriorityType) directionType{
    directionPriority = directionType;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"光标位置%ld——%ld",textView.selectedRange.location,textView.selectedRange.length);
        
    CGRect startRect = [textView caretRectForPosition:[textView selectedTextRange].start];
    CGRect endRect = [textView caretRectForPosition:[textView selectedTextRange].end];
//    NSLog(@"__👂👂👂👂%.1f,%.1f,%.1f,%.1f",startRect.origin.x, startRect.origin.y, startRect.size.width, startRect.size.height);
//    NSLog(@"__👂👂👂👂%.1f,%.1f,%.1f,%.1f",endRect.origin.x, endRect.origin.y, endRect.size.width, endRect.size.height);
    
    CGRect resultRect = CGRectZero;
    if (startRect.origin.y == endRect.origin.y) {
        resultRect.origin.x = startRect.origin.x;
        resultRect.origin.y = startRect.origin.y;
        resultRect.size.width = endRect.origin.x - startRect.origin.x + 2;
        resultRect.size.height = startRect.size.height;
    } else {
        resultRect.origin.x = 0;
        resultRect.origin.y = startRect.origin.y;
        resultRect.size.width = textView.frame.size.width;
        resultRect.size.height = endRect.origin.y - startRect.origin.y + endRect.size.height;
    }
    
//    _selectedTopView.frame = resultRect;
    
    CGRect tempRect = [self convertRect:resultRect toView:((AppDelegate*)([UIApplication sharedApplication].delegate)).window];
    CGRect cursorStartRectToWindow = [self convertRect:startRect toView:((AppDelegate*)([UIApplication sharedApplication].delegate)).window];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (textView.selectedRange.length > 0) {
        //全部选中的时候内容显示的不一样。
        if (textView.selectedRange.length == textView.text.length) {
            for (int i = 0; i < 2; i ++) {
                JYBubbleButtonModel *model = [[JYBubbleButtonModel alloc] init];
                if (i == 0) {
                    model.imageName = @"icon_ai_icon_copy";
                    model.name = kJL_TXT("复制");
                } else if (i == 1) {
                    model.imageName = @"icon_ai_mul_choose";
                    model.name = kJL_TXT("多选");
                }
//                else if (i == 2) {
//                    model.imageName = @"collect";
//                    model.name = @"收藏";
//                } else if (i == 3) {
//                    model.imageName = @"rubbish";
//                    model.name = @"删除";
//                } else if (i == 4) {
//                    model.imageName = @"mulSelect";
//                    model.name = @"多选";
//                } else if (i == 5) {
//                    model.imageName = @"ref";
//                    model.name = @"引用";
//                }
                [array addObject:model];
            }
            
            [[JYBubbleMenuView shareMenuView] setDirectionPriority:directionPriority];
            [[JYBubbleMenuView shareMenuView] showViewWithButtonModels:array cursorStartRect:cursorStartRectToWindow selectionTextRectInWindow:tempRect selectBlock:^(NSString * _Nonnull selectTitle) {

                [self hideTextSelection];
                [JYBubbleMenuView.shareMenuView removeFromSuperview];
                [self alertWithTitle:selectTitle];
            }];
        } else {
            for (int i = 0; i < 2; i ++) {
                JYBubbleButtonModel *model = [[JYBubbleButtonModel alloc] init];
                
                if (i == 0) {
                    model.imageName = @"icon_ai_icon_copy";
                    model.name = kJL_TXT("复制");
                } else if (i == 1) {
                    model.imageName = @"icon_ai_mul_choose";
                    model.name = kJL_TXT("多选");
                }
//                else if (i == 2) {
//                    model.imageName = @"collect";
//                    model.name = @"收藏";
//                } else if (i == 3) {
//                    model.imageName = @"rubbish";
//                    model.name = @"删除";
//                }
                
                [array addObject:model];
            }
            
            [[JYBubbleMenuView shareMenuView] setDirectionPriority:directionPriority];
            [[JYBubbleMenuView shareMenuView] showViewWithButtonModels:array cursorStartRect:cursorStartRectToWindow selectionTextRectInWindow:tempRect selectBlock:^(NSString * _Nonnull selectTitle) {
                [self hideTextSelection];
                [JYBubbleMenuView.shareMenuView removeFromSuperview];
                [self alertWithTitle:selectTitle];
            }];
        }
    } else {
        //隐藏
        [[JYBubbleMenuView shareMenuView] removeFromSuperview];
    }
}


- (void)drawRect:(CGRect)rect {
    if(_type == 1){
        [kDF_RGBA(242.0, 242.0, 242.0, 1.0) setFill];
        // Drawing code
        //绘制圆角
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
        [bezierPath fill];

        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:128/255.0 green:91/255.0 blue:235/255.0 alpha:1.0].CGColor;
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;

        [kDF_RGBA(128.0, 91.0, 235.0, 1.0) setStroke];
        UIBezierPath *bezierPath2 = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
        bezierPath2.lineWidth = 1;
        [bezierPath2 stroke];
    }else if(_type == 2){
        [kDF_RGBA(242.0, 242.0, 242.0, 1.0) setFill];
        // Drawing code
        //绘制圆角
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
        [bezierPath fill];
    }
}

- (void)alertWithTitle:(NSString *)title {
    if ([_textViewDelegate respondsToSelector:@selector(didSelectTitle:)]) {
        [_textViewDelegate didSelectTitle:title];
    }
    
//    if (_fatherViewController == nil) {
//        return;
//    }
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:title preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [alertController addAction:okAlert];
//    [alertController addAction:cancelAlert];
//    [_fatherViewController presentViewController:alertController animated:true completion:^{
//
//    }];
}

@end
