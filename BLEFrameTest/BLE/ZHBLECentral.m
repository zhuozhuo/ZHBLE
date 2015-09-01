//
//  ZHBLECentral.m
//  BLE_IOS
//
//  Created by aimoke on 15/7/15.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//


#import "ZHBLECentral.h"
#import <UIKit/UIKit.h>
#import "ZHStoredPeripherals.h"
#import "ZHBLEPeripheral.h"
#import "ZHBLEManager.h"

@interface ZHBLECentral()<CBCentralManagerDelegate,CBPeripheralDelegate>
@end


#pragma mark -Life cycle
@implementation ZHBLECentral

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
    self.disconnectedBlocks     = [NSMutableDictionary dictionary];
    [ZHStoredPeripherals initializeStorage];//初始化存储
    
     

    
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
-(CBCentralManagerState)state
{
    return self.manager.state;
}

#pragma mark -Scanning or stopping Scan of Peripheral

-(void)scanPeripheralWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(ZHPeripheralUpdatedBlock)onUpdateBlock
{
    NSAssert(onUpdateBlock !=nil, @"onUpdateBlock can not be nil");
    [self.manager scanForPeripheralsWithServices:serviceUUIDs                                            options:options];
    self.onPeripheralUpdated = onUpdateBlock;
}


-(void)stopScan
{
    [self.manager stopScan];
}


#pragma mark － discoverPeripheral


#pragma mark Establishing or cancel with peripherals
-(void)connectPeripheral:(ZHBLEPeripheral *)peripheral options:(NSDictionary *)options onFinished:(ZHPeripheralConnectionBlock)finished onDisconnected:(ZHPeripheralConnectionBlock)onDisconnected
{
    self.connectionFinishBlocks[peripheral.identifier] = finished;
    self.disconnectedBlocks[peripheral.identifier] = onDisconnected;
    [self.connectingPeripherals addObject: peripheral];
    [self.manager connectPeripheral:peripheral.peripheral options:options];
    
}

-(void)cancelPeripheralConnection:(ZHBLEPeripheral *)peripheral onFinished:(ZHPeripheralConnectionBlock)ondisconnected
{
    self.disconnectedBlocks[peripheral.identifier] = ondisconnected;
    [self.manager cancelPeripheralConnection:peripheral.peripheral];
    
}


#pragma mark Retrieving Lists of Peripherals
-(NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs
{
    NSArray * tArray = [self.manager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    
    //转换成自定义的peripherals
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
    //转换成自定义的peripherals
        
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
        
        //存储到本地
        [ZHStoredPeripherals saveUUID:peripheral.identifier];
        
        if (finish) {
            finish(thePeripheral,nil);
            [self.connectionFinishBlocks removeObjectForKey:peripheral.identifier];
        }
        
        
    }
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    ZHBLEPeripheral *thePeripheral = peripheral.delegate;
    if (thePeripheral && [self.connectingPeripherals containsObject:thePeripheral]) {
        ZHPeripheralConnectionBlock finish = self.connectionFinishBlocks[thePeripheral.identifier];
        
        //remove it
        [self.connectingPeripherals removeObject:peripheral];
        
        [thePeripheral cleanup];
        
        if (finish) {
            finish(thePeripheral,error);
            [self.connectionFinishBlocks removeObjectForKey:thePeripheral.identifier];
            [self.disconnectedBlocks removeObjectForKey:thePeripheral.identifier];
        }
        
    }
}


-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    ZHBLEPeripheral *thePeripheral = peripheral.delegate;
    if (thePeripheral && [self.connectedPeripherals containsObject:thePeripheral]) {
        ZHPeripheralConnectionBlock finish = self.disconnectedBlocks[peripheral.identifier];
        
        //设置manager Peripheral 为空
        ZHBLEManager *manager = [ZHBLEManager sharedZHBLEManager];
        manager.connectPeripheral = nil;
        
        [self.connectedPeripherals removeObject:peripheral];
        if (finish) {
            finish(thePeripheral,error);
            [self.disconnectedBlocks removeObjectForKey:thePeripheral.identifier];
        }
        
    }
}


#pragma mark - internal methods
-(void)clearPeripherals
{
    [self.connectedPeripherals removeAllObjects];
    [self.connectingPeripherals removeAllObjects];
    [self.peripherals removeAllObjects];
    [self.connectionFinishBlocks removeAllObjects];
    [self.disconnectedBlocks removeAllObjects];
}

#pragma mark - central state delegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central == self.manager) {
        [self filterBluetoothState];
        switch (central.state) {
            case CBCentralManagerStatePoweredOff:
            {
                [self clearPeripherals];
                if (_onPeripheralUpdated)
                {
                    _onPeripheralUpdated(nil,nil);
                }
            }
                break;
            case CBCentralManagerStatePoweredOn:
            {
                if (_onPeripheralUpdated)
                {
                    _onPeripheralUpdated(nil,nil);
                }
            }
                break;
            case CBCentralManagerStateResetting:
            {
                [self clearPeripherals];
                if (_onPeripheralUpdated)
                {
                    _onPeripheralUpdated(nil,nil);
                }
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
        if (_onStateChanged)
        {
            _onStateChanged(nil);
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
                remindString = @"请打开蓝牙";
                break;
            case CBCentralManagerStateUnknown:
                remindString = @"蓝牙发送未知错位";
                break;
                
            case CBCentralManagerStateResetting:
                remindString = @"蓝牙正在重启,请稍等";
                break;
            case CBCentralManagerStateUnsupported:
                remindString = @"手机不支持BlueTooth";
                break;
            case CBCentralManagerStateUnauthorized:
                remindString = @"未被授权";
                break;
            default:
                break;
        }
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:remindString delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    
    
    
}
@end
