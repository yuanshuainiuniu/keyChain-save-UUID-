//
//  Tool.m
//  keyChain
//
//  Created by GoBeta on 15/5/6.
//  Copyright (c) 2015年 Marshal. All rights reserved.
//

#define KEY_UDID            @"KEY_UDID"
#define KEY_IN_KEYCHAIN     @"KEY_IN_KEYCHAIN"

#import <Security/Security.h>
#import <UIKit/UIKit.h>
#import "Tool.h"

@interface Tool ()

@end
@implementation Tool

#pragma mark 获取UUID
/**
 *此uuid在相同的一个程序里面-相同的vindor-相同的设备下是不会改变的
 *此uuid是唯一的，但应用删除再重新安装后会变化，采取的措施是：只获取一次保存在钥匙串中，之后就从钥匙串中获取
 **/
+ (NSString *)openUDID
{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    return identifierForVendor;
}

#pragma mark 保存UUID到钥匙串

+ (void)saveUDID:(NSString *)udid
{
    NSMutableDictionary *udidKVPairs = [NSMutableDictionary dictionary];
    [udidKVPairs setObject:udid forKey:KEY_UDID];
    [self save:KEY_IN_KEYCHAIN data:udidKVPairs];
}
#pragma mark 读取UUID
/**
 *先从内存中获取uuid，如果没有再从钥匙串中获取，如果还没有就生成一个新的uuid，并保存到钥匙串中供以后使用
 **/
+ (id)readUDID
{
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_UDID];
    if (uuid == nil || uuid.length == 0) {
        NSMutableDictionary *udidKVPairs = (NSMutableDictionary *)[self load:KEY_IN_KEYCHAIN];
        uuid = [udidKVPairs objectForKey:KEY_UDID];
    }
    if (uuid == nil || uuid.length == 0) {
        uuid = [self openUDID];
        [self saveUDID:uuid];
        //缓存下来
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:KEY_UDID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return uuid;
}

#pragma mark 删除UUID
+ (void)deleteUUID
{
    //删除本地
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_UDID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //删除keychain
    [self delete:KEY_IN_KEYCHAIN];
}

#pragma mark 查询钥匙串
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,nil];
}

#pragma mark 将数据保存到钥匙串
+ (void)save:(NSString *)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

#pragma mark 加载钥匙串中数据
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

#pragma mark 删除钥匙串中数据
+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}
@end
