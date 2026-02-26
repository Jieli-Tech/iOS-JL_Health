//
//  AIKITDataBuilder.h
//  AIKIT
//
//  Created by lxwang12 on 20203/03/16.
//
#import <Foundation/Foundation.h>
@class AIText;
@class AIAudio;
@class AIImage;
@class AIVideo;

NS_ASSUME_NONNULL_BEGIN

@protocol AIData<NSObject>
- (void*)getData;
@end

@protocol AIDataProtocol<NSObject>
- (id)setStatus:(NSInteger)status;
- (id)setBegin;
- (id)setCont;
- (id)setEnd;
- (id)setOnce;
@end

// AIText
@protocol AITextProtocol<AIDataProtocol>
- (id<AITextProtocol>)setTextData:(NSString*)data;
- (id<AITextProtocol>)setTextDataPath:(NSString*)path;

- (id<AITextProtocol>)setEncoding:(NSString*)encoding;
- (id<AITextProtocol>)setCompress:(NSString*)compress;
- (id<AITextProtocol>)setFormat:(NSString*)format;

- (AIText*)validCheck;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly)id<AITextProtocol>(^status)(NSInteger);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^begin)(void);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^cont)(void);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^end)(void);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^once)(void);

@property(nonatomic,copy,readonly)id<AITextProtocol>(^data)(NSString*);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^dataPath)(NSString*);

@property(nonatomic,copy,readonly)id<AITextProtocol>(^encoding)(NSString*);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^compress)(NSString*);
@property(nonatomic,copy,readonly)id<AITextProtocol>(^format)(NSString*);

@property(nonatomic,copy,readonly)AIText*(^valid)(void);
@end

@interface AIText : NSObject<AIData>
+ (id<AITextProtocol>)getHolder:(NSString*)key;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly,class)id<AITextProtocol>(^get)(NSString*);
#pragma mark - recommended parameters
+ (NSString*)ENCODING_UTF8  ; // @"utf-8"
+ (NSString*)ENCODING_GBK   ; // @"gbk"
+ (NSString*)ENCODING_GB2312; // @"gb2312"
+ (NSString*)ENCODING_DEF   ; // ENCODING_UTF8

+ (NSString*)COMPRESS_RAW   ; // @"raw"
+ (NSString*)COMPRESS_GZIP  ; // @"gzip"
+ (NSString*)COMPRESS_DEF   ; // COMPRESS_RAW

+ (NSString*)FORMAT_PLAIN   ; // @"plain"
+ (NSString*)FORMAT_JSON    ; // @"json"
+ (NSString*)FORMAT_XML     ; // @"xml"
+ (NSString*)FORMAT_DEF     ; // FORMAT_PLAIN
@end

// AIAudio
@protocol  AIAudioProtocol<AIDataProtocol>
- (id<AIAudioProtocol>)setAudioData:(NSData*)data;
- (id<AIAudioProtocol>)setAudioDataPath:(NSString*)path;

- (id<AIAudioProtocol>)setEncoding:(NSString*)encoding;
- (id<AIAudioProtocol>)setSampleRate:(NSInteger)sampleRate;
- (id<AIAudioProtocol>)setChannels:(NSInteger)channels;
- (id<AIAudioProtocol>)setBitDepth:(NSInteger)bitDepth;

- (AIAudio*)validCheck;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^status)(NSInteger);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^begin)(void);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^cont)(void);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^end)(void);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^once)(void);

@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^data)(NSData*);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^dataPath)(NSString*);

@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^encoding)(NSString*);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^sampleRate)(NSInteger);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^channels)(NSInteger);
@property(nonatomic,copy,readonly)id<AIAudioProtocol>(^bitDepth)(NSInteger);

@property(nonatomic,copy,readonly)AIAudio*(^valid)(void);
@end

@interface AIAudio : NSObject<AIData>
+ (id<AIAudioProtocol>)getHolder:(NSString*)key;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly,class)id<AIAudioProtocol>(^get)(NSString*);
#pragma mark - recommended parameters
+ (NSString*)ENCODING_PCM      ; //@"pcm";
+ (NSString*)ENCODING_RAW      ; //@"raw";
+ (NSString*)ENCODING_ICO      ; //@"ico";
+ (NSString*)ENCODING_SPEEX    ; //@"speex";
+ (NSString*)ENCODING_SPEEX_WB ; //@"speex-wb";
+ (NSString*)ENCODING_LAME     ; //@"lame";
+ (NSString*)ENCODING_OPUS     ; //@"opus";
+ (NSString*)ENCODING_OPUS_WB  ; //@"opus-wb";
+ (NSString*)ENCODING_WAV      ; //@"wav";
+ (NSString*)ENCODING_AMR      ; //@"amr";
+ (NSString*)ENCODING_AMR_WB   ; //@"amr-wb";
+ (NSString*)ENCODING_MP3      ; //@"mp3";
+ (NSString*)ENCODING_CDA      ; //@"cda";
+ (NSString*)ENCODING_WAVE     ; //@"wave";
+ (NSString*)ENCODING_AIFF     ; //@"aiff";
+ (NSString*)ENCODING_MPEG     ; //@"mpeg";
+ (NSString*)ENCODING_MID      ; //@"mid";
+ (NSString*)ENCODING_WMA      ; //@"wma";
+ (NSString*)ENCODING_RA       ; //@"ra";
+ (NSString*)ENCODING_RM       ; //@"rm";
+ (NSString*)ENCODING_RMX      ; //@"rmx";
+ (NSString*)ENCODING_VQF      ; //@"vqf";
+ (NSString*)ENCODING_OGG      ; //@"ogg";
+ (NSString*)ENCODING_DEF      ; //ENCODING_SPEEX_WB;

+ (NSInteger)SAMPLE_RATE_8K ; //8000;
+ (NSInteger)SAMPLE_RATE_16K; //16000;
+ (NSInteger)SAMPLE_RATE_DEF; //SAMPLE_RATE_16K;

+ (NSInteger)CHANNELS_1  ; //1;
+ (NSInteger)CHANNELS_2  ; //2;
+ (NSInteger)CHANNELS_DEF; //CHANNELS_1;

+ (NSInteger)BIT_DEPTH_8  ; //8;
+ (NSInteger)BIT_DEPTH_16 ; //16;
+ (NSInteger)BIT_DEPTH_DEF; //BIT_DEPTH_16;
@end

// AIImage
@protocol AIImageProtocol <AIDataProtocol>
- (id<AIImageProtocol>)setImageData:(NSData*)data;
- (id<AIImageProtocol>)setImageDataPath:(NSString*)path;

- (id<AIImageProtocol>)setEncoding:(NSString*)encoding;
- (id<AIImageProtocol>)setWidth:(NSInteger)width;
- (id<AIImageProtocol>)setHeight:(NSInteger)height;
- (id<AIImageProtocol>)setDims:(NSInteger)dims;

- (AIImage*)validCheck;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^status)(NSInteger);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^begin)(void);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^cont)(void);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^end)(void);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^once)(void);

@property(nonatomic,copy,readonly)id<AIImageProtocol>(^data)(NSData*);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^dataPath)(NSString*);

@property(nonatomic,copy,readonly)id<AIImageProtocol>(^encoding)(NSString*);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^width)(NSInteger);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^height)(NSInteger);
@property(nonatomic,copy,readonly)id<AIImageProtocol>(^dims)(NSInteger);

@property(nonatomic,copy,readonly)AIImage*(^valid)(void);
@end

@interface AIImage : NSObject<AIData>
+ (id<AIImageProtocol>)getHolder:(NSString*)key;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly,class)id<AIImageProtocol>(^get)(NSString*);
#pragma mark - recommended parameters
+ (NSString*)ENCODING_RAW   ; //@"raw";
+ (NSString*)ENCODING_JPG   ; //@"jpg";
+ (NSString*)ENCODING_JPEG  ; //@"jpeg";
+ (NSString*)ENCODING_PNG   ; //@"png";
+ (NSString*)ENCODING_APNG  ; //@"apng";
+ (NSString*)ENCODING_BMP   ; //@"bmp";
+ (NSString*)ENCODING_WEBP  ; //@"webp";
+ (NSString*)ENCODING_TIFF  ; //@"tiff";
+ (NSString*)ENCODING_RGB565; //@"rgb565";
+ (NSString*)ENCODING_RGB888; //@"rgb888";
+ (NSString*)ENCODING_BGR565; //@"bgr565";
+ (NSString*)ENCODING_BGR888; //@"bgr888";
+ (NSString*)ENCODING_YUV12 ; //@"yuv12";
+ (NSString*)ENCODING_YUV21 ; //@"yuv21";
+ (NSString*)ENCODING_YUV420; //@"yuv420";
+ (NSString*)ENCODING_YUV422; //@"yuv422";
+ (NSString*)ENCODING_PSD   ; //@"psd";
+ (NSString*)ENCODING_PCD   ; //@"pcd";
+ (NSString*)ENCODING_DEF   ; //ENCODING_JPG;
@end

// AIVideo
@protocol AIVideoProtocol<AIDataProtocol>
- (id<AIVideoProtocol>)setVideoData:(NSData*)data;
- (id<AIVideoProtocol>)setVideoDataPath:(NSString*)path;

- (id<AIVideoProtocol>)setEncoding:(NSString*)encoding;
- (id<AIVideoProtocol>)setWidth:(NSInteger)width;
- (id<AIVideoProtocol>)setHeight:(NSInteger)height;
- (id<AIVideoProtocol>)setFrameRate:(NSInteger)frameRate;

- (AIVideo*)validCheck;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^status)(NSInteger);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^begin)(void);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^cont)(void);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^end)(void);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^once)(void);

@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^data)(NSData*);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^dataPath)(NSString*);

@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^encoding)(NSString*);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^width)(NSInteger);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^height)(NSInteger);
@property(nonatomic,copy,readonly)id<AIVideoProtocol>(^frameRate)(NSInteger);

@property(nonatomic,copy,readonly)AIVideo*(^valid)(void);
@end

@interface AIVideo : NSObject<AIData>
+ (id<AIVideoProtocol>)getHolder:(NSString*)key;
#pragma mark - chain's invoke
@property(nonatomic,copy,readonly,class)id<AIVideoProtocol>(^get)(NSString*);
#pragma mark - recommended parameters
+ (NSString*)ENCODING_H264; //@"h264";
+ (NSString*)ENCODING_H265; //@"h265";
+ (NSString*)ENCODING_AVI ; //@"avi";
+ (NSString*)ENCODING_NAVI; //@"navi";
+ (NSString*)ENCODING_MP4 ; //@"mp4";
+ (NSString*)ENCODING_RM  ; //@"rm";
+ (NSString*)ENCODING_RMVB; //@"rmvb";
+ (NSString*)ENCODING_MKV ; //@"mkv";
+ (NSString*)ENCODING_FLV ; //@"flv";
+ (NSString*)ENCODING_F4V ; //@"f4v";
+ (NSString*)ENCODING_MPG ; //@"mpg";
+ (NSString*)ENCODING_MLV ; //@"mlv";
+ (NSString*)ENCODING_MPE ; //@"mpe";
+ (NSString*)ENCODING_MPEG; //@"mpeg";
+ (NSString*)ENCODING_DAT ; //@"dat";
+ (NSString*)ENCODING_M2V ; //@"m2v";
+ (NSString*)ENCODING_VOB ; //@"vob";
+ (NSString*)ENCODING_ASF ; //@"asf";
+ (NSString*)ENCODING_MOV ; //@"mov";
+ (NSString*)ENCODING_WMV ; //@"wmv";
+ (NSString*)ENCODING_3GP ; //@"3gp";
+ (NSString*)ENCODING_DEF ; //ENCODING_H264;
@end

NS_ASSUME_NONNULL_END
