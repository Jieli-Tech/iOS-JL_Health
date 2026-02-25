//
// Created by junhuai on 2019/12/11.
// Copyright (c) 2019 junhuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "JHPersonModel.h"

CONTACTS_EXTERN NSString * const JHPersonsDidChangeNotification;

@interface JHContactManager : NSObject
@property(atomic, assign) BOOL authorized;
@property (nonatomic, strong, readonly) NSArray<JHPersonModel *> *persons;
@property(nonatomic, copy, readonly) NSArray *fetchKeys;
@property (nonatomic, copy, readonly) NSArray<NSString *> *groups;
@property (nonatomic, copy, readonly) NSArray *groupPersons;

+ (instancetype)sharedInstance;

- (void)requestContactAuthorization:(void (^)(void))completion;
- (void)fetchAllPerson:(void(^)(NSArray<JHPersonModel *> *allPersons))result;

//-(BOOL) requestContactAuthorization;
-(BOOL) isAuthorized;
//- (NSArray<JHPersonModel *> *)persons;
- (BOOL)addPersonToGroup:(CNContact *)contact index:(NSUInteger)index;
@end
