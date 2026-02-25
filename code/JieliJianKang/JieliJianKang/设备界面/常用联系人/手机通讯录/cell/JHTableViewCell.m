//
//  JHTableViewCell.m
//  JHContactTrue
//
//  Created by junhuai on 2019/12/13.
//  Copyright © 2019 junhuai. All rights reserved.
//

#import "JHTableViewCell.h"
#import "JL_RunSDK.h"

@interface JHTableViewCell ()
@end

@implementation JHTableViewCell {
    UIImageView *_imageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 获取单元格高度
+ (NSInteger)getCellHeight:(JHTableViewCellStyle)style {
    switch (style) {
        case JHTableViewCellStyleDetail:
            return 70;
    }
    return 0;
}

- (instancetype)initWithMyStyle:(JHTableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.style = style;
        _imageView = [[UIImageView alloc] init];
        self.nameLabel = [[UILabel alloc] init];
        self.nicknameLabel = [[UILabel alloc] init];
        self.selectImv = [[UIImageView alloc] init];
        
        // 加入 cell 中
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.nicknameLabel];
        [self.contentView addSubview:self.selectImv];
        
        if (style == JHTableViewCellStyleDetail) {
            self.numberLabel = [[UILabel alloc] init];
            [self.contentView addSubview:self.numberLabel];
        }
    }

    return self;
}

// 顺带刷新数据
// 不能在这里新建，否则重用的时候会产生问题
- (void)setModel {
    if (self.personModel != nil) {
        // 先看图片是否为空
        if (self.personModel.smallImage) {
            self.image = self.personModel.smallImage;
        } else {
            self.image = [UIImage imageNamed:@"icon_contecter_person"];
        }
        switch (self.style) {
            case JHTableViewCellStyleDetail:
                _imageView.image = self.image;
                _imageView.frame = CGRectMake(14, 13, 44, 44);
                // 将头像裁剪成圆形
                _imageView.layer.cornerRadius = _imageView.frame.size.width / 2;  // 设置圆形半径
                _imageView.layer.masksToBounds = YES;  //隐藏裁掉的部分
//                // 加一个圆形边框
//                _imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//                _imageView.layer.borderWidth = 1.0f;
                // 可以改变图片颜色
                _imageView.tintColor = [UIColor grayColor];

                // 对姓名标签赋值
                if (self.personModel.fullName != nil) {
                    self.nameLabel.text = self.personModel.fullName;
                    self.nameLabel.frame = CGRectMake(72, 10, 160, 30);
                    self.nameLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
                    self.nameLabel.font = [UIFont fontWithName:@"PingFangSC" size:15];
                }

                // 手机号副标题
                if (self.personModel.phones.count){
                    self.numberLabel.text = [NSString stringWithFormat:@"%@  %@",self.personModel.phones[0].type, self.personModel.phones[0].value];
                    self.numberLabel.frame = CGRectMake(72, 33, 200, 30);
                    self.numberLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
                    self.numberLabel.font = [UIFont fontWithName:@"PingFangSC" size:15];
                } else{
                    self.numberLabel.text = @"";
                }
                
                //选中图标
                self.selectImv.image = [UIImage imageNamed:@"icon_music_unsel"];
                self.selectImv.frame = CGRectMake([DFUITools screen_2_W]-32-18-20,25,20,20);
                self.selectImv.contentMode = UIViewContentModeScaleAspectFit;
                break;

            default:
                break;

        }
    }

}

- (void)setPersonModel:(JHPersonModel *)personModel {
    _personModel = personModel;
    [self setModel];
}

///  随机选择颜色  根据号码尾数
/// @return 颜色
- (UIColor *)randomColor {
    NSArray<UIColor *> *color = @[[UIColor redColor], [UIColor blueColor], [UIColor magentaColor],
            [UIColor purpleColor], [UIColor grayColor], [UIColor orangeColor], [UIColor brownColor], [UIColor cyanColor]];
    int count = 0;
    if (_personModel.phones.count) {
        NSString *temp = [_personModel.phones[0].value substringFromIndex:_personModel.phones[0].value.length - 3];
        count = [temp intValue];
    }
    return color[count % color.count];
}


@end
