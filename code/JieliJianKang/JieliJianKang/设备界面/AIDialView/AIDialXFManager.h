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

-(void)saveTypeIndex:(int)index;

-(int)getType;

-(void)setRequestContent:(NSString *)content;


/// 设置AI表盘风格
-(void)setAiDialStyle;

/// 保存记录到本地
/// - Parameter image: 图片
-(void)saveImageToPath:(UIImage *)image;

/// 发送表盘到设备
/// - Parameter img: 图片
/// - Parameter type: 0:App端操作 1：设备端操作
-(void)installDialToDevice:(UIImage *)img WithType:(int) type completion:(AiDialInstallResult)completion;

@end

NS_ASSUME_NONNULL_END
