//
//  deviceListTableViewController.h
//  ZHBLE
//
//  Created by aimoke on 15/7/17.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHBLE.h"
@interface DeviceListTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *connectedDeviceArray;
@property (nonatomic, strong) NSMutableArray *findDeviceArray;
@property (nonatomic, strong) ZHBLECentral *central;
@property (nonatomic, strong) ZHBLEPeripheral *connectedPeripheral;



@end
