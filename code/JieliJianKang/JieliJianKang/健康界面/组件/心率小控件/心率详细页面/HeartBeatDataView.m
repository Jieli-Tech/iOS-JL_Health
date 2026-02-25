//
//  HeartBeatDataView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/26.
//

#import "HeartBeatDataView.h"
#import "JL_RunSDK.h"
#import <TYCoreText/TYCoreText.h>

@interface HeartBeatDataView(){
    UIImageView *heartView;
    TYAttributedLabel *msgLab;
}
@end

@implementation HeartBeatDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        heartView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 20, 20)];
        heartView.image = [UIImage imageNamed:@"icon_heart"];
        [self addSubview:heartView];
        _heartLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, self.frame.size.width, 20)];
        _heartLab.font = [UIFont systemFontOfSize:14];
        _heartLab.textColor = kDF_RGBA(145, 145, 145, 1);
        _heartLab.text = kJL_TXT("心率范围");
        [self addSubview:_heartLab];
        
        msgLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(40, 32, 200, 24)];
        msgLab.backgroundColor = [UIColor clearColor];
        [self addSubview:msgLab];
        //[self hbMsgLabel:@"48-128" Units:kJL_TXT("次/分钟")];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor colorWithRed:100/255.0 green:102/255.0 blue:103/255.0 alpha:0.34].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 10;
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];
        [self addGestureRecognizer:tapges];
        
    }
    return self;
}

-(void)didTouch{
    [self shadows:true];
    if ([_delegate respondsToSelector:@selector(didSelected:)]) {
        [_delegate didSelected:self];
    }
}

-(void)shadows:(BOOL)status{
    if (status) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 3;
        self.layer.shadowOffset = CGSizeMake(1.0f,1.0f);
        self.layer.shadowOpacity = 0.6f;
    }else{
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 3;
        self.layer.shadowOffset = CGSizeMake(1.0f,1.0f);
        self.layer.shadowOpacity = 0.6f;
    }
}



-(void)hbMsgLabel:(NSString *)main Units:(NSString *)u{
    TYTextContainer *container = [[TYTextContainer alloc] init];
    NSString *mainText = [NSString stringWithFormat:@"%@%@",main,u];
    container.text = mainText;
    TYTextStorage *strong = [[TYTextStorage alloc] init];
    strong.range = [mainText rangeOfString:main];
    strong.font = [UIFont systemFontOfSize:17];
    strong.textColor = kDF_RGBA(36, 36, 36, 1);
    [container addTextStorage:strong];
    
    TYTextStorage *strong2 = [[TYTextStorage alloc] init];
    strong2.range = [mainText rangeOfString:u];
    strong2.font = [UIFont systemFontOfSize:10];
    strong2.textColor = kDF_RGBA(145, 145, 145, 1);
    [container addTextStorage:strong2];
    msgLab.textContainer = container;
    
}

@end
