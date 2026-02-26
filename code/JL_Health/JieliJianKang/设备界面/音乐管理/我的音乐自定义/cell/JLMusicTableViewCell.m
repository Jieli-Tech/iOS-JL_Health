//
//  JLMusicTableViewCell.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/12/14.
//

#import "JLMusicTableViewCell.h"

@interface JLMusicTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@end

@implementation JLMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTitle:(NSString *)title description:(NSString *)description fileSize:(CGFloat)fileSize withIsSelected:(BOOL)isSelected {
    self.titleLabel.text = title;
    if (description.length > 0) {
        if (fileSize > 0) {
            self.descriptionLabel.text = [NSString stringWithFormat:@"%@  %@", description, [self convertFileSize:fileSize]];
        } else {
            self.descriptionLabel.text = description;
        }
    } else {
        if (fileSize > 0) {
            self.descriptionLabel.text = [NSString stringWithFormat:@"%@", [self convertFileSize:fileSize]];
        } else {
            self.descriptionLabel.text = @"";
        }
    }
    if (isSelected) {
        self.selectedImageView.image = [UIImage imageNamed:@"icon_music_sel"];
    } else {
        self.selectedImageView.image = [UIImage imageNamed:@"icon_music_unsel"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (NSString *)convertFileSize:(CGFloat)fileSize {
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    if (fileSize >= gb) {
        return [NSString stringWithFormat:@"%.1fGB", fileSize / gb];
    } else if (fileSize >= mb) {
        CGFloat f = fileSize / mb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fMB", f];
        }else{
            return [NSString stringWithFormat:@"%.1fMB", f];
        }
    } else if (fileSize >= kb) {
        CGFloat f = (float) fileSize / kb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fKB", f];
        }else{
            return [NSString stringWithFormat:@"%.1fKB", f];
        }
    } else {
        return [NSString stringWithFormat:@"%fB", fileSize];
    }
}

@end
