//
//  IFlyAIUISetting.h
//  IFlyAIUI
//
//  Created by jmli3 on 2018/7/4.
//

#import <Foundation/Foundation.h>

/*!
 *  日志打印等级
 */
typedef NS_OPTIONS(NSInteger, AIUI_LOG_LEVEL){

    LV_DEBUG,

    LV_INFO,
    
    LV_WARN,
    
    LV_ERROR,
    
    LV_NONE
};

/**
 * 版本类型。
 */
typedef NS_OPTIONS(NSInteger, AIUI_VERSION_TYPE){

    INTELLIGENT_HDW,    // 智能硬件版本
    MOBILE_PHONE,        // 移动互联网版本
    DESKTOP_PC            // 桌面PC版本
};

/*!
 *   可以获取版本号，设置日志打印等级等
 */
@interface IFlyAIUISetting : NSObject

/*!
 *  设置AIUI工作目录，SDK会在该路径下保存日志、数据等文件。<br>
 *
 *  @param path 路径（windows下以"\\"结尾，其他平台以"/"结尾），不能为空
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) setAIUIDir:(NSString *) path;

/*!
 *  设置MSC工作目录，SDK会从该路径下读取基本配置，保存云端交互日志。<br>
 *  注：需要在createAgent之前调用，否则无效。
 *
 *  @param path 路径（windows下以"\\"结尾，其他平台以"/"结尾），不能为空
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) setMscDir:(NSString *) path;

/*!
 *  设置msc.cfg的内容到SDK中。<br>
 *
 *  @param cfgStr msc.cfg中的实际内容
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) setMscCfg:(NSString *) cfgStr;

/*!
 *  初始化日志记录器，设置日志保存目录。<br>
 *  注：需要在createAgent之前调用，否则无效。
 *
 *  @param path 路径（windows下以"\\"结尾，其他平台以"/"结尾），为空则在AIUI工作目录下创建log目录
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) initLogger:(NSString *) path;

/*!
 *  设置日志打印级别，默认级别为LV_INFO。<br>
 *
 *  @param level 日志等级，具体取值参考AIUI_LOG_LEVEL定义
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) setLogLevel:(AIUI_LOG_LEVEL) level;

/*!
 *  设置是否保存数据日志，即输入的音频和云端返回的结果。<br>
 *
 *  @param save 是否保存
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) setSaveDataLog:(BOOL) save;

/*!
 *  设置数据日志保存目录，不设置则默认是在AIUI工作目录下的data目录。<br>
 *
 *  @param path 路径（windows下以"\\"结尾，其他平台以"/"结尾）。
 *  @return YES:设置成功；NO:设置失败
 */
+ (BOOL) setRawAudioDir:(NSString *) path;

/*!
 *  是否为移动互联网版本。<br>
 *
 *  @return YES:是；NO:不是
 */
+ (BOOL) isMobileVersion;

/*!
 *  获取版本类型。<br>
 *
 *  @return 参考AIUI_VERSION_TYPE定义
 */
+ (AIUI_VERSION_TYPE) getVersionType;


/*!
 *  获取版本号
 *
 *  @return  版本号
 */
+ (NSString *) getVersion;

/*!
 * 设置一些系统信息
 * @param key
 * @param val
 */
+ (void) setSystemInfo: (NSString *)key withVal: (NSString *)val;

/*!
 * 获取设置的系统信息
 * @param key
 * @return
 */
+ (NSString *) getSystemInfo: (NSString *)key;

@end
