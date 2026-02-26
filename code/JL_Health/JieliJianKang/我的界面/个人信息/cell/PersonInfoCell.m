//
//  PersonInfoCell.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/2.
//

#import "PersonInfoCell.h"

@implementation PersonInfoCell

-(instancetype)init{
    self = [[NSBundle mainBundle] loadNibNamed:@"PersonInfoCell" owner:nil options:nil][0];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
