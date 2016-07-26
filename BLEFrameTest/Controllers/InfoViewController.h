//
//  infoViewController.h
//  BLEFrameTest
//
//  Created by aimoke on 15/7/20.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHBLEPeripheral.h"
@interface InfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@property(nonatomic, strong)ZHBLEPeripheral *peripheral;
@property(nonatomic, strong)CBCharacteristic *characteristic;

@end
