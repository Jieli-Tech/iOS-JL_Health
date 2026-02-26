//
//  JLTabBarController.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2022/1/6.
//

#import "JLTabBarController.h"


@interface JLTabBarController ()

@end

@implementation JLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - JLWearSyncProtocol

-(void)jlWearSyncStartMotionWith:(JL_EntityM *_Nonnull)entity {
    [JLApplicationDelegate checkCurrentSport];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    UIViewController *vc = self.viewControllers[item.tag];
    [vc viewWillAppear:YES];
}

@end
