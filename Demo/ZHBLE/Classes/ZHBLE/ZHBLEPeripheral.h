//
//  ZHBLEPeripheral.h
//  BLE_iOS
//
//  Created by aimoke on 15/7/16.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZHBLEBlocks.h"

@interface ZHBLEPeripheral : NSObject
@property (nonatomic, strong, readonly) CBPeripheral * peripheral;
@property (nonatomic) NSArray * services;
@property (nonatomic, strong) NSUUID *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *RSSI;//You should use readRSSIOnFinish replace it.
@property (readonly) CBPeripheralState state;
@property (nonatomic, copy) ZHServicesUpdated onServiceModified;
@property (nonatomic, copy) ZHObjectChagedBlock onNameUpdated;
@property (nonatomic, copy) ZHCharacteristicChangeBlock notificationStateChanged;
@property (nonatomic, copy) ZHPeripheralConnectionBlock onConnectionFinished;
@property (nonatomic, copy) ZHPeripheralConnectionBlock onDisconnected;


#pragma mark initial Methods
-(instancetype)initWithPeripheral:(CBPeripheral *) peripheral;


#pragma mark discovery services
-(void)discoverServices:(NSArray *)serviceUUIDs onFinish:(ZHObjectChagedBlock)discoverFinished;

- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(ZHSpecifiedServiceUpdatedBlock) finished;


#pragma mark Discovering Characteristics and Characteristic Descriptors
- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service onFinish:(ZHSpecifiedServiceUpdatedBlock) onfinish;

- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic onFinish:(ZHCharacteristicChangeBlock) onfinish;


#pragma mark Reading Characteristic and Characteristic Descriptor Values
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic onFinish:(ZHCharacteristicChangeBlock) onUpdate;

- (void)readValueForDescriptor:(CBDescriptor *)descriptor onFinish:(ZHDescriptorChangedBlock) onUpdate;


#pragma mark Writing Characteristic and Characteristic Descriptor Values
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type onFinish:(ZHCharacteristicChangeBlock) onfinish;

- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor onFinish:(ZHDescriptorChangedBlock) onfinish;


#pragma mark Setting Notifications for a Characteristic’s Value
- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic onUpdated:(ZHCharacteristicChangeBlock) onUpdated;


#pragma mark ReadRSSI
- (void)readRSSIOnFinish:(ZHPeripheralUpdateRSSIBlock)onUpdated;

#pragma mark cleanup
/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup;
@end
