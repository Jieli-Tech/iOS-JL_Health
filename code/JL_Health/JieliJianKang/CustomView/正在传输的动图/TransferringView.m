#import "TransferringView.h"
#import "UIImage+GIF.h"

#define TransferringView_W      self.frame.size.width
#define TransferringView_H      self.frame.size.height

@interface TransferringView(){
    UITapGestureRecognizer *tapges;
    UIImageView *bgImgv;
    UIView *centerView;
    
    int mType;
}
@end
@implementation TransferringView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self initUI];
        [self adjustDark];
    }
    return self;
    
}

#pragma mark 适配暗黑模式
-(void)adjustDark{
    if (@available(iOS 13.0, *)) {
        UIColor *bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            }
            else {
                return [UIColor colorWithRed:60/255.0 green:61/255.0 blue:74/255.0 alpha:1.0];
            }
        }];
        [centerView setBackgroundColor:bgColor];
    } else {
        // Fallback on earlier versions
        [centerView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    }
}

-(void)initUI{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, TransferringView_W, TransferringView_H)];
    //样式
    toolbar.barStyle = UIBarStyleBlackTranslucent;//半透明
    toolbar.userInteractionEnabled=YES;
    //透明度
    toolbar.alpha = 0.45f;
    [self addSubview:toolbar];
    
    //命令背景View
    centerView = [[UIView alloc] initWithFrame:CGRectMake(TransferringView_W/2-180/2,[UIScreen mainScreen].bounds.size.height/2-122/2,180,122)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.alpha=1.0;
    centerView.layer.cornerRadius = 8;
    [self addSubview:centerView];
    
    CGRect aiImvrect = CGRectMake(centerView.frame.size.width/2-96/2,0,96,96);
    UIImageView *aiImv = [[UIImageView alloc] initWithFrame:aiImvrect];
    aiImv.contentMode = UIViewContentModeScaleAspectFit;
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"transferring" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    aiImv.image = [UIImage sd_animatedGIFWithData:imageData];
    [centerView addSubview:aiImv];
    
    UILabel *transferringLabel = [[UILabel alloc] init];
    transferringLabel.frame = CGRectMake(55,aiImv.frame.origin.y+aiImv.frame.size.height-15,centerView.frame.size.width,20);
    transferringLabel.numberOfLines = 0;
    transferringLabel.text = kJL_TXT("正在传输中");
    transferringLabel.contentMode = UIViewContentModeCenter;
    transferringLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    transferringLabel.textColor = kDF_RGBA(0, 0, 0, 0.9);
    [centerView addSubview:transferringLabel];
    [transferringLabel sizeToFit];
}

@end
