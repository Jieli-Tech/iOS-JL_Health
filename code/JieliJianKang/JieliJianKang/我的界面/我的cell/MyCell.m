//
//  MyCell.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/1.
//

#import "MyCell.h"
#import "JL_RunSDK.h"

@implementation MyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.cellImv = [[UIImageView alloc] initWithFrame:CGRectMake(32, 50/2-22/2, 22, 22)];
        self.cellImv.image = [UIImage imageNamed:@"weight_img_nol"];
        self.cellImv.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.cellImv];
        
        self.label = [[UILabel alloc] init];
        self.label.frame = CGRectMake(self.cellImv.frame.origin.x+self.cellImv.frame.size.width+12, 50/2-21/2, self.frame.size.width, 21);
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
        self.label.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.label.textColor = kDF_RGBA(36, 36, 36, 1.0);
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
