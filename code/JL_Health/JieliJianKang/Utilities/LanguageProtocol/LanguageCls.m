//
//  LanguageCls.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/12/24.
//

#import "LanguageCls.h"

#define LocalLanguage  @"LocalLanguage"

@interface LanguageCls()

@property(nonatomic,strong)NSHashTable         *delegates;
@property(nonatomic,strong)NSLock              *delegateLock;

@end

@implementation LanguageCls


+(instancetype)share{
    static LanguageCls *me;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[LanguageCls alloc] init];
    });
    return me;
}

-(NSLock *)delegateLock{
    if (_delegateLock == nil) {
        _delegateLock = [NSLock new];
    }
    return _delegateLock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

-(void)add:(id<LanguagePtl>)objc{
    [self.delegateLock lock];
    if (![self.delegates containsObject:objc]) {
        [self.delegates addObject:objc];
    }
    [self.delegateLock unlock];
}

-(void)remove:(id<LanguagePtl>)objc{
    [self.delegateLock lock];
    if ([self.delegates containsObject:objc]) {
        [self.delegates removeObject:objc];
    }
    [self.delegateLock unlock];
}

-(void)setLanguage:(NSString *)lgg{
    for (NSObject<LanguagePtl> *objc in self.delegates) {
        if ([objc respondsToSelector:@selector(languageChange)]) {
            [objc languageChange];
        }
    }
}

+(NSString *)checkLanguage {
    NSString *objc = [[NSUserDefaults standardUserDefaults] valueForKey:LocalLanguage];
    if (objc) {
        return objc;
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"auto" forKey:LocalLanguage];
        return [DFUITools systemLanguage];
    }
}

+(void)setLangague:(NSString *)lan{
    [[NSUserDefaults standardUserDefaults] setValue:lan forKey:LocalLanguage];
    if ([lan isEqual:@"auto"]) {
        NSString *str = [DFUITools systemLanguage];
        [DFUITools languageSet:[self getLan:str]];
        [[self share] setLanguage:str];
    }else{
        [DFUITools languageSet:lan];
        [[self share] setLanguage:lan];
    }
    
}

+(NSString *)localizableTxt:(NSString *)key{
    NSString *mlan = [DFUITools getLanguage];
    NSString *path = [[NSBundle mainBundle] pathForResource:mlan ofType:@"lproj"];
   
    NSString *nonePath = [[NSBundle mainBundle] pathForResource:@"en-GB" ofType:@"lproj"];//默认匹配不了时的语言
    NSString *defaultStr = [[NSBundle bundleWithPath:nonePath] localizedStringForKey:key value:nil table:@"Localizable"];
    
    NSString *str= [[NSBundle bundleWithPath:path] localizedStringForKey:key value:defaultStr table:@"Localizable"];
    
    if (str == nil) {
        /*--- 检测当前语言 ---*/
        NSString *path;
        if ([mlan hasPrefix:@"en"]) {
            path = [[NSBundle mainBundle] pathForResource:@"en-GB" ofType:@"lproj"];
        }else if ([mlan hasPrefix:@"zh-Hans"]){
            path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
        }else{
            path = [[NSBundle mainBundle] pathForResource:@"en-GB" ofType:@"lproj"];
        }
        str = [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:@"Localizable"];
    }
    
    return str;
}


+(NSString *)getLan:(NSString *)str{
    NSString *lan = @"auto";
    if ([str hasPrefix:@"en"]) {
        lan = @"en-GB";
    }else if ([str hasPrefix:@"zh-Hans"]){
        lan = @"zh-Hans";
    }else if ([str hasPrefix:@"ja"]){
        lan = @"ja";
    }else if ([str hasPrefix:@"ko"]){
        lan = @"ko";
    }else if ([str hasPrefix:@"fr"]){
        lan = @"fr";
    }else if ([str hasPrefix:@"de"]){
        lan = @"de";
    }else if ([str hasPrefix:@"it"]){
        lan = @"it";
    }else if ([str hasPrefix:@"pt-PT"]){
        lan = @"pt-PT";
    }else if ([str hasPrefix:@"es"]){
        lan = @"es";
    }else if ([str hasPrefix:@"sv"]){
        lan = @"sv";
    }else if ([str hasPrefix:@"pl"]){
        lan = @"pl";
    }else if ([str hasPrefix:@"ru"]){
        lan = @"ru";
    }else if ([str hasPrefix:@"tr"]){
        lan = @"tr";
    }else if ([str hasPrefix:@"vi"]){
        lan = @"vi";
    }else if ([str hasPrefix:@"he"]){
        lan = @"he";
    }else if ([str hasPrefix:@"th"]){
        lan = @"th";
    }else if ([str hasPrefix:@"ar"]){
        lan = @"ar";
    }else if ([str hasPrefix:@"id"]){
        lan = @"id";
    }else if ([str hasPrefix:@"ms"]){
        lan = @"ms";
    }else if ([str hasPrefix:@"fa"]){
        lan = @"fa";
    }else{
        lan = @"auto";
    }
    
    return lan;
}




@end
