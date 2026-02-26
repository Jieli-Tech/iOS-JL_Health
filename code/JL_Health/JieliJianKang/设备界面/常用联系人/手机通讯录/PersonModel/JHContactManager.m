//
// Created by junhuai on 2019/12/11.
// Copyright (c) 2019 junhuai. All rights reserved.
//

#import "JHContactManager.h"
#import <ContactsUI/ContactsUI.h>

NSString * const JHPersonsDidChangeNotification = @"JHPersonsDidChangeNotification";

@implementation JHContactManager {
    CNContactStore *_store;
    NSMutableArray<JHPersonModel * > *_mutablePersons;
    NSArray *_fetchKeys;
    NSArray<JHPersonModel *> *_persons;
    NSMutableArray<NSString *> *_groups;
    NSMutableArray *_groupID;
    NSMutableArray *_groupPersons;
    NSArray *_group;
}

/**
 * 获取关键字
 * @return
 */
- (NSArray *)fetchKeys {
    if (!_fetchKeys) {
        _fetchKeys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],   // 这个可以自动生成姓名格式
                CNContactGivenNameKey, CNContactFamilyNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactThumbnailImageDataKey,
                CNContactViewController.descriptorForRequiredKeys, // 这个用于进入系统编辑页面
                CNGroupNameKey];  // 获得群组
    }
    return _fetchKeys;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _store = [[CNContactStore alloc] init];
        _mutablePersons = [[NSMutableArray alloc] init];
        _groups = [[NSMutableArray alloc] init];
        _groupPersons = [[NSMutableArray alloc] init];
        _groupID = [[NSMutableArray alloc] init];


        // 在通知中心注册
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:CNContactStoreDidChangeNotification object:nil];

    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CNContactStoreDidChangeNotification object:nil];
}

- (void) update{
    [self fetchAllPerson:nil];
    [self fetchGroups];
    [self fetchGroupPersons];
    [[NSNotificationCenter defaultCenter] postNotificationName:JHPersonsDidChangeNotification object:nil]; // 慢慢通知

}


// 单例模式
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

// 请求授权
- (void)requestContactAuthorization:(void (^)(void))completion {
    // 获得授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    // 如果是未授权，则请求授权  这里是并行的，回调
    if (status == CNAuthorizationStatusNotDetermined) {
//        kJLLog(JLLOG_DEBUG, @"in");
        [_store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                //kJLLog(JLLOG_DEBUG, @"授权成功");
                completion();  // 回调刷新
//                kJLLog(JLLOG_DEBUG, @"回调时 %@", [NSThread currentThread]);
            } else
                ///(@"授权失败");
//            result = granted;
            self.authorized = granted;
        }];
    }
}

// 看是否已授权
- (BOOL)isAuthorized {
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized ? YES : NO;
}

// 获得所有联系人
- (void)fetchAllPerson:(void(^)(NSArray<JHPersonModel *> *allPersons))result{
    // 先确定要请求的 keys
    // 创建请求对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.fetchKeys];
    // 应该移除所有子数组
    [_mutablePersons removeAllObjects];
    // 请求
    NSError *error = nil;
    [_store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact *contact, BOOL *stop) {
        // stop是决定是否要停止
        JHPersonModel *personModel = [JHPersonModel modelWithContact:contact];
        [self->_mutablePersons addObject:personModel];
    }];
    if (error == nil){
        _persons = [self->_mutablePersons copy];
        if (result) result(_persons);
    }
}

- (NSArray<JHPersonModel *> *)persons {
//    // 改成直接从本地获取
//    if (_persons.count == 0){
//        [self fetchAllPerson];
//    }
    // 返回不可改变的对象
    return _persons;
}

// 获取群组
- (void) fetchGroups{
    [_groups removeAllObjects];
    NSArray *cnGroups = [_store groupsMatchingPredicate:nil error:nil];
//    NSArray *container = [_store containersMatchingPredicate:nil error:nil];
    _group = cnGroups;  // 获取群组
    for (CNGroup * group in cnGroups) {
        if (group)
        [_groups addObject:[NSString stringWithString:group.name]];
        [_groupID addObject:[NSString stringWithString:group.identifier]];
    }
}

- (NSArray<NSString *> *)groups {
    if (!_groups)
        _groups = [[NSMutableArray alloc] init];
    if (_groups.count == 0){
        [self fetchGroups];
    }

    return [_groups copy];
}

// 获得群组中的联系人
- (void) fetchGroupPersons{
    [_groupPersons removeAllObjects];
    for (NSString * groupId in _groupID) {
        // 新建一个数组
        NSMutableArray *gPerson = [[NSMutableArray alloc] init];
        // 检索条件
        NSPredicate *predicate = [CNContact predicateForContactsInGroupWithIdentifier:groupId];
        // 提取数据
        NSArray *contacts = [_store unifiedContactsMatchingPredicate:predicate  keysToFetch:self.fetchKeys error:nil];
        for (CNContact *contact in contacts) {
            JHPersonModel *personModel = [JHPersonModel modelWithContact:contact];
            [gPerson addObject:personModel];
        }
        // 加入到新数组
        [_groupPersons addObject:gPerson];
    }

}

- (NSArray *)groupPersons {
    if(!_groupPersons)
        _groupPersons = [[NSMutableArray alloc] init];
    if (_groupPersons.count == 0)
        [self fetchGroupPersons];
    return [_groupPersons copy];
}

// 将其加入群组
- (BOOL)addPersonToGroup:(CNContact *)contact index:(NSUInteger)index{
    // 创建请求
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
//    CNMutableGroup *mutableGroup = _group[index];
    [saveRequest addMember:contact toGroup:_group[index]];
    NSError *error = nil;
    // 保存到通讯录
    [_store executeSaveRequest:saveRequest error:&error];
    if (error)
        return NO;
    else
        return YES;

}


@end
