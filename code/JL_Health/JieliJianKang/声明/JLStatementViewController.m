//
//  JLStatementViewController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/13.
//

#import "JLStatementViewController.h"
#import "UILabel+YBAttributeTextTapAction.h"

@interface JLStatementViewController ()

@property (weak, nonatomic) IBOutlet UIView *menuView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation JLStatementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.4).CGColor;
    self.menuView.layer.shadowOffset = CGSizeMake(0,1);
    self.menuView.layer.shadowOpacity = 1;
    self.menuView.layer.shadowRadius = 10;
    self.menuView.layer.cornerRadius = 16;
    

    NSString *showText= [NSString stringWithFormat:@"%@",  kJL_TXT("声明一")];
    NSArray *array = @[kJL_TXT("声明二"), kJL_TXT("声明三")];
    
    [self.cancelBtn setTitle:kJL_TXT("退出") forState:UIControlStateNormal];
    [self.confirmBtn setTitle:kJL_TXT("同意") forState:UIControlStateNormal];
    self.titleLabel.text = kJL_TXT("宜动健康声明");

    UIColor *color = [UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
    UIColor *color2 = [UIColor colorWithRed:68.0/255.0 green:142.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.contentLabel.attributedText = [self getAttributeWith:array string:showText orginFont:14 orginColor:color attributeFont:14 attributeColor:color2];
    __weak typeof(self) weakSelf = self;
    [self.contentLabel yb_addAttributeTapActionWithStrings:array tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        if ([weakSelf.delegate respondsToSelector:@selector(confirmDidSelect:)]) {
            [weakSelf.delegate confirmDidSelect:(int)index];
        }
    }];
}

- (IBAction)confirmBtnFunc:(id)sender {
    if ([_delegate respondsToSelector:@selector(confirmConfirmBtnAction)]) {
        [_delegate confirmConfirmBtnAction];
        [[NSNotificationCenter defaultCenter] postNotificationName:AgreementView.kAgreeMent object:@"ok" userInfo:nil];
    }
}

- (IBAction)cancelBtnFunc:(id)sender {
    if ([_delegate respondsToSelector:@selector(confirmCancelBtnAction)]) {
        [_delegate confirmCancelBtnAction];
        [[NSNotificationCenter defaultCenter] postNotificationName:AgreementView.kAgreeMent object:@"no" userInfo:nil];
    }
}

#pragma mark - Private Method

- (NSAttributedString *)getAttributeWith:(id)sender string:(NSString *)string orginFont:(CGFloat)orginFont orginColor:(UIColor *)orginColor attributeFont:(CGFloat)attributeFont attributeColor:(UIColor *)attributeColor
{
    __block  NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc] initWithString:string];
    [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:orginFont] range:NSMakeRange(0, string.length)];
    [totalStr addAttribute:NSForegroundColorAttributeName value:orginColor range:NSMakeRange(0, string.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.0f]; //设置行间距
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [totalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [totalStr length])];
    
    if ([sender isKindOfClass:[NSArray class]]) {
        
        __block NSString *oringinStr = string;
        __weak typeof(self) weakSelf = self;
        
        [sender enumerateObjectsUsingBlock:^(NSString *  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRange range = [oringinStr rangeOfString:str];
            [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
            [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
            oringinStr = [oringinStr stringByReplacingCharactersInRange:range withString:[weakSelf getStringWithRange:range]];
        }];
        
    } else if ([sender isKindOfClass:[NSString class]]) {
        
        NSRange range = [string rangeOfString:sender];
        
        [totalStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:attributeFont] range:range];
        [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
    }
    return totalStr;
}

- (NSString *)getStringWithRange:(NSRange)range
{
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < range.length ; i++) {
        [string appendString:@" "];
    }
    return string;
}

@end
