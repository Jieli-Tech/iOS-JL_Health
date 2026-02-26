//
//  EcDateSelectView.m
//  Example
//
//  Created by EzioChan on 2021/4/15.
//  Copyright © 2021 Zhuhia Jieli Technology. All rights reserved.
//

#import "EcDateSelectView.h"
#import "JL_RunSDK.h"
#import <JTCalendar/JTCalendar.h>


@interface EcDateSelectView()<JTCalendarDelegate,LanguagePtl>{
    JTCalendarMenuView *calendarMenuView;
    JTHorizontalCalendarView *calendarContentView;
    JTCalendarManager *calendarManager;
    UIButton *leftBtn;
    UIButton *rightBtn;
    NSDate *dateSelected;
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    
    
    NSMutableArray *datesSelected;
    NSMutableArray *weeksView;
    JTCalendarWeekView *superWeekView;
}
@end

@implementation EcDateSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        _todayDate = [NSDate date];
        datesSelected = [NSMutableArray new];
        weeksView = [NSMutableArray new];
        NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
        calendarManager = [[JTCalendarManager alloc] initWithLocale:local andTimeZone:[NSTimeZone new]];
        calendarManager.delegate = self;
        [self createMinAndMaxDate];
      
        calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatCustom;
        calendarManager.dateHelper.calendar.firstWeekday = 2;
        [calendarManager.settings.weekDays setArray:@[kJL_TXT("周一"),kJL_TXT("周二"),kJL_TXT("周三"),kJL_TXT("周四"),kJL_TXT("周五"),kJL_TXT("周六"),kJL_TXT("周日")]];
        [calendarManager setMenuView:calendarMenuView];
        [calendarManager setContentView:calendarContentView];
        [calendarManager setDate:_todayDate];
    }
    return self;
}

-(void)setIsWeek:(BOOL)isWeek{
    _isWeek = isWeek;
    superWeekView.backgroundColor = [UIColor whiteColor];
    superWeekView = nil;
    if (isWeek == false) {
        [datesSelected removeAllObjects];
    }
    [calendarManager reload];
}

- (void)languageChange{
    
}

-(void)initUI{
    self.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.45;
    [self addSubview:bgView];
    UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction)];
    [bgView addGestureRecognizer:tapges];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(36, self.frame.size.height/2-254/2, self.frame.size.width-36*2, 254)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    CGFloat width = contentView.frame.size.width;
    CGFloat height = 254;
    calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, 0, width,40)];
    [contentView addSubview:calendarMenuView];
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 40, 40)];
    [leftBtn addTarget:self action:@selector(leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setImage:[UIImage imageNamed:@"icon_left_02_nol"] forState:UIControlStateNormal];
    [contentView addSubview:leftBtn];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-48, 0, 40, 40)];
    [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"icon_right_02_nol"] forState:UIControlStateNormal];
    [contentView addSubview:rightBtn];
  
    calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(5, 42, width-10, height-42-20)];
    [contentView addSubview:calendarContentView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 68.5, width, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    [contentView addSubview:line];
    
    
    contentView.layer.cornerRadius = 10;
    contentView.layer.masksToBounds = YES;
}

#pragma mark btnAction
-(void)leftBtnAction{
    _todayDate = [calendarManager.dateHelper addToDate:_todayDate months:-1];
    [self createMinAndMaxDate];
    [calendarManager setDate:_todayDate];
}
-(void)rightBtnAction{
    _todayDate = [calendarManager.dateHelper addToDate:_todayDate months:1];
    [self createMinAndMaxDate];
    [calendarManager setDate:_todayDate];
}

- (void)createMinAndMaxDate
{
    // Min date will be 2 month before today
    _minDate = [calendarManager.dateHelper addToDate:_todayDate months:-24];
    
    // Max date will be 2 month after today
    _maxDate = [calendarManager.dateHelper addToDate:_todayDate months:24];
}
-(void)dismissAction{
    self.hidden = YES;
}

//MARK:日历回调

-(void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView{
    
    if ([calendarManager.dateHelper date:[NSDate new] isTheSameDayThan:dayView.date]) {
        dayView.circleView.hidden = NO;
        dayView.circleView.layer.borderWidth = 1;
        dayView.circleView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:157.0/255.0 blue:91.0/255.0 alpha:1.0].CGColor;
        dayView.circleView.backgroundColor = [UIColor whiteColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor darkTextColor];
    }
    // Other month
    else if(![calendarManager.dateHelper date:calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else {
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        if(![calendarManager.dateHelper date:[NSDate new] isEqualOrBefore:dayView.date]){
            dayView.textLabel.textColor = [UIColor blackColor];
        }else{
            dayView.textLabel.textColor = [UIColor lightGrayColor];
        }
    }
    
    // Selected date
    if(dateSelected && [calendarManager.dateHelper date:dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
        dayView.circleView.layer.borderColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    if (_isWeek) {
        if (superWeekView == nil && datesSelected.count == 0 && [calendarManager.dateHelper date:[NSDate new] isTheSameDayThan:dayView.date]) {
            superWeekView = (JTCalendarWeekView *)dayView.fatherView;
            superWeekView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
            for (JTCalendarDayView *dView in [superWeekView getArrays]) {
                if(dView.date){
                    [datesSelected addObject:dView.date];
                }
            }
            [calendar reload];
        }
        
        if (datesSelected.firstObject && [calendarManager.dateHelper date:datesSelected.firstObject isTheSameDayThan:dayView.date]) {
            superWeekView = (JTCalendarWeekView *)dayView.fatherView;
//            NSLog(@"%@,%@",superWeekView,dayView.date);
        }
       
        NSDateFormatter *formatter = [EcTools cachedFm];
        formatter.dateFormat = @"yyyy-MM-dd";
        if([self isInDatesSelected:dayView.date]){
            dayView.circleView.hidden = NO;
            dayView.circleView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
            dayView.circleView.layer.borderColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0].CGColor;
            dayView.dotView.backgroundColor = [UIColor whiteColor];
            dayView.textLabel.textColor = [UIColor whiteColor];
            if ([superWeekView isEqual:dayView.fatherView]) {
                superWeekView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
            }
        }else{
            dayView.fatherView.backgroundColor = [UIColor whiteColor];
        }
       
    }

}


-(void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView{
    if(![calendarManager.dateHelper date:[NSDate new] isEqualOrAfter:dayView.date]){
        return;
    }
    dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
        dayView.circleView.transform = CGAffineTransformIdentity;
        [self->calendarManager reload];
    } completion:nil];
    if(calendarManager.settings.weekModeEnabled){
        return;
    }
    // Load the previous or next page if touch a day from another month
    
    if(![calendarManager.dateHelper date:calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [calendarContentView loadNextPageWithAnimation];
        }
        else{
            [calendarContentView loadPreviousPageWithAnimation];
        }
    }
    if ([_delegate respondsToSelector:@selector(ecDidDateSelected:)]) {
        [_delegate ecDidDateSelected:dateSelected];
    }
    if (_isWeek) {
        for (JTCalendarWeekView *objc in weeksView) {
            if ([objc isEqual:dayView.fatherView]) {
                objc.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
                [datesSelected removeAllObjects];
                for (JTCalendarDayView *dView in [objc getArrays]) {
                    [datesSelected addObject:dView.date];
                }
                superWeekView = objc;
            }else{
                objc.backgroundColor = [UIColor whiteColor];
            }
        }
        [calendar reload];
    }
    
    
}

- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date{
    return [calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}


- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar{
    _todayDate = calendar.date;
}
-(void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar{
    _todayDate = calendar.date;
}

//MARK:Menu delegate
- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    return label;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    
    NSDateFormatter *dateFormatter = [EcTools cachedFm];
    if ([[DFUITools getLanguage] hasPrefix:@"zh"]) {
        dateFormatter.dateFormat = [NSString stringWithFormat:@"yyyy%@MM%@",kJL_TXT("年"),kJL_TXT("月")];
    }else{
        dateFormatter.dateFormat = @"yyyy-MM";
    }

    menuItemView.text = [dateFormatter stringFromDate:date];
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    for(UILabel *label in view.dayViews){
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:15];
    }
    return view;
}

- (UIView<JTCalendarWeek> *)calendarBuildWeekView:(JTCalendarManager *)calendar{
    JTCalendarWeekView *view = [JTCalendarWeekView new];
    view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:128.0/255.0 green:91.0/255.0 blue:235.0/255.0 alpha:1.0];
    [weeksView addObject:view];
    view.layer.cornerRadius = 15.0;
    return view;
}


//MARK: - 新增
- (BOOL)isInDatesSelected:(NSDate *)date
{
//    NSDateFormatter *formatter = [EcTools cachedFm];
//    formatter.dateFormat = @"yyyy-MM-dd";
//    NSMutableString *tmpStr = [NSMutableString new];
    for(NSDate *dateSelected in datesSelected){
//        NSLog(@"isInDatesSelected:%@",date);
//        [tmpStr appendString:@","];
//        [tmpStr appendString:[formatter stringFromDate:dateSelected]];
        if([calendarManager.dateHelper date:dateSelected isTheSameDayThan:date]){
//            NSLog(@"%@",tmpStr);
            return YES;
        }
    }
//    NSLog(@"not match %@",[formatter stringFromDate:date]);
    return NO;
}




@end
