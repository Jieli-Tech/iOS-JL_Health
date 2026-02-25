//
//  DevicesViewCell.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/21.
//

#import "DevicesViewCell.h"

@interface DevicesViewCell()<LanguagePtl>

@end

@implementation DevicesViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[LanguageCls share] add:self];
    [_reConnectBtn setTitle:kJL_TXT("重新连接") forState:UIControlStateNormal];
    

    
}


- (IBAction)reConnectBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(cellDidSelect:)]) {
        [_delegate cellDidSelect:self.itemIndex];
    }
}

- (void)languageChange {
    [_reConnectBtn setTitle:kJL_TXT("重新连接") forState:UIControlStateNormal];
}

@end
