//
//  JLSwiperBaseView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#import "JLPagerBaseView.h"
#import "JLPagerParameter.h"
#import "JLTopTabButton.h"
#import "UIView+CBFrameHelpers.h"

@interface JLPagerBaseView () <UIScrollViewDelegate>

@end

@implementation JLPagerBaseView {
    NSMutableArray<JLTopTabButton*> *btnArray;
    NSArray *titlesArray; /**<  标题   **/
    NSInteger arrayCount; /**<  topTab数量   **/
    UIColor *selectBtn;
    UIColor *unselectBtn;
    UIColor *underline;
}


- (instancetype)initWithFrame:(CGRect)frame WithSelectColor:(UIColor *)selectColor WithUnselectorColor:(UIColor *)unselectColor WithUnderLineColor:(UIColor *)underlineColor {
    self = [super initWithFrame:frame];
    if (self) {
        if ([selectColor isKindOfClass:[UIColor class]]) {
            selectBtn = selectColor ? selectColor : [UIColor redColor];
        }
        if ([unselectColor isKindOfClass:[UIColor class]]) {
            unselectBtn = unselectColor ? unselectColor : [UIColor redColor];
        }
        if ([underlineColor isKindOfClass:[UIColor class]]) {
            underline = underlineColor ? underlineColor : [UIColor lightGrayColor];
        }
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - SetMethod
- (void)setTitleArray:(NSArray *)titleArray {
    titlesArray = titleArray;
    arrayCount = titleArray.count;
    [self addSubview:self.topTab];
    [self addSubview:self.scrollView];
}

#pragma mark - GetMethod

- (UIScrollView *)topTab {
    if (!_topTab) {
        _topTab = [[UIScrollView alloc] init];
        _topTab.frame = CGRectMake(TOPTABMARGINLEFT, 0, TOPTABWIDTH, PageBtn);
        _topTab.delegate = self;
        _topTab.tag = TITLE_SCROLLVIEW;
        _topTab.scrollEnabled = YES;
        _topTab.alwaysBounceHorizontal = YES;
        _topTab.showsHorizontalScrollIndicator = NO;
        _topTab.alwaysBounceHorizontal = NO;
        _topTab.backgroundColor = [UIColor lightGrayColor];
        CGFloat additionCount = 0;
        if (arrayCount > 5) {
            additionCount = (arrayCount - 5.0) / 5.0;
        }
        _topTab.contentSize = CGSizeMake((1 + additionCount) * TOPTABWIDTH, 0);
        btnArray = [NSMutableArray array];
        for (NSInteger i = 0; i < titlesArray.count; i++) {
            NSString *buttonTitle = @"";
            if ([titlesArray[i] isKindOfClass:[NSString class]]) {
                buttonTitle = titlesArray[i];
            } else {
                kJLLog(JLLOG_DEBUG, @"您所提供的标题%li格式不正确。 Your title%li not fit for topTab,please correct it to NSString!",(long)i + 1,(long)i + 1);
            }
            CGRect buttonFrame = CGRectMake(0, 0, 40, PageBtn);
            if (titlesArray.count > 5) {
                buttonFrame = CGRectMake(_topTab.frame.size.width / 5 * i, 0, _topTab.frame.size.width / 5, PageBtn);
            } else {
                buttonFrame = CGRectMake(_topTab.frame.size.width / titlesArray.count * i, 0, _topTab.frame.size.width / titlesArray.count, PageBtn);
            }
            JLTopTabButton *button = [JLTopTabButton topTabButtonWithFrame:buttonFrame withTitle:buttonTitle withDefaulTitleColor:unselectBtn withSelectedTitleColor:selectBtn];
            button.tag = i;
            [_topTab addSubview:button];
            __weak typeof(self) weakSelf = self;
            button.touchesBeganBlock = ^{
                [weakSelf.scrollView setContentOffset:CGPointMake(FUll_VIEW_WIDTH * button.tag, 0) animated:YES];
                weakSelf.currentPage = (FUll_VIEW_WIDTH * button.tag + FUll_VIEW_WIDTH / 2) / FUll_VIEW_WIDTH;
            };
            if (i == 0) {
                [button setSelected:YES];
            } else {
                [button setSelected:NO];
            }
            [btnArray addObject:button];
        }
    }
    return _topTab;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, PageBtn, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT - PageBtn - TabbarHeight);
        _scrollView.delegate = self;
        _scrollView.tag = BODY_SCROLLVIEW;
        _scrollView.backgroundColor = UIColorFromRGB(0xfafafa);
        _scrollView.contentSize = CGSizeMake(FUll_VIEW_WIDTH * titlesArray.count, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES;
    }
    return _scrollView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.tag == BODY_SCROLLVIEW) {
        self.currentPage = (NSInteger)((scrollView.contentOffset.x + FUll_VIEW_WIDTH / 2) / FUll_VIEW_WIDTH);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == BODY_SCROLLVIEW) {
        NSInteger yourPage = (NSInteger)((scrollView.contentOffset.x + FUll_VIEW_WIDTH / 2) / FUll_VIEW_WIDTH);
        for (NSInteger i = 0;  i < btnArray.count; i++) {
            if (unselectBtn) {
                [btnArray[i] setSelected:NO];
            }else {
                [btnArray[i] setSelected:YES];
            }
        }
        if (selectBtn) {
            [btnArray[yourPage] setSelected:YES];
        }else {
            [btnArray[yourPage] setSelected:NO];
        }
    }
}

#pragma mark - LayOutSubViews

- (void)layoutSubviews {
    [super layoutSubviews];
    [self initUI];
}

- (void)initUI {
    CGFloat yourCount = 1.0 / arrayCount;
    CGFloat additionCount = 0;
    if (arrayCount > 5) {
        additionCount = (arrayCount - 5.0) / 5.0;
        yourCount = 1.0 / 5.0;
    }
}

@end
