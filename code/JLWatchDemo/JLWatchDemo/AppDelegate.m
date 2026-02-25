//
//  AppDelegate.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/5.
//

#import "AppDelegate.h"
#import "JL_RunSDK.h"
#import "DeviceVC.h"
#import "FunctionVC.h"

#include <stdio.h>
#include <math.h>

@interface AppDelegate (){
    
    UITabBarController  *mainVC;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [JL_Tools openLogTextFile];
    
    [JL_RunSDK sharedMe];
    
    /*--- 初始化UI ---*/
    [self setupUI];
    

    return YES;
}

-(void)setupUI{
    self.window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    mainVC = [self prepareViewControllers];
    self.window.rootViewController = mainVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

-(UITabBarController*)prepareViewControllers{
    DeviceVC    *vc_1 = [DeviceVC new];
    FunctionVC  *vc_2 = [FunctionVC new];
    
    UINavigationController *nvc_1 = [[UINavigationController alloc] initWithRootViewController:vc_1];
    UINavigationController *nvc_2 = [[UINavigationController alloc] initWithRootViewController:vc_2];

    NSArray *arr_vc  = @[nvc_1,nvc_2];
    NSArray *arr_txt = @[@"设备",@"功能"];
    NSArray *arr_img = @[@"tab_icon_watch_nol",@"tab_icon_settle_nol"];
    NSArray *arr_img_sel = @[@"tab_icon_watch_sel",@"tab_icon_settle_sel"];
    
    for (int i = 0 ; i < arr_vc.count; i++) {
        UINavigationController *nvc = arr_vc[i];
        /*--- TabBarItem的名字 ---*/
        nvc.tabBarItem.title = arr_txt[i];
        
        /*--- 使用原图片作为底部的TabBarItem ---*/
        UIImage *image     = [UIImage imageNamed:arr_img[i]];
        UIImage *image_sel = [UIImage imageNamed:arr_img_sel[i]];
        nvc.tabBarItem.image         = [self imageAlwaysOriginal:image];
        nvc.tabBarItem.selectedImage = [self imageAlwaysOriginal:image_sel];
        
        /*--- 隐藏底部 ---*/
        [nvc.tabBarController.tabBar setHidden:NO];
        
        /*--- 同时支持又滑返回功能的解决办法(隐藏顶部) ---*/
        nvc.navigationBarHidden = NO;
        nvc.navigationBar.hidden = YES;
    }
    
    UITabBarController *tabBarVC  = [[UITabBarController alloc] init];
    tabBarVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    tabBarVC.tabBar.tintColor     = kDF_RGBA(255.0, 198.0, 96.0, 1.0);
    tabBarVC.tabBar.barTintColor  = [UIColor lightGrayColor];
    tabBarVC.tabBar.backgroundColor = [UIColor whiteColor];
    tabBarVC.viewControllers      = arr_vc;
    return tabBarVC;
}


- (UIImage *)imageAlwaysOriginal:(UIImage *)image{
    UIImage *img = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

// 方法三
// NS_AVAILABLE_IOS(9_0)
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"---> url:%@ option:%@",url,options);
    return YES;
}

@end
