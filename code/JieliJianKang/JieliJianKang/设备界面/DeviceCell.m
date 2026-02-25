//
//  DeviceCell.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/19.
//

#import "DeviceCell.h"
#import "JLUI_Effect.h"
#import "JL_RunSDK.h"

@interface DeviceCell()
{
    
    __weak IBOutlet UIView *subBgView;
    __weak IBOutlet UIButton *btnConnect;
    
}

@end

@implementation DeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)init
{
    self = [DFUITools loadNib:@"DeviceCell"];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [JLUI_Effect addShadowOnView_2:subBgView];
        [self setIsConnect:NO];
    }
    return self;
}

-(void)setIsConnect:(BOOL)isConnect{
    if (isConnect) {
        [btnConnect setTitle:kJL_TXT("已连接") forState:UIControlStateNormal];
        [btnConnect setTitleColor:kDF_RGBA(111, 206, 124, 1) forState:UIControlStateNormal];
        [btnConnect setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        btnConnect.layer.borderColor = kJL_COLOR_ASSIST_GREEN.CGColor;
        btnConnect.layer.borderWidth = 1.0;
        btnConnect.layer.cornerRadius= 15.0;
    }else{
        [btnConnect setTitle:kJL_TXT("连接") forState:UIControlStateNormal];
        [btnConnect setTitleColor:kDF_RGBA(128, 91, 235, 1) forState:UIControlStateNormal];
        [btnConnect setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        btnConnect.layer.borderColor = kDF_RGBA(128, 91, 235, 1).CGColor;
        btnConnect.layer.borderWidth = 1.0;
        btnConnect.layer.cornerRadius= 15.0;
    }
}

- (IBAction)btnConnect:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onDeviceCellSelectIndex:)]) {
        [_delegate onDeviceCellSelectIndex:self.subIndex];
    }
}


@end
