//
//  deviceListTableViewController.h
//  BLEFrameTest
//
//  Created by aimoke on 15/7/17.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHBLECentral.h"
#import "ZHStoredPeripherals.h"
#import "ZHBLEPeripheral.h"
@interface deviceListTableViewController : UITableViewController
@property(nonatomic, strong)NSMutableArray *connectedDeviceArray;
@property(nonatomic, strong)NSMutableArray *findDeviceArray;
@property(nonatomic, strong)ZHBLECentral *central;
@property(nonatomic, strong)ZHBLEPeripheral *connectedPeripheral;



@end
