//
//  JLPagerView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#import "JLPagerView.h"
#import "JLPagerParameter.h"
#import "JLPagerBaseView.h"
#import "JLOutdoorSportThumbnailViewController.h"
#import "JLIndoorSportsThumbnailViewController.h"

#define MaxNums  5

@implementation JLPagerView
{
    JLPagerBaseView *pagerView;
}

- (instancetype)initWithTitles:(NSArray *)titles WithVCs:(NSArray *)childVCs WithColorArrays:(NSArray *)colors {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_CONTENT_HEIGHT);
        [self createPagerView:titles WithVCs:childVCs WithColors:colors];
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - CreateView

- (void)createPagerView:(NSArray *)titles WithVCs:(NSArray *)childVCs WithColors:(NSArray *)colors {
    if (colors.count > 0) {
        for (NSInteger i = 0; i < colors.count; i++) {
            switch (i) {
                case 0:
                     _selectColor = colors[0];
                    break;
                case 1:
                    _unselectColor = colors[1];
                    break;
                case 2:
                    _underlineColor = colors[2];
                    break;
                default:
                    break;
            }
        }
    }
    if (titles.count > 0 && childVCs.count > 0) {
        if(pagerView == nil){
            pagerView = [[JLPagerBaseView alloc] initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_CONTENT_HEIGHT) WithSelectColor:_selectColor WithUnselectorColor:_unselectColor WithUnderLineColor:_underlineColor];
        }else{
            [pagerView setFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_CONTENT_HEIGHT) WithSelectColor:_selectColor WithUnselectorColor:_unselectColor WithUnderLineColor:_underlineColor];
        }
        [pagerView setTitleArray:titles];
        if (childVCs.count > 0) {
            if(pagerView.scrollView.subviews.count >0){
                return;
            }
            [pagerView.scrollView removeSubviews];
            for (int i = 0; i < childVCs.count; i++) {
                NSString *className = childVCs[i];
                UIViewController *ctrl = nil;
                if ([className isEqualToString:NSStringFromClass([JLOutdoorSportThumbnailViewController class])]) {
                    ctrl = [[JLOutdoorSportThumbnailViewController alloc] initWithNibName:NSStringFromClass([JLOutdoorSportThumbnailViewController class]) bundle:nil];
                    if (ctrl) {
                        _outdoorSportThumbnailViewController = (JLOutdoorSportThumbnailViewController *)ctrl;
                        JLApplicationDelegate.outdoorSportThumbnailVC = _outdoorSportThumbnailViewController;
                    }
                } else if ([className isEqualToString:NSStringFromClass([JLIndoorSportsThumbnailViewController class])]) {
                    ctrl = [[JLIndoorSportsThumbnailViewController alloc] initWithNibName:NSStringFromClass([JLIndoorSportsThumbnailViewController class]) bundle:nil];
                }
                if (ctrl) {
                    ctrl.view.frame = CGRectMake(FUll_VIEW_WIDTH * i, 0, FUll_VIEW_WIDTH, FUll_CONTENT_HEIGHT - PageBtn);
                    [pagerView.scrollView addSubview:ctrl.view];
                }
            }
        }
        [self addSubview:pagerView];
    }
}

- (void)reCreatePagerView:(NSArray *)titles WithVCs:(NSArray *)childVCs WithColors:(NSArray *)colors {
    [self createPagerView:titles WithVCs:childVCs WithColors:colors];
}

- (void)setTitles:(NSArray *)titles {
    if (pagerView.titleArray.count == titles.count) {
        [pagerView setTitleArray:titles];
    }
}

@end
