//
//  CustomDialCell.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import "CustomDialCell.h"
#import "AIDialXFManager.h"

@interface CustomDialCell (){
    UITapGestureRecognizer *editTap;
}
@end

@implementation CustomDialCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.centerView = [[UIView alloc] init];
        self.centerImgv = [[UIImageView alloc] init];
        self.centerImgv.contentMode = UIViewContentModeScaleAspectFit;
        self.confirmBtn = [[UIButton alloc] init];
        self.deleteBtn = [[UIButton alloc] init];
        
        self.backgroundColor = [UIColor whiteColor];
        self.centerView.backgroundColor = [UIColor whiteColor];
        if ([[JL_RunSDK sharedMe] configModel].exportFunc.spDialInfoExtend) {
            uint8_t shape = [[JL_RunSDK sharedMe] dialInfoExtentedModel].shape;
            if( shape == 0x01){
                //圆形时，直接把图片裁成圆的，指定圆角半径
                self.centerView.layer.cornerRadius = 44;
            }else if ( shape == 0x01){
                //方形时，保持原图展示
                self.centerView.layer.cornerRadius = 0;
            }else if (shape == 0x02){
                //圆角方形时，取获取到的圆角半径一半，因为 iOS 的点阵屏是@2x，设备的是@1x
                self.centerView.layer.cornerRadius = [[JL_RunSDK sharedMe] dialInfoExtentedModel].radius/2;
            }
        }
        self.centerView.layer.masksToBounds = YES;
        [self.contentView addSubview:_centerView];
        
        [self.centerView addSubview:_centerImgv];
        

        [self.deleteBtn setImage:[UIImage imageNamed:@"login_icon_delete_nol"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteBtn];
        
        [self.confirmBtn setBackgroundColor:[JLColor colorWithString:@"#F0F1F5" alpha:1]];
        [self.confirmBtn setTitle:kJL_TXT("使用") forState:UIControlStateNormal];
        self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.confirmBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        [self.confirmBtn setTitleColor:[JLColor colorWithString:@"#558CFF"] forState:UIControlStateNormal];
        self.confirmBtn.layer.cornerRadius = 12;
        self.confirmBtn.layer.masksToBounds = YES;
        [self.contentView addSubview:_confirmBtn];
        
        [self.confirmBtn addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBtnAction)];
        
        
        self.deleteBtn.hidden = YES;
        
        [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).inset(12);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.height.equalTo(@88);
            make.width.equalTo(@88);
        }];
        
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@24);
            make.top.right.equalTo(self).inset(0);
        }];
        
        [self.centerImgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.centerView);
        }];

        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@72);
            make.height.equalTo(@24);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
    }
    return self;
}

- (void)setModel:(CustomDialCellModel *)model{
    _model = model;
    self.centerImgv.image = model.image;
    [self.confirmBtn setTitle:kJL_TXT("使用") forState:UIControlStateNormal];
    [self.centerView addGestureRecognizer:editTap];
    if (model.index == 0){
        self.deleteBtn.hidden = true;
        [self.confirmBtn setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
        [self.centerView removeGestureRecognizer:editTap];
    }
    
}

- (void)deleteBtnAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(customDialCell:didDeleteModel:)]) {
        [self.delegate customDialCell:self didDeleteModel:self.model];
    }
}

- (void)confirmBtnAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(customDialCell:didSelectModel:)]) {
        [self.delegate customDialCell:self didSelectModel:self.model];
    }
}

- (void)editBtnAction{
    if ([self.delegate respondsToSelector:@selector(customDialCell:didEditModel:)]) {
        [self.delegate customDialCell:self didEditModel:self.model];
    }
}

@end


@implementation CustomDialCellModel

- (void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    NSString *middlePath = [NSString stringWithFormat:@"%@/CustomDial",[EcTools appUserDevFolder]];
    _originPath = [filePath stringByReplacingOccurrencesOfString:middlePath withString:@"CustomDialOrigin"];
    NSData *dt = [NSData dataWithContentsOfFile:_filePath];
    _image = [AIDialXFManager machRadius:[UIImage imageWithData:dt] withBg:false];
    
    NSData *oriDt = [NSData dataWithContentsOfFile:_originPath];
    _originImage = [UIImage imageWithData:oriDt];
    
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    fmDate.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString *str = [[[filePath lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    _date = [fmDate dateFromString:str];
}

@end
