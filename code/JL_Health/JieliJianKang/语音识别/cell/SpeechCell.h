//
//  SpeechCell.h
//  JieliJianKang
//
//  Created by 李放 on 2023/8/1.
//

#import <UIKit/UIKit.h>
#import "AICloundMessageModel.h"
#import "JYBubbleMenuView.h"
#import "JYTextView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpeechCellDelegate <NSObject,JYTextViewDelegate>

-(void)didSelectTitle:(NSString *) selectTitle;
-(void)hideTextSelection;

@end

@interface SpeechCell : UITableViewCell

@property (strong, nonatomic) UIImageView *chooseImv;

@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) JYTextView *aiLabel;
+(NSString*)ID;
+(CGFloat)cellHeight:(AICloundMessageModel *)info Index:(NSInteger)index;
-(void)setInfo:(AICloundMessageModel *)info Index:(NSInteger)index WithMulSelect:(BOOL) mulSelect WithArray:(NSArray *)selectArray;

@property (assign, nonatomic) id <SpeechCellDelegate> speechCellDelegate;
@end

NS_ASSUME_NONNULL_END
