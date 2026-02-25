//
//  SportRecordView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/15.
//

#import "SportRecordView.h"
#import "JL_RunSDK.h"
#import <TYCoreText/TYCoreText.h>


@interface SportRecordView()<LanguagePtl>{
    UIImageView *spImgv;
    UILabel *titleLab;
    UILabel *dayLab;
    TYAttributedLabel *recordLab;
}
@end

@implementation SportRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        spImgv = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12.0, 28, 28)];
        spImgv.image = [UIImage imageNamed:@"health_icon_record_nol"];
        [self addSubview:spImgv];
        
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(44, 16, 100, 20)];
        titleLab.textColor = kDF_RGBA(36, 36, 36, 1);
        titleLab.text = kJL_TXT("运动记录");
        CGFloat width = [self getWidthWithText:kJL_TXT("运动记录") height:20 font:14];
        titleLab.frame = CGRectMake(44, 16, width, 20);

        titleLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:titleLab];
        
        dayLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-120-16, 16, 120, 20)];
        dayLab.textAlignment = NSTextAlignmentRight;
        dayLab.textColor = kDF_RGBA(175, 175, 175, 1);
        dayLab.font = [UIFont systemFontOfSize:12];
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
        [self addSubview:dayLab];
        
        recordLab = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(41, 46, 200, 35)];
        recordLab.backgroundColor = [UIColor clearColor];
        [self addSubview:recordLab];
        [self setTheRecord:@"单位" Record:nil type:nil withDay:nil];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
    
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchForJump)];
        [self addGestureRecognizer:ges];
        [[LanguageCls share] add:self];
    }
    return self;
}

-(void)touchForJump{
    if ([_delegate respondsToSelector:@selector(jumpByObject:)]) {
        [_delegate jumpByObject:SportRecord];
    }
}


-(void)setTheRecord:(NSString *)unit Record:(NSString *_Nullable)record type:(NSString *_Nullable)type withDay:(NSString *_Nullable)day{
    
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    
    if (record == nil) {
        textContainer.text = kJL_TXT("无记录");
        TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
        textStorage2.range = [kJL_TXT("无记录")rangeOfString:kJL_TXT("无记录")];
        textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        textStorage2.textColor = kDF_RGBA(36, 36, 36, 1);
        [textContainer addTextStorage:textStorage2];
        recordLab.textContainer = textContainer;
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
    }else{
        NSString *stepStr = [NSString stringWithFormat:@"%@%@",record,unit];
        textContainer.text = stepStr;
        // 整体设置属性
        textContainer.linesSpacing = 2;
        textContainer.paragraphSpacing = 5;
        
        // 文字样式
        TYTextStorage *textStorage = [[TYTextStorage alloc]init];
        textStorage.range = [stepStr rangeOfString:record];
        textStorage.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24];
        textStorage.textColor = kDF_RGBA(36, 36, 36, 1);
        [textContainer addTextStorage:textStorage];
        
        TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
        textStorage2.range = [stepStr rangeOfString:unit];
        textStorage2.font = [UIFont systemFontOfSize:12];
        textStorage2.textColor = kDF_RGBA(152, 152, 152, 1);
        [textContainer addTextStorage:textStorage2];
        recordLab.textContainer = textContainer;

        NSString *newStr = [NSString stringWithFormat:@"%@ %@",day,type];
        dayLab.text = newStr;
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)languageChange {
    titleLab.text = kJL_TXT("运动记录");
    CGFloat width = [self getWidthWithText:kJL_TXT("运动记录") height:20 font:14];
    titleLab.frame = CGRectMake(44, 16, width, 20);
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
}

@end
