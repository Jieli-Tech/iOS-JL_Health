//
// Created by junhuai on 2019/12/11.
// Copyright (c) 2019 junhuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>

@class JHValue;

@interface JHPersonModel : NSObject<NSCopying>
// 基本信息
@property(nonatomic,assign) BOOL      select;
@property(nonatomic,assign) BOOL      contactsSelect;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *givenName;
@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, strong) NSDate *birthday;
// 联系方式
@property (nonatomic, strong) NSArray<JHValue*> *phones;
@property (nonatomic, strong) NSArray<JHValue*> *emails;
@property (nonatomic, copy) NSString *phoneNum;
// 图片
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *smallImage;
// 加入拼音
@property (nonatomic, copy) NSString *py;
@property (nonatomic, copy) NSString *pinyin;
// contact信息
@property (nonatomic, strong) CNContact *contact;
// 群组信息
@property (nonatomic, copy) NSString *group;

- (instancetype)initWithFullName:(NSString *)fullName;

- (instancetype)initWithContact:(CNContact *)contact;

+ (instancetype)modelWithContact:(CNContact *)contact;

+ (instancetype)modelWithFullName:(NSString *)fullName;
// 缩略图

@end

@interface JHValue : NSObject
// 值和类型
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *type;

- (instancetype)initWithValue:(NSString *)value type:(NSString *)type;

+ (instancetype)valueWithValue:(NSString *)value type:(NSString *)type;


@end
