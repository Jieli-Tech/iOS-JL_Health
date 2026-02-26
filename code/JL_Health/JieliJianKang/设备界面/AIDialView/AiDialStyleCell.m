//
//  AiDialStyleCell.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/13.
//

#import "AiDialStyleCell.h"

@implementation AiDialStyleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
}


-(void)setSelectStatus:(BOOL)status{
    if (status) {
        self.layer.borderColor = [JLColor colorWithString:@"#805BEB"].CGColor;
        self.layer.borderWidth = 2;
        self.selectImgv.hidden = false;
    }else{
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 2;
        self.selectImgv.hidden = true;
    }
}



@end
