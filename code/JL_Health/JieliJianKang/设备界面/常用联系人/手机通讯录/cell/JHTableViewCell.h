//
//  JHTableViewCell.h
//  JHContactTrue
//
//  Created by junhuai on 2019/12/13.
//  Copyright © 2019 junhuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHPersonModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JHTableViewCellStyle) {
    JHTableViewCellStyleDetail,
};

@interface JHTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *selectImv;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic) JHPersonModel *personModel;
@property (nonatomic) JHTableViewCellStyle style;


+ (NSInteger)getCellHeight:(JHTableViewCellStyle)style;

- (instancetype)initWithMyStyle:(JHTableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
