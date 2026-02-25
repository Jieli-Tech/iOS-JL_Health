//
//  MyChartVC.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2021/3/22.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "MyChartVC.h"
#import "JL_RunSDK.h"
#import "YaLiView.h"

#import "YaliCircleView.h"



@interface MyChartVC (){
    YaLiView *yaliView;
    YaliCircleView *yaliCircleView;
}

@end

@implementation MyChartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float sW = [DFUITools screen_2_W];
    float sH = 260;
    
    CGRect rect_0 = CGRectMake(0, 88, sW, sH);
    yaliView = [[YaLiView alloc] initWithFrame:rect_0];
    yaliView.textArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    yaliView.dataArray = @[@(40.0),@(20.0),@(40.0),@(80.0),@(60.0),@(90.0),@(0.0)];
    [self.view addSubview:yaliView];
    
    [yaliView loadUI];
    
    [JL_Tools delay:0.1 Task:^{
        CGRect rect_1 = CGRectMake(100.0, 440.0, 120.0, 120.0);
        self->yaliCircleView = [[YaliCircleView alloc] initByFrame:rect_1];
        self->yaliCircleView.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:self->yaliCircleView];
        
        self->yaliCircleView.value_0 = 0.2;
        self->yaliCircleView.value_1 = 0.1;
        self->yaliCircleView.value_2 = 0.4;
        self->yaliCircleView.value_3 = 0.3;
        [self->yaliCircleView updateUI];
    }];
    

}

- (IBAction)btn_test:(id)sender {
    [yaliView setSubIndex:5];
    
}


@end
