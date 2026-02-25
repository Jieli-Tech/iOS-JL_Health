//
//  JLSwiperParameter.h
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/2.
//

#ifndef JLPagerParameter_h
#define JLPagerParameter_h

//全屏宽和高大小
#define FUll_VIEW_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define FUll_VIEW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define FUll_CONTENT_HEIGHT FUll_VIEW_HEIGHT - 64 - 49
//十六进制颜色值
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define PageBtn .0675 * FUll_VIEW_HEIGHT //6s下高度45
//tabbar的高度
#define TabbarHeight 49
//TopTab相关参数
#define TOPTABMARGINLEFT    20
#define TOPTABWIDTH         FUll_VIEW_WIDTH - TOPTABMARGINLEFT * 2
#define More5LineWidth TOPTABWIDTH / 5.0 //超过5个标题的宽度
#define TITLE_SCROLLVIEW    318
#define BODY_SCROLLVIEW     917


#endif /* JLPagerParameter_h */
