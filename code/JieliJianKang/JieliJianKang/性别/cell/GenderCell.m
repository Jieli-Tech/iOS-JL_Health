//
//  GenderCell.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/4.
//

#import "GenderCell.h"

@implementation GenderCell

-(instancetype)init{
    self = [[NSBundle mainBundle] loadNibNamed:@"GenderCell" owner:nil options:nil][0];
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
