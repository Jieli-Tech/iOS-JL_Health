//
//  OtaView.h
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/3/9.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

#define IS_OTA_NET 1 //OTA升级标志位，0:本地OTA资源升级 1:服务器OTA资源升级

NS_ASSUME_NONNULL_BEGIN


typedef void(^OTA_VIEW_BK)(void);

@interface OtaView : UIView
@property (nonatomic,assign)int                         subUiType;
@property (weak, nonatomic) IBOutlet UILabel            *otaTitle;
@property (weak, nonatomic) IBOutlet UITextView         *otaTextView;

@property (weak, nonatomic) IBOutlet UILabel            *updateTxt;
@property (weak, nonatomic) IBOutlet UILabel            *progressTxt;
@property (weak, nonatomic) IBOutlet UIProgressView     *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actView;

@property (weak, nonatomic) IBOutlet UIImageView        *resultImage;
@property (weak, nonatomic) IBOutlet UILabel            *resultTxt;
@property (weak, nonatomic) IBOutlet UIButton           *sureBtn;
@property (weak, nonatomic) IBOutlet UILabel            *updateLabel;

@property (strong, nonatomic) NSDictionary              *otaDict;
@property (assign, nonatomic) BOOL                      isOtaRelink;

@property(nonatomic,strong  )NSString *otaUUID;

-(instancetype)initByFrame:(CGRect)frame;
- (IBAction)btn_0_Update:(id)sender;
-(void)showOtaError;
-(void)remoteNote;
@end

NS_ASSUME_NONNULL_END
