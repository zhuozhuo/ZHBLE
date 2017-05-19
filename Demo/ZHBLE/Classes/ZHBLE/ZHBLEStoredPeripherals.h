//
//  ZHStoredPeripherals.h
//  BLE_iOS
//
//  Created by aimoke on 15/7/16.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ZHBLEStoredPeripherals : NSObject

+ (void)initializeStorage;

+ (NSArray *)genIdentifiers;

+ (void)saveUUID:(NSUUID *)UUID;

+ (void)deleteUUID:(NSUUID *)UUID;
@end
