//
//  SporadicNapView.m
//  JieliJianKang
//
//  Created by 李放 on 2021/11/5.
//

#import "SporadicNapView.h"

@interface SporadicNapView (){
    UILabel *lable1;
    UILabel *lable2;
}
@end

@implementation SporadicNapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *lingXingImv0 = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 20, 20)];
        lingXingImv0.image = [UIImage imageNamed:@"sleep_small_nol"];
        lingXingImv0.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:lingXingImv0];
        
        lable1 = [[UILabel alloc] init];
        lable1.frame = CGRectMake(46,19,60,21);
        lable1.numberOfLines = 0;
        [self addSubview:lable1];
        lable1.font =  [UIFont fontWithName:@"PingFang SC" size: 15];
        lable1.text =  kJL_TXT("零星小睡");
        lable1.textColor = kDF_RGBA(36, 36, 36, 1.0);
        
        lable2 = [[UILabel alloc] init];
        lable2.numberOfLines = 0;
        [self addSubview:lable2];
        lable2.font =  [UIFont fontWithName:@"PingFang SC" size: 13];
        lable2.textColor = kDF_RGBA(145, 145, 145, 1.0);
    }
    return self;
}

-(void)setCurrentTime:(int) type WithStartTime:(NSString *) startTime WithEndTime:(NSString *) endTime WithHour:(int) hour WithMinute:(int) minute{
    if(type == 0){ //0:零星小睡的时间不超过1个小时
        lable2.frame = CGRectMake(self.frame.size.width/2+70,21,150,18);
        lable2.text =  [NSString stringWithFormat:@"%@-%@ %d%@",startTime,endTime,minute,kJL_TXT("分钟")];
    }
    if(type == 1){ //1：零星小睡的时间超过1个小时
        lable2.frame = CGRectMake(self.frame.size.width/2+50,21,150,18);
        lable2.text =  [NSString stringWithFormat:@"%@-%@ %d%@%d%@",startTime,endTime,hour,kJL_TXT("小时"),minute,kJL_TXT("分钟")];
    }
}

@end
