//
//  ZHPeripheralManager.h
//  ZHBLE
//
//  Created by aimoke on 15/9/6.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHBLEBlocks.h"

@interface ZHBLEPeripheralManager : NSObject
@property (nonatomic, readonly) BOOL isAdvertizing;
@property (nonatomic, readonly) CBManagerState state;
@property (nonatomic, copy) ZHObjectChagedBlock onStateUpdated;
@property (nonatomic, copy) ZHPeripheralManagerStatedChangedBlock onWillRestoreState;
@property (nonatomic, copy) ZHCentralSubscriptionBlock onSubscribedBlock;
@property (nonatomic, copy) ZHCentralSubscriptionBlock onUnsubscribedBlock;
@property (nonatomic, copy) ZhCentralReadRequestBlock onReceivedReadRequest;
@property (nonatomic, copy) ZHCentralWriteRequestBlock onReceiveWriteRequest;
@property (nonatomic, copy) ZHObjectChagedBlock onReadToUpdateSubscribers;

@property (nonatomic, strong) NSArray * services;
@property (nonatomic, strong) NSMutableArray *addedServices;
@property (nonatomic, strong) CBPeripheralManager * peripheralManager;

#pragma mark INIT Methods
+(ZHBLEPeripheralManager *)sharedZHBLEPeripheralManager;


- (instancetype)initWithQueue:(dispatch_queue_t)queue;
- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options NS_AVAILABLE(NA, 7_0);

#pragma mark Adding and Removing Services
- (void)addService:(CBMutableService *)service onFinish:(ZHSpecifiedServiceUpdatedBlock) onfinish;
- (void)removeService:(CBMutableService *)service;
- (void)removeAllServices;


#pragma mark Managing Advertising

- (void)startAdvertising:(NSDictionary *)advertisementData onStarted:(ZHObjectChagedBlock) onstarted;
- (void)stopAdvertising;


#pragma mark Sending Updates of a Characteristic’s Value

- (BOOL)updateValue:(NSData *)value forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:(NSArray *)centrals;

#pragma mark Responding to Read and Write Requests

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result;
#pragma mark Setting Connection Latency

- (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central;
@end
