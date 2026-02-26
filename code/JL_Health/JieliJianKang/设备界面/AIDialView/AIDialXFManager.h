//
//  AIDialXFManager.h
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/13.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "JL_RunSDK.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^AiDialInstallResult)(float progress, DialOperateType success);

@interface AIDialXFManager : NSObject


/// AI 表盘对象管理
@property(nonatomic,strong)JLAIDialManager *dialManager;

+(instancetype)share;

/// 裁剪图片方法
/// - Parameter image: 图片
/// - Parameter withBg: 是否带背景
/// - Returns: 裁剪后的图片
+(UIImage *)machRadius:(UIImage *)image withBg:(BOOL)withBg;

-(void)saveTypeIndex:(int)index;

-(int)getType;

-(void)setRequestContent:(NSString *)content;


/// 设置AI表盘风格
-(void)setAiDialStyle;



/// 发送表盘到设备
/// - Parameter img: 图片
/// - Parameter type: 0:App端操作 1：设备端操作
/// - Parameter originSizeImage 原图
-(void)installDialToDevice:(UIImage *)img WithType:(int) type  originSizeImage:(UIImage*) originSizeImage completion:(AiDialInstallResult)completion;

@end

NS_ASSUME_NONNULL_END
