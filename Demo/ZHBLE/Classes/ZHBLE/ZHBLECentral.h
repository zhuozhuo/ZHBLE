//
//  ZHBLECentral.h
//  BLE_iOS
//
//  Created by aimoke on 15/7/15.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZHBLEBlocks.h"
@class ZHBLEPeripheral;

@interface ZHBLECentral : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *peripherals;
@property (nonatomic, readonly) CBManagerState state;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) CBCentralManager * manager;

@property (nonatomic, copy) ZHPeripheralUpdatedBlock onPeripheralUpdated;
@property (nonatomic, copy) ZHPeripheralDisConnectionBlock disConnectionBlock;
@property (nonatomic, copy) ZHCentralStateDidUpdatedBlock centralStateUpdateBlock;
@property (nonatomic, assign) BOOL scanStarted;
@property (nonatomic, strong) NSMutableArray * connectingPeripherals;
@property (nonatomic, strong) NSMutableArray * connectedPeripherals;
@property (nonatomic, strong) NSDictionary * initializedOptions;
@property (nonatomic, strong) NSMutableDictionary * connectionFinishBlocks;

#pragma mark initial Methods
+(ZHBLECentral *)sharedZHBLECentral;

-(instancetype)initWithQueue:(dispatch_queue_t)queue;

-(instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options;

#pragma mark scan or stopScan methods

/**
 Scan Peripheral with Services

 *  @param serviceUUIDs scan service uuids
 *  @param options options
 *  @param onUpdateBlock call back
 */
-(void)scanPeripheralWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(ZHPeripheralUpdatedBlock) onUpdateBlock;

/**
 *  stop scan
 */
-(void)stopScan;

#pragma mark Establishing or Canceling Connection
-(void)connectPeripheral:(ZHBLEPeripheral *)peripheral options:(NSDictionary *)options onFinished:(ZHPeripheralConnectionBlock) finished;
-(void)cancelPeripheralConnection:(ZHBLEPeripheral *)peripheral onFinished:(ZHPeripheralConnectionBlock) ondisconnected;


#pragma mark retrieving Lists of Peripherals
-(NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs NS_AVAILABLE(NA, 7_0);

-(NSArray *)retrievePeriphearlsWithIdentifiers:(NSArray *)identifiers NS_AVAILABLE(NA, 7_0);


@end
