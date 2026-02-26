//
//  SyncThreadManager.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SyncThreadDelegate <NSObject>

-(void)syncTaskFinish:(NSData * _Nullable)data type:(JL_SmallFileType)type;

@end

@interface SyncObject:NSObject
@property(nonatomic,assign)JL_SmallFileType type;
@property(nonatomic,strong)JL_SmallFileManager *smallFileManager;
@end

@interface SyncThreadManager : NSObject

@property(nonatomic,weak)id<SyncThreadDelegate> delegate;



-(void)addTask:(SyncObject *)objc;

-(void)removeAllTask;

-(void)syncById:(UInt16 )spid with:(JL_SmallFileManager *)ft;

@end

NS_ASSUME_NONNULL_END
