//
//  BasicViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/13.
//

#import "BasicViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [JLColor colorWithString:@"#FBFCFC"];
    
    _navigateView = [[UIView alloc] init];
    _titleLab = [[UILabel alloc] init];
    _existBtn = [[UIButton alloc] init];
    
    _navigateView.backgroundColor = [JLColor colorWithString:@"#FFFFFF"];
    
    _titleLab.text = @"BasicTitle";
    _titleLab.font = FontMedium(18);
    _titleLab.textColor = [JLColor colorWithString:@"#242424"];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    
    [_existBtn addTarget:self action:@selector(existBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_existBtn setImage:[UIImage imageNamed:@"icon_return_nol"] forState:UIControlStateNormal];
    
    [self.view addSubview:_navigateView];
    [_navigateView addSubview:_titleLab];
    [_navigateView addSubview:_existBtn];
    
    [_navigateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(@(kJL_HeightNavBar));
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_navigateView.mas_centerX);
        make.bottom.equalTo(_navigateView.mas_bottom).offset(-9);
        make.height.mas_equalTo(25);
    }];
    
    [_existBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_navigateView.mas_left).offset(16);
        make.width.height.equalTo(@(30));
        make.centerY.equalTo(_titleLab.mas_centerY);
    }];

}

-(void)setTitle:(NSString *)title{
    self.titleLab.text = title;
}

-(void)existBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
