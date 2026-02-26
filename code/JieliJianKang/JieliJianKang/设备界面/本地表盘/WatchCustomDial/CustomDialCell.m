//
//  CustomDialCell.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/20.
//

#import "CustomDialCell.h"

@implementation CustomDialCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.centerView = [[UIView alloc] init];
        self.centerImgv = [[UIImageView alloc] init];
        self.editBtn = [[UIButton alloc] init];
        self.confirmBtn = [[UIButton alloc] init];
        self.deleteBtn = [[UIButton alloc] init];
        
        self.backgroundColor = [UIColor whiteColor];
        self.centerView.backgroundColor = [UIColor whiteColor];
        self.centerView.layer.cornerRadius = 44;
        self.centerView.layer.masksToBounds = YES;
        [self.contentView addSubview:_centerView];
        
        [self.centerView addSubview:_centerImgv];
        
        [self.editBtn setBackgroundColor:[JLColor colorWithString:@"#000000" alpha:0.4]];
        [self.editBtn setTitle:kJL_TXT("编辑") forState:UIControlStateNormal];
        self.editBtn.titleLabel.font = FontMedium(13);
        self.editBtn.titleLabel.adjustsFontSizeToFitWidth = true;
        [self.editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.centerView addSubview:_editBtn];

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
        
        [self.editBtn addTarget:self action:@selector(editBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.confirmBtn addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.deleteBtn.hidden = YES;
        self.editBtn.hidden = YES;
        
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
        [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.centerView).inset(0);
            make.height.equalTo(@26);
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
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    fmDate.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString *str = [fmDate stringFromDate:model.date];
    NSString *localIndex = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerUsing"];
    if ([localIndex isEqualToString:str]){
        self.editBtn.hidden = NO;
        [self.editBtn setTitle:kJL_TXT("编辑") forState:UIControlStateNormal];
        [self.confirmBtn setTitle:kJL_TXT("正在使用") forState:UIControlStateNormal];
    }else{
        self.editBtn.hidden = YES;
        [self.confirmBtn setTitle:kJL_TXT("使用") forState:UIControlStateNormal];
    }
    if (model.index == 0){
        self.editBtn.hidden = true;
        self.deleteBtn.hidden = true;
        [self.confirmBtn setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
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

- (void)editBtnAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(customDialCell:didEditModel:)]) {
        [self.delegate customDialCell:self didEditModel:self.model];
    }
}

@end


@implementation CustomDialCellModel

- (void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    NSData *dt = [NSData dataWithContentsOfFile:_filePath];
    _image = [UIImage imageWithData:dt];
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    fmDate.dateFormat = @"yyyy-MM-dd_HH-mm-ss";
    NSString *str = [[[filePath lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    _date = [fmDate dateFromString:str];
}

@end
