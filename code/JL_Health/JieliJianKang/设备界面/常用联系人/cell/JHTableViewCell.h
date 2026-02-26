//
//  JHTableViewCell.h
//  JHContactTrue
//
//  Created by junhuai on 2019/12/13.
//  Copyright © 2019 junhuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHPersonModel.h"
#import "MyContactsVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JHTableViewCellStyle) {
    JHTableViewCellStyleContacts,
    JHTableViewCellStyleDetail,
};

@interface JHTableViewCell : UITableViewCell
@property (nonatomic, strong) DFLabel *nameLabel;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) DFLabel *numberLabel;
@property (nonatomic, strong) UIImageView *selectImv;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) JLContactsFuncType funType; //0:添加 1:排序 2：移除
@property (nonatomic) JHPersonModel *personModel;
@property (nonatomic) JHTableViewCellStyle style;


+ (NSInteger)getCellHeight:(JHTableViewCellStyle)style;

- (instancetype)initWithMyStyle:(JHTableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
