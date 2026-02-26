//
//  JLMusicTableViewCell.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLMusicTableViewCell : UITableViewCell

- (void)setTitle:(NSString *)title description:(NSString *)description fileSize:(CGFloat)fileSize withIsSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
