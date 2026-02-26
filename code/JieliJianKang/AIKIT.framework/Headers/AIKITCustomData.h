//
//  AEECustomData.h
//  AEE
//
//  Created by Jean on 2021/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIKITCustomData : NSObject

- (void)addText:(NSString*)text key:(NSString*)key index:(int)index;

- (void)addTextPath:(NSString*)path key:(NSString*)key index:(int)index;

- (void)addImage:(NSData*)image key:(NSString*)key index:(int)index;

- (void)addImagePath:(NSString*)path key:(NSString*)key index:(int)index;

- (void)addVideo:(NSData*)video key:(NSString*)key index:(int)index;

- (void)addVideoPath:(NSString*)path key:(NSString*)key index:(int)index;

- (void)addAudio:(NSData*)audio key:(NSString*)key index:(int)index;

- (void)addAudioPath:(NSString*)path key:(NSString*)key index:(int)index;

- (void *)getCustomBuilder;

@end

NS_ASSUME_NONNULL_END
