//
//  DialModel.h
//  JieliJianKang
//
//  Created by 李放 on 2022/5/9.
//

#import <Foundation/Foundation.h>
#import "WatchCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DialType) {
    //系统表盘
    DialType_0 =  0,
    //推荐表盘
    DialType_1 =  1,
    //主题表盘
    DialType_2 =  2,
    
    DialType_x
};

@interface DialModel : NSObject
@property(nonatomic,assign)DialType  dialType;
@property(nonatomic,strong)NSString  *iconUrl;       //表盘小图片
@property(nonatomic,strong)NSString  *bigIconUrl;    //表盘大图片
@property(nonatomic,strong)NSString  *watchName;     //表盘名字
@property(nonatomic,assign)WatchCellType mStatus;    //表盘的状态
@property(nonatomic,assign)float      mPrice;        //价格
@property(nonatomic,strong)NSString  *dialIntroduce; //表盘简介
@property(nonatomic,strong)NSDictionary *dict;

@end

NS_ASSUME_NONNULL_END
