//
//  ZHBLECentral.m
//  BLE_iOS
//
//  Created by aimoke on 15/7/15.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//


#import "ZHBLECentral.h"
#import <UIKit/UIKit.h>
#import "ZHBLEStoredPeripherals.h"
#import "ZHBLEPeripheral.h"
#import "ZHBLEManager.h"

@interface ZHBLECentral()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, copy) ZHPeripheralDisConnectionBlock canCelConnectionBlock;
@end


#pragma mark -Life cycle
@implementation ZHBLECentral

+(ZHBLECentral *)sharedZHBLECentral
{
    static ZHBLECentral *_bleCentralFactory = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        NSDictionary * opts = nil;
        if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
        {
            opts = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
        }
        
        _bleCentralFactory = [[ZHBLECentral alloc]initWithQueue:nil options:opts];
    });
    return _bleCentralFactory;
    
}


-(instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        [self initializeWithQueue:queue options:nil];
    }
    return self;
}

-(instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        [self initializeWithQueue:queue options:options];
    }
    return self;
    
}

-(void)initializeWithQueue:(dispatch_queue_t) queue options:(NSDictionary *) options
{
    self.queue                  = queue;
    self.initializedOptions     = options;
    _peripherals                = [NSMutableArray array];
    self.connectingPeripherals  = [NSMutableArray array];
    self.connectedPeripherals   = [NSMutableArray array];
    self.connectionFinishBlocks = [NSMutableDictionary dictionary];
    
    [ZHBLEStoredPeripherals initializeStorage];//初始化存储
    if (![CBCentralManager instancesRespondToSelector:@selector(initWithDelegate:queue:options:)]) {
        //for version lowser than 7.0
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:self.queue];
    }else{
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:self.queue options:self.initializedOptions];
    }
}

-(CBCentralManager *)manager
{
    @synchronized(_manager){
        if (!_manager) {
            if (![CBCentralManager instancesRespondToSelector:@selector(initWithDelegate:queue:options:)]) {
                //for version lowser than 7.0
                _manager = [[CBCentralManager alloc]initWithDelegate:self queue:self.queue];
            }else{
                _manager = [[CBCentralManager alloc]initWithDelegate:self queue:self.queue options:self.initializedOptions];
            }
            
        }
    }
    return _manager;
}

-(void)dealloc
{
    _manager.delegate = nil;
}


#pragma mark － property Methods
-(CBManagerState)state
{
    return self.manager.state;
}


#pragma mark -Scanning or stopping Scan of Peripheral

-(void)scanPeripheralWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(ZHPeripheralUpdatedBlock)onUpdateBlock
{
    NSAssert(onUpdateBlock !=nil, @"onUpdateBlock can not be nil");
    if (serviceUUIDs) {
        NSArray *array = [self.manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
        [array enumerateObjectsUsingBlock:^(CBPeripheral *peripheral, NSUInteger index, BOOL *stop){
            ZHBLEPeripheral *zhPeripheral = peripheral.delegate;
            if (!zhPeripheral) {
                zhPeripheral = [[ZHBLEPeripheral alloc] initWithPeripheral:peripheral];
            }
            if (zhPeripheral && ![self.peripherals containsObject:peripheral]) {
                [self.peripherals addObject:zhPeripheral];
            }
            
            if (onUpdateBlock) {
                onUpdateBlock(zhPeripheral,nil);
            }
        }];
        
    }
    
    [self.manager scanForPeripheralsWithServices:serviceUUIDs                                            options:options];
    self.onPeripheralUpdated = onUpdateBlock;
}


-(void)stopScan
{
    [self.manager stopScan];
}


#pragma mark － discoverPeripheral

#pragma mark Establishing or cancel with peripherals
-(void)connectPeripheral:(ZHBLEPeripheral *)peripheral options:(NSDictionary *)options onFinished:(ZHPeripheralConnectionBlock)finished
{
    
    if (finished && peripheral) {
        self.connectionFinishBlocks[peripheral.identifier] = finished;
        [self.connectingPeripherals addObject: peripheral];
        [self.manager connectPeripheral:peripheral.peripheral options:options];
    }
}

-(void)cancelPeripheralConnection:(ZHBLEPeripheral *)peripheral onFinished:(ZHPeripheralConnectionBlock)ondisconnected
{
    self.canCelConnectionBlock = ondisconnected;
    if (peripheral.peripheral && peripheral.peripheral.identifier) {
        [self.manager cancelPeripheralConnection:peripheral.peripheral];
    }
}


#pragma mark Retrieving Lists of Peripherals
-(NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs
{
    NSArray * tArray = [self.manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    
    //Converting custom peripherals
    NSMutableArray *ZHPeripherals = [NSMutableArray arrayWithArray:tArray];
    for (CBPeripheral * peri in ZHPeripherals) {
        ZHBLEPeripheral *zhperi = peri.delegate;
        if (!zhperi) {
            zhperi = [[ZHBLEPeripheral alloc]initWithPeripheral:peri];
        }
        [ZHPeripherals addObject:zhperi];
    }
    return ZHPeripherals;
    
}

-(NSArray *)retrievePeriphearlsWithIdentifiers:(NSArray *)identifiers
{
    NSArray * tArray = [self.manager retrievePeripheralsWithIdentifiers:identifiers];
    
    //Converting custom peripherals
    NSMutableArray *ZHPeripherals = [NSMutableArray array];
    for (CBPeripheral * peri in tArray) {
        ZHBLEPeripheral *zhperi = peri.delegate;
        if (!zhperi) {
            zhperi = [[ZHBLEPeripheral alloc]initWithPeripheral:peri];
        }
        [ZHPeripherals addObject:zhperi];
    }
    return ZHPeripherals;
}




#pragma mark -CBCentralManagerDelegate
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    ZHBLEPeripheral *zhPeripheral = peripheral.delegate;
    if (!zhPeripheral) {
        zhPeripheral = [[ZHBLEPeripheral alloc] initWithPeripheral:peripheral];
    }
    // NSLog(@"advertisementData:%@",advertisementData);
    
    if (zhPeripheral && ![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:zhPeripheral];
    }
    zhPeripheral.RSSI = RSSI;
    _onPeripheralUpdated(zhPeripheral,advertisementData);
    
}



#pragma mark Monitoring Connections with Peripherals
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    ZHBLEPeripheral *thePeripheral = peripheral.delegate;
    if (thePeripheral && [self.connectingPeripherals containsObject:thePeripheral]) {
        ZHPeripheralConnectionBlock finish = self.connectionFinishBlocks[peripheral.identifier];
        
        //remove it from connectiongPeripherals
        [self.connectingPeripherals removeObject:thePeripheral];
        [self.connectedPeripherals addObject:thePeripheral];
        
        ZHBLEManager *manager = [ZHBLEManager sharedZHBLEManager];
        manager.connectPeripheral = peripheral;
        
        //Stored to local
        [ZHBLEStoredPeripherals saveUUID:peripheral.identifier];
        
        if (finish) {
            finish(thePeripheral,nil);
            [self.connectionFinishBlocks removeObjectForKey:peripheral.identifier];
        }
        
        
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    ZHBLEPeripheral *thePeripheral = peripheral.delegate;
    ZHPeripheralConnectionBlock finish = self.connectionFinishBlocks[thePeripheral.identifier];
    if (finish) {
        finish(thePeripheral,error);
        [self.connectionFinishBlocks removeObjectForKey:thePeripheral.identifier];
    }
    
    if (thePeripheral && [self.connectingPeripherals containsObject:thePeripheral]) {
        //remove it
        [self.connectingPeripherals removeObject:peripheral];
        [thePeripheral cleanup];
    }
}


-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    ZHBLEPeripheral *thePeripheral = peripheral.delegate;
    if (self.disConnectionBlock) {
        self.disConnectionBlock(thePeripheral, error);
    }
    if (self.canCelConnectionBlock) {
        self.canCelConnectionBlock(thePeripheral, error);
    }
    
    if (thePeripheral && [self.connectedPeripherals containsObject:thePeripheral]) {
        //Manager Peripheral set is empty
        ZHBLEManager *manager = [ZHBLEManager sharedZHBLEManager];
        manager.connectPeripheral = nil;
        [self.connectedPeripherals removeObject:peripheral];
    }
}


#pragma mark - internal methods
-(void)clearPeripherals
{
    [self.connectedPeripherals removeAllObjects];
    [self.connectingPeripherals removeAllObjects];
    [self.peripherals removeAllObjects];
    [self.connectionFinishBlocks removeAllObjects];
    if (self.onPeripheralUpdated) {
        self.onPeripheralUpdated = nil;
    }
    if (self.canCelConnectionBlock) {
        self.canCelConnectionBlock = nil;
    }
    
}

#pragma mark - central state delegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central == self.manager) {
        if (self.centralStateUpdateBlock) {
            self.centralStateUpdateBlock(central);
        }
        switch (central.state) {
            case CBCentralManagerStatePoweredOff:
            {
                [self clearPeripherals];
                
            }
                break;
            case CBCentralManagerStatePoweredOn:
            {
                
            }
                break;
            case CBCentralManagerStateResetting:
            {
                [self clearPeripherals];
            }
                break;
            case CBCentralManagerStateUnauthorized:
            {
                /* Tell user the app is not allowed. */
                
            }
                break;
            case CBCentralManagerStateUnknown:
            {
                /* Bad news, let's wait for another event. */
                
            }
                break;
            case CBCentralManagerStateUnsupported:
                break;
            default:
                break;
        }
    }
}

#pragma mark -Filter BluetoolthState Judgement
-(void)filterBluetoothState
{
    NSString *remindString = nil;
    switch (self.state) {
        case CBCentralManagerStatePoweredOn:
            return;
            
        case CBCentralManagerStatePoweredOff:
            remindString = @"Please turn on the Bluetoolth";
            break;
        case CBCentralManagerStateUnknown:
            remindString = @"Unknown error Bluetooth";
            break;
            
        case CBCentralManagerStateResetting:
            remindString = @"Bluetoolth is resetting";
            break;
        case CBCentralManagerStateUnsupported:
            remindString = @"The device does not support Bluetooth";
            break;
        case CBCentralManagerStateUnauthorized:
            remindString = @"Not authorized";
            break;
        default:
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Remind" message:remindString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}
@end
