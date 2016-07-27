//
//  ZHStoredPeripherals.m
//  BLE_IOS
//
//  Created by aimoke on 15/7/16.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import "ZHStoredPeripherals.h"

@implementation ZHStoredPeripherals
+ (void)initializeStorage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    if (devices == nil) {
        [userDefaults setObject:@[] forKey:@"storedPeripherals"];
        [userDefaults synchronize];
    }
}


+ (NSArray *)genIdentifiers {
    NSMutableArray *result= [NSMutableArray new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    
    for (id uuidString in devices) {
        if (![uuidString isKindOfClass:[NSString class]]) {
            continue;
        }
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        
        if (!uuid)
            continue;
        
        [result addObject:uuid];
    }
    
    return result;
}


+ (void)saveUUID:(NSUUID *)UUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *existingDevices = [userDefaults objectForKey:@"storedPeripherals"];
    NSMutableArray *devices;
    NSString *uuidString = nil;
    if (UUID != nil) {
        uuidString = [UUID UUIDString];
        
        if (existingDevices != nil) {
            devices = [[NSMutableArray alloc] initWithArray:existingDevices];
            
            if (uuidString) {
                BOOL test = YES;
                
                for (NSString *obj in existingDevices) {
                    if ([obj isEqualToString:uuidString]) {
                        test = NO;
                        break;
                    }
                }
                if (test) {
                    [devices addObject:uuidString];
                }
            }
        }
        else {
            devices = [[NSMutableArray alloc] init];
            [devices addObject:uuidString];
        }
        [userDefaults setObject:devices forKey:@"storedPeripherals"];
        [userDefaults synchronize];
    }
}

+ (void)deleteUUID:(NSUUID *)UUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults arrayForKey:@"storedPeripherals"];
    NSMutableArray *newDevices = [NSMutableArray arrayWithArray:devices];
    
    NSString *uuidString = [UUID UUIDString];
    
    [newDevices removeObject:uuidString];
    
    [userDefaults setObject:newDevices forKey:@"storedPeripherals"];
    [userDefaults synchronize];
}


@end
