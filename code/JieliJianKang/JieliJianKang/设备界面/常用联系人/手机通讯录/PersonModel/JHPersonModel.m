//
// Created by junhuai on 2019/12/11.
// Copyright (c) 2019 junhuai. All rights reserved.
//

#import "JHPersonModel.h"
#import "ChineseToPinyin.h"
#import "JL_RunSDK.h"

@implementation JHPersonModel {

}
- (instancetype)initWithFullName:(NSString *)fullName {
    self = [super init];
    if (self) {
        self.fullName = fullName;
    }

    return self;
}

+ (instancetype)modelWithFullName:(NSString *)fullName {
    return [[self alloc] initWithFullName:fullName];
}

/**
 * 通过 contact 来初始化
 * @param contact  contact
 * @return instancetype
 */
- (instancetype)initWithContact:(CNContact *)contact {
    self = [super init];
    if (self) {
        // 获取姓名
        self.fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];  // 自动格式化名字
        self.givenName = contact.givenName;
        self.familyName = contact.familyName;
        self.nickName = contact.nickname;

        // 获得全名的拼音
        if (self.fullName != nil || self.fullName.length != 0){
            self.py = [ChineseToPinyin letterPinyinFromChineseString:self.fullName];
            self.pinyin = [ChineseToPinyin pinyinFromChineseString:self.fullName withSpace:NO];
        } else{
            self.fullName = @"";
            self.py = @"";
            self.pinyin = @"";
        }
//        NSLog(@"%@:%@:%@", _fullName, _py, _pinyin);

        // 生日
        self.birthday = [contact.birthday date];

//        NSLog(@"%@ : %@ : %@", self.fullName, self.givenNameLabel, self.familyNameLabel);

        // 获取电话号码
        NSArray *phones = contact.phoneNumbers;
        NSMutableArray *phonesValue = [[NSMutableArray alloc] init];
        for (CNLabeledValue *labelValue in phones) {
            CNPhoneNumber *phoneNumber = labelValue.value;
//            NSLog(@"%@ %@ ", phoneNumber.stringValue, labelValue.label);
            JHValue *value = [JHValue valueWithValue:phoneNumber.stringValue type:[self getTypes:labelValue.label]];
            [phonesValue addObject:value];
        }
        // 加入到里面
        self.phones = [phonesValue copy];  // copy 使其不可拷贝化
        
        if (self.phones.count > 0) {
            self.phoneNum = self.phones[0].value;
        }
        
        // 获取邮件
        NSArray *email = contact.emailAddresses;
        NSMutableArray *emailValue = [[NSMutableArray alloc] init];
        for (CNLabeledValue *labelValue in email) {
//            NSLog(@"%@ %@ ", labelValue.value, labelValue.label);
            JHValue *value = [JHValue valueWithValue:labelValue.value type:[self getTypes:labelValue.label]];
            [emailValue addObject:value];
        }
        self.emails = [emailValue copy];

        // 图片
        if (contact.imageData) {
            self.image = [UIImage imageWithData:contact.imageData];
//            NSLog(@"有图  %@", self.fullName);
        }

        if (contact.imageData) {
            self.smallImage = [UIImage imageWithData:contact.thumbnailImageData];
//            NSLog(@"小图  %@", self.fullName);
        }

        // 将当前 contact 加入
        self.contact = contact;

        //加入群组信息
//        self.group =

    }
    return self;
}

+ (instancetype)modelWithContact:(CNContact *)contact {
    return [[self alloc] initWithContact:contact];
}

/// 标签转换
/// @param tag 标记类型
/// @return  转换后的类型
- (NSString *)getTypes:(NSString *)tag {
//    NSDictionary *tagDic = @{CNLabelPhoneNumberMobile: @"手机", CNLabelPhoneNumberMain: @"主号码", CNLabelHome: @"家",
//            CNLabelWork: @"公司", CNLabelSchool: @"学校", CNLabelPhoneNumberiPhone: @"iPhone",
//            CNLabelPhoneNumberHomeFax: @"家用传真", CNLabelPhoneNumberWorkFax: @"工作传真",};
    return  kJL_TXT("手机");//return tagDic[tag] ? tagDic[tag] : @"其他";
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.fullName forKey:@"fullName"];
    [coder encodeObject:self.phoneNum forKey:@"phoneNum"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.fullName = [coder decodeObjectForKey:@"fullName"];
        self.phoneNum = [coder decodeObjectForKey:@"phoneNum"];
    }
    return self;
}

@end

///  JHValue
@implementation JHValue {

}

- (instancetype)initWithValue:(NSString *)value type:(NSString *)type {
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
    }

    return self;
}

+ (instancetype)valueWithValue:(NSString *)value type:(NSString *)type {
    return [[self alloc] initWithValue:value type:type];
}

@end
