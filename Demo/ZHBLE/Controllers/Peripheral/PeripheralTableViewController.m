//
//  PeripheralTableViewController.m
//  ZHBLE
//
//  Created by aimoke on 16/7/27.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import "PeripheralTableViewController.h"
#import "Constant.h"
#import "UIAlertView+showAlertView.h"


@interface PeripheralTableViewController (){
    NSArray *titles;
}

@end

@implementation PeripheralTableViewController


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.title = @"Peripheral";
    titles = @[@"OnlyRead",@"Notify",@"Write",@"NotifyAndWrite",@"ReadAndWrite"];
    
    self.peripheralManager = [ZHBLEPeripheralManager sharedZHBLEPeripheralManager];
    self.subscribedCharacteristicDic = [NSMutableDictionary dictionary];
    [self initialDataInteractBlock];
    
    UIColor *color = [UIColor colorWithRed:26.0/255 green:26.0/255 blue: 26.0/255 alpha:1.0];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Advertise" forState:UIControlStateNormal];
    [button setTitle:@"Stop" forState:UIControlStateSelected];
    button.selected = NO;
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark User Interaction Methods
-(void)clickRightItem:(id)sender
{
    UIButton *button = sender;
    if (!button.selected) {
        [self startAdvertising];
    }else{
        [self stopAdvertising];
    }
    button.selected = !button.selected;
}

#pragma mark - Private Methods
#pragma mark - Data Interact
-(void)initialDataInteractBlock
{
    
    //SubscribedBlock
    self.peripheralManager.onSubscribedBlock = ^(CBCentral *central, CBCharacteristic *characteristic){
        NSLog(@"subCharacteristicUUID:%@",[characteristic.UUID UUIDString]);
        //Do Something
    };
    
    //onUnsubscribedBlock
    self.peripheralManager.onUnsubscribedBlock = ^(CBCentral *central, CBCharacteristic *characteristic){
        NSLog(@"unSubCharacteristicUUID:%@",[characteristic.UUID UUIDString]);
        //Do Something
    };
    
    
    self.peripheralManager.onReadToUpdateSubscribers = ^(NSError *error){
        NSLog(@"onReadToUpdateSubscribers");
        if (!error) {
            //Do Something
        }
    };
    
    
    self.peripheralManager.onReceiveWriteRequest = ^(NSArray *requests){
        if (requests.count>0) {
            NSLog(@"onReceiveWriteRequest");
            //Do Something
        }
    };
    
}

#pragma mark － TableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles.count;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"CBCharacteristicProperties";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeripheralTableViewCellIdentifier" forIndexPath:indexPath];
    NSString *title = [titles objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    return cell;
}


#pragma mark - TableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.transferService) {
        [self.peripheralManager removeService:self.transferService];
    }
    NSString *temAdvertisingString = @"TestValue";
    NSData *temAdvertisingData = [temAdvertisingString dataUsingEncoding:NSUTF8StringEncoding];
    switch (indexPath.row) {
        case 0://OnlyRead
            self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                             properties:CBCharacteristicPropertyRead
                                                                                  value:temAdvertisingData
                                                                            permissions:CBAttributePermissionsReadable];
            break;
        case 1://Notify
            self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
            break;
        case 2://Write
            self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
            break;
        case 3://NotifyAndWrite
            self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
            break;
            
        case 4://ReadAndWrite
            self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsWriteable|CBAttributePermissionsReadable];
            break;
        case 5:
            self.transferCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]properties:CBCharacteristicPropertyIndicate value:nil permissions:CBAttributePermissionsReadable];
            
            break;
        default:
            
            break;
    }
    // Then the service
    _transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                      primary:YES];
    // Add the characteristic to the service
    _transferService.characteristics = @[self.transferCharacteristic];
    // And add it to the peripheral manager
    [self.peripheralManager addService:_transferService onFinish:^(CBService *service,NSError *error){
        NSString *message = nil;
        if (!error) {
            message = @"Add Service Success!";
        }else{
            message = [NSString stringWithFormat:@"Add Service Failure Error:%@",error.localizedDescription];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
             [UIAlertView showAlertViewWithTitile:@"Remind" withMessage:message withDelegate:nil withCancleButtonTitle:@"Ok" withotherBtnTitle:nil];
        });
    }];

}


#pragma mark Advertising And StopAdvertising  
-(void)startAdvertising
{
    if (!self.peripheralManager.isAdvertizing) {
        CBUUID *temUUID = [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID];
        NSArray *temUUIDArray = [NSArray arrayWithObjects:temUUID, nil];
        NSDictionary *temServiceDic = @{CBAdvertisementDataServiceUUIDsKey:temUUIDArray};
        [self.peripheralManager startAdvertising:temServiceDic onStarted:^(NSError *error){
            NSString *message = nil;
            if (!error) {
                message = @"Advertising Success!";
            }else{
                message = [NSString stringWithFormat:@"Advertising Failure Error:%@",error.localizedDescription];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView showAlertViewWithTitile:@"Remind" withMessage:message withDelegate:nil withCancleButtonTitle:@"Ok" withotherBtnTitle:nil];
            });
            
        }];

    }
}

-(void)stopAdvertising
{
    if (self.peripheralManager.isAdvertizing) {
         [self.peripheralManager stopAdvertising];
    }
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
