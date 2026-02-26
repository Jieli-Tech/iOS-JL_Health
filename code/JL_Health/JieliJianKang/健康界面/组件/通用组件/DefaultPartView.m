//
//  DefaultPartView.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/3/19.
//

#import "DefaultPartView.h"
#import <TYCoreText/TYCoreText.h>
#import "JL_RunSDK.h"


@interface DefaultPartView(){
    UIImageView *spImgv;
    UILabel *titleLab;
    UILabel *dayLab;
    TYAttributedLabel *recordLab;
}
@end

@implementation DefaultPartView

- (instancetype)initWithFrame:(CGRect)frame Type:(NSString *)typeName Image:(UIImage *)img
{
    self = [super initWithFrame:frame];
    if (self) {
        
        spImgv = [[UIImageView alloc] initWithFrame:CGRectMake(12, 14.0, 24, 24)];
        spImgv.image = img;
        [self addSubview:spImgv];
        
        CGFloat width = [self getWidthWithText:typeName height:20 font:14];
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(44, 16,width, 20)];
        titleLab.textColor = kDF_RGBA(36, 36, 36, 1);
        titleLab.text = typeName;
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

        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchForJump)];
        [self addGestureRecognizer:ges];
    }
    return self;
}


-(void)touchForJump{
    if ([_delegate respondsToSelector:@selector(jumpByObject:)]) {
        [_delegate jumpByObject:self.type];
    }
}


-(void)setLabValue:(NSString *)value Unit:(NSString *)units day:(NSDate * _Nullable )date{
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    
    NSString *tmpStr = [NSString stringWithFormat:@"%@",value];
    NSString *targetStr = [NSString stringWithFormat:@"%@%@",tmpStr,units];
    textContainer.text = targetStr;
    TYTextStorage *textStorage2 = [[TYTextStorage alloc]init];
    textStorage2.range = [targetStr rangeOfString:tmpStr];
    textStorage2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24];
    textStorage2.textColor = kDF_RGBA(36, 36, 36, 1);
    [textContainer addTextStorage:textStorage2];
    
    TYTextStorage *textStorage = [[TYTextStorage alloc]init];
    textStorage.range = [targetStr rangeOfString:units];
    textStorage.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    textStorage.textColor = kDF_RGBA(96, 96, 96, 1);
    [textContainer addTextStorage:textStorage];
    recordLab.textContainer = textContainer;
    
    NSDateFormatter *fm = [EcTools cachedFm];
    
    //NSString *fmstr = [NSString stringWithFormat:@"MM%@dd%@",kJL_TXT("月"),kJL_TXT("日")];
    fm.dateFormat = @"MM-dd";
    
    NSString *str = [fm stringFromDate:date];
    
    if (str == nil) {
        dayLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"-",kJL_TXT("月"),@"-",kJL_TXT("日")];
    }else{
        dayLab.text = str;
    }
}

-(void)setTitle:(NSString *)title{
    titleLab.text = title;
    CGFloat width = [self getWidthWithText:titleLab.text height:20 font:14];
    titleLab.frame = CGRectMake(44, 16,width, 20);
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
