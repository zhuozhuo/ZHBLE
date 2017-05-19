//
//  ZHPeripheralManager.m
//  ZHBLE
//
//  Created by aimoke on 15/9/6.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ZHBLEPeripheralManager.h"
#import "ZHBLECentral.h"

@interface ZHBLEPeripheralManager()<CBPeripheralManagerDelegate>


@property (nonatomic, strong) NSMutableDictionary * serviceAddingBlocks;
@property (nonatomic, copy) ZHObjectChagedBlock advertisingStartedBlock;

@property (nonatomic, strong) NSDictionary * initialzedOptions;
@property (nonatomic, strong) dispatch_queue_t queue;

@end
@implementation ZHBLEPeripheralManager

#pragma mark - INIT Methods

+(ZHBLEPeripheralManager *)sharedZHBLEPeripheralManager
{
   static  ZHBLEPeripheralManager *_blePeripheralManagerFactory = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        
        NSDictionary * opts = nil;
        if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
        {
            //DebugLog(@"%f",[[UIDevice currentDevice].systemVersion floatValue]);
            opts = @{CBPeripheralManagerOptionShowPowerAlertKey:@YES};
        }
//        NSDate *da = [NSDate date];
//        NSString *daStr = [da description];
//        const char *queueName = [daStr UTF8String];
//        dispatch_queue_t myQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_PRIORITY_DEFAULT);
        
        _blePeripheralManagerFactory = [[ZHBLEPeripheralManager alloc]initWithQueue:nil options:nil];
    });
    return _blePeripheralManagerFactory;
    
}



-(instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:queue options:nil];
    }
    return self;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:queue options:options];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:nil options:nil];
    }
    return self;
}

- (void)initializeWithQueue:(dispatch_queue_t) queue options:(NSDictionary *)options
{
    self.queue = queue;
    self.initialzedOptions = options;
    self.serviceAddingBlocks = [NSMutableDictionary dictionary];
    self.addedServices = [NSMutableArray array];
    
}

-(CBPeripheralManager *)peripheralManager
{
    @synchronized(_peripheralManager)
    {
        if (!_peripheralManager)
        {
            if ([CBPeripheralManager instancesRespondToSelector:@selector(initWithDelegate:queue:options:)])
            {
        
               _peripheralManager= [[CBPeripheralManager alloc] initWithDelegate:self queue:self.queue options:self.initialzedOptions];
            }else
            {
                _peripheralManager= [[CBPeripheralManager alloc] initWithDelegate:self queue:self.queue ];
            }
            
        }
    }
    return _peripheralManager;

}

#pragma mark Adding and Removing Services
- (void)addService:(CBMutableService *)service onFinish:(ZHSpecifiedServiceUpdatedBlock) onfinish
{
    self.serviceAddingBlocks[service.UUID] = onfinish;
    [self.peripheralManager addService:service];
}

- (void)removeService:(CBMutableService *)service
{
    [self.peripheralManager removeService:service];
    [self.addedServices removeObject:service];
}

- (void)removeAllServices
{
    [self.peripheralManager removeAllServices];
    [self.addedServices removeAllObjects];
}


#pragma mark Managing Advertising
- (void)startAdvertising:(NSDictionary *)advertisementData onStarted:(ZHObjectChagedBlock) onstarted
{
    [[ZHBLECentral sharedZHBLECentral] stopScan];
    
    NSAssert(onstarted != nil, @"block should not be nil");
    self.advertisingStartedBlock = onstarted;
    [self.peripheralManager startAdvertising: advertisementData];
}
- (void)stopAdvertising
{
    [self.peripheralManager stopAdvertising];
}
- (BOOL)isAdvertising
{
    
    return  self.peripheralManager.isAdvertising;
}


#pragma mark Sending Updates of a Characteristic’s Value
- (BOOL)updateValue:(NSData *)value forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:(NSArray *)centrals
{
    BOOL res = [self.peripheralManager updateValue:value forCharacteristic:characteristic onSubscribedCentrals:centrals];
    if (!res)
    {
        
    }
    return res;
}

#pragma mark Responding to Read and Write Requests

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result
{
     [_peripheralManager respondToRequest: request withResult: result];
}

#pragma mark Setting Connection Latency
- (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central
{
    [_peripheralManager setDesiredConnectionLatency: latency forCentral:central];
}

- (CBManagerState) state
{
    
    return self.peripheralManager.state;
}

- (NSArray *)services
{
    return self.addedServices;
}


#pragma mark - Delegates
#pragma mark Monitoring Changes to the Peripheral Manager’s State
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onStateUpdated)
        {
            self.onStateUpdated(nil);
        }
    }
}


#pragma mark Adding Services
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
     if (peripheral == self.peripheralManager)
     {
         ZHSpecifiedServiceUpdatedBlock onfinish = self.serviceAddingBlocks[service.UUID];
         if (!error) {
             [self.addedServices addObject:service];
         }
         if (onfinish) {
             onfinish(service,error);
             [self.serviceAddingBlocks removeObjectForKey:service.UUID];
         }
     }
}

#pragma mark Advertising Peripheral Data
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (peripheral == self.peripheralManager)
    {
        if (self.advertisingStartedBlock)
        {
            self.advertisingStartedBlock(error);
            self.advertisingStartedBlock = nil;
        }
    }
    
}

#pragma mark Monitoring Subscriptions to Characteristic Values
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onSubscribedBlock)
        {
            self.onSubscribedBlock(central ,characteristic);
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onUnsubscribedBlock)
        {
            self.onUnsubscribedBlock(central,characteristic);
        }
    }
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onReadToUpdateSubscribers)
        {
            self.onReadToUpdateSubscribers(nil);
        }
    }
}



#pragma mark Receiving Read and Write Requests
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onReceivedReadRequest)
        {
            self.onReceivedReadRequest(request);
        }
    }
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onReceiveWriteRequest) {
            self.onReceiveWriteRequest(requests);
        }
    }
}


@end
