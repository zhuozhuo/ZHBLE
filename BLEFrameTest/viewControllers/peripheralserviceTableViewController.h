//
//  peripheralserviceTableViewController.h
//  BLEFrameTest
//
//  Created by aimoke on 15/7/20.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHBLEPeripheral.h"

@interface peripheralserviceTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *serviceArray;
@property(nonatomic, strong) NSMutableArray *characteristicArray;

@property(nonatomic, strong) ZHBLEPeripheral *connectedPeripheral;
@property(nonatomic, strong) NSString *testString;

@end
