//
//  SpeechCell.m
//  JieliJianKang
//
//  Created by 李放 on 2023/8/1.
//

#import "SpeechCell.h"
#import "AIClound.h"

@interface SpeechCell(){
    JYTextView *meLabel;
    UIView *view_2;
}
@end

@implementation SpeechCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    if(selected){
//        kJLLog(JLLOG_DEBUG, @"select 2");
//        _chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_sel"];
//    }else {
//        kJLLog(JLLOG_DEBUG, @"unselect 2");
//        _chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_nol"];
//    }
}

+(NSString*)ID{
    return @"SpeechCell";
}

+(CGFloat)cellHeight:(AICloundMessageModel *)aiCloundMessageModel Index:(NSInteger)index{
    NSString *text = [NSString stringWithFormat:@"%@", aiCloundMessageModel.text];
    
    CGFloat w =  [UIScreen mainScreen].bounds.size.width - 56.0 - 70.0;
    CGFloat height = [DFUITools labelHeightByWidth:w Text:text Font:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    
//    if(aiCloundMessageModel.role ==1){
//        return 64;
//    }else{
        return height + 56.0;
    //}
//    if(index==0){
//        return 64;
//    }else if(aiCloundMessageModel.role ==1){
//        if(aiCloundMessageModel.isFirstPage){
//            return 64;
//        }else{
//            return 44;
//        }
//    }else{
//        return height + 56.0;
//    }
}

-(void)setInfo:(AICloundMessageModel *)aiCloundMessageModel Index:(NSInteger)index WithMulSelect:(BOOL) mulSelect WithArray:(NSArray *)selectArray{
    int type = aiCloundMessageModel.role;
    NSString *text = [NSString stringWithFormat:@"%@", aiCloundMessageModel.text];
    
    NSDate *currentDate = aiCloundMessageModel.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    int state = aiCloundMessageModel.aiCloudState;
    
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 40.0 - 70.0;
    CGFloat lb_h = [DFUITools labelHeightByWidth:w Text:text Font:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    CGFloat lb_w = [DFUITools labelWidthByWidth:w Text:text Font:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
    
    /*--- 我 ---*/
    if (type == 1) {
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-68/2,
                                         0,160,20);
        timeLabel.numberOfLines = 0;
        timeLabel.text = dateString;
        timeLabel.font =  [UIFont fontWithName:@"PingFangSC" size:14];
        timeLabel.textColor = kDF_RGBA(145, 145, 145, 1.0);
        [self.contentView addSubview:timeLabel];
        [timeLabel sizeToFit];
        kJLLog(JLLOG_DEBUG, @"isFirstPage:%d",aiCloundMessageModel.isFirstPage);
        
        UIView *view_1 = [[UIView alloc] init];
        //if(aiCloundMessageModel.isFirstPage || index ==0){
            timeLabel.hidden = NO;
            timeLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-68/2,
                                             0,160,20);
            view_1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-(lb_w+56), 25, lb_w+35.0, lb_h+20.0);
//        }else{
//            timeLabel.hidden = YES;
//            timeLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-68/2,
//                                             0,160,0);
//            view_1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-(lb_w+56), 0, lb_w+35.0, lb_h+20.0);
//        }
        [self.contentView addSubview:view_1];
        view_1.backgroundColor =  kDF_RGBA(242.0, 242.0, 242.0, 1.0);
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];

        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:143/255.0 green:106/255.0 blue:249/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:114/255.0 green:70/255.0 blue:242/255.0 alpha:1.0].CGColor];

        gradientLayer.locations = @[@(0), @(1.0f)];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);

        gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(view_1.frame), CGRectGetHeight(view_1.frame));

        [view_1.layer addSublayer:gradientLayer];
        
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view_1.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
        //创建 layer
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = view_1.bounds;
        //赋值
        maskLayer.path = maskPath.CGPath;
        view_1.layer.mask = maskLayer;
        
        if(state ==1) { //识别过程
            if([text isEqualToString:@"开始识别..."]){
                UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(10,view_1.frame.size.height/2-lb_h/2,lb_w+35.0-20, lb_h)];
                imv.contentMode = UIViewContentModeScaleAspectFit;
                UIImage *image = [UIImage imageNamed:@"icon_ai_sound"];
                imv.image = image;
                [view_1 addSubview:imv];
            }
            
            if([text isEqualToString:@"识别中..."]){
                JYTextView *label = [[JYTextView alloc] init];
                label.frame = CGRectMake(view_1.frame.size.width/2-25/2, 0,25, 3);
                label.text = @"...";
                label.textColor = [UIColor whiteColor];
                label.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:16];
                label.backgroundColor = [UIColor clearColor];
                label.contentMode = UIViewContentModeCenter;
                [view_1 addSubview:label];
                [label sizeToFit];

                [JL_Tools delay:2.5 Task:^{
                    [label removeFromSuperview];
                }];
            }
        }
        
        if(state == 2){ //识别结果
            if(text.length>0){
                meLabel = [[JYTextView alloc] init];
                meLabel.frame = CGRectMake(10,2.5,lb_w+25, lb_h);
                [meLabel setDirectionPriority:JYTextViewJYBubbleMenuViewDirectionPriorityType_Up];
//                if(index == 0){
//                    [meLabel setDirectionPriority:JYTextViewJYBubbleMenuViewDirectionPriorityType_Down];
//                }else{
//                    [meLabel setDirectionPriority:JYTextViewJYBubbleMenuViewDirectionPriorityType_Up];
//                }
                meLabel.text = text;
                meLabel.textViewDelegate = self;
                meLabel.textColor = [UIColor whiteColor];
                meLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:16];
                meLabel.backgroundColor = [UIColor clearColor];
                [view_1 addSubview:meLabel];
                [meLabel sizeToFit];
            }
        }
        _chooseImv  = [[UIImageView alloc] init];
        _chooseImv.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:_chooseImv];
//        if(aiCloundMessageModel.isFirstPage || index ==0){
            _chooseImv.frame = CGRectMake(68, 25, 24, 24);
//        }else{
//            _chooseImv.frame = CGRectMake(68, 5, 24, 24);
//        }
        
//        if(selectArray.count>0){
//            for(AICloundMessageModel *model in selectArray){
//                if([model.text isEqualToString:meLabel.text]){
//                    _chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_sel"];
//                }
//            }
//        }else{
//            _chooseImv.image = [UIImage imageNamed:@"icon_chat_choose_nol"];
//        }
    }
    
    /*--- 机器 ---*/
    if (type == 2) {
//        _chooseImv  = [[UIImageView alloc] initWithFrame:CGRectMake(16,16,24, 24)];
//        _chooseImv.contentMode = UIViewContentModeScaleToFill;
//        [self.contentView addSubview:_chooseImv];
        
        UIImageView *aiImv = [[UIImageView alloc] init];
        aiImv.contentMode = UIViewContentModeScaleToFill;
        UIImage *image = [UIImage imageNamed:@"icon_ai_img_photo"];
        aiImv.image = image;
        [self.contentView addSubview:aiImv];
        
        //kJLLog(JLLOG_DEBUG, @"mulSelect:%d",mulSelect);
        
        view_2 = [[UIView alloc] init];
        view_2.frame = CGRectMake(68,16,lb_w+20.0,lb_h);
        [self.contentView addSubview:view_2];
        view_2.backgroundColor =  [UIColor clearColor];//kDF_RGBA(242.0, 242.0, 242.0, 1.0);
        
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view_2.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
//        //创建 layer
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = view_2.bounds;
//        //赋值
//        maskLayer.path = maskPath.CGPath;
        //view_2.layer.mask = maskLayer;
        
        _aiLabel = [[JYTextView alloc] init];
        _aiLabel.frame = CGRectMake(0,2.5,lb_w+10, lb_h);
        //aiLabel.numberOfLines = 0;
        _aiLabel.text = text;
        _aiLabel.textContainerInset = UIEdgeInsetsMake(15, 16, 11, 16);
        _aiLabel.textViewDelegate = self;
        _aiLabel.type=2;
        [_aiLabel setDirectionPriority:JYTextViewJYBubbleMenuViewDirectionPriorityType_Up];
        _aiLabel.font =  [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _aiLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
        _aiLabel.contentMode = UIViewContentModeCenter;
        _aiLabel.backgroundColor = [UIColor clearColor];
        [view_2 addSubview:_aiLabel];
        [_aiLabel sizeToFit];
        [_aiLabel hideTextSelection];
        
//        if(selectArray.count>0){
//            for(AICloundMessageModel *model in selectArray){
//                if([model.text isEqualToString:_aiLabel.text]){
//                    _aiLabel.type=1;
//                }
//            }
//        }else{
//            _aiLabel.type =2;
//        }

//        if(mulSelect){
//            aiImv.frame = CGRectMake(_chooseImv.frame.origin.x+_chooseImv.frame.size.width+10,16,44,44);
//            view_2.frame = CGRectMake(_chooseImv.frame.origin.x+_chooseImv.frame.size.width+68,16,lb_w+20-(_chooseImv.frame.origin.x+_chooseImv.frame.size.width),lb_h+20.0);
//            aiLabel.frame = CGRectMake(7,0,lb_w+20-(_chooseImv.frame.origin.x+_chooseImv.frame.size.width)-5, lb_h+30);
//        }else{
            aiImv.frame = CGRectMake(16,16,44,44);
            view_2.frame = CGRectMake(68,16,lb_w+20.0,lb_h+20.0);
           _aiLabel.frame = CGRectMake(7,0,lb_w+10, lb_h+30);
//        }

        
        UIView *view_bottom = [[UIView alloc] init];
        view_bottom.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 16);
        [self.contentView addSubview:view_bottom];
    }
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if(aiLabel)[aiLabel hideTextSelection];
//    if(meLabel)[meLabel hideTextSelection];
//
//    [JYBubbleMenuView.shareMenuView removeFromSuperview];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if ([scrollView isKindOfClass:[UITextView class]]) {
//        [JYBubbleMenuView.shareMenuView removeFromSuperview];
//    }
//}

-(void)didSelectTitle:(NSString *) selectTitle{
    if ([_speechCellDelegate respondsToSelector:@selector(didSelectTitle:)]) {
        [_speechCellDelegate didSelectTitle:selectTitle];
    }
}

-(void)hideTextSelection{
    if ([_speechCellDelegate respondsToSelector:@selector(hideTextSelection)]) {
        [_speechCellDelegate hideTextSelection];
    }
}

@end
