//
//  deviceListTableViewController.m
//  ZHBLE
//
//  Created by aimoke on 15/7/17.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//


#define bleCellIdentifier @"searchBleCellIdentifier"

#import "DeviceListTableViewController.h"
#import "PeripheralserviceTableViewController.h"
#import "Constant.h"
#import "ZHBLEStoredPeripherals.h"

@interface DeviceListTableViewController ()

@end

@implementation DeviceListTableViewController


#pragma mark - ViewLife cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scan devices";
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    NSDictionary * opts = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
    {
        opts = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
    }
    self.central = [ZHBLECentral sharedZHBLECentral];
    NSArray *storedArray = [ZHBLEStoredPeripherals genIdentifiers];
    NSLog(@"storedIdentifier:%@",storedArray);
    NSArray *peripherayArray = nil;
    if (storedArray.count>0) {
       peripherayArray = [self.central retrievePeriphearlsWithIdentifiers:storedArray];
    }
    self.connectedDeviceArray = [NSMutableArray arrayWithArray:peripherayArray];
    self.findDeviceArray = [NSMutableArray array];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scan];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.central stopScan];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public Interface
-(void)scan
{
    WEAKSELF;
    NSArray *identifiers = [ZHBLEStoredPeripherals genIdentifiers];
    NSLog(@"identifiers:%@",identifiers);

    NSArray *conectedPeripherals = [self.central retrievePeriphearlsWithIdentifiers:identifiers];
    NSLog(@"have connceted peripheral:%@",conectedPeripherals);
    
    [conectedPeripherals enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        ZHBLEPeripheral *peripheral = obj;
        [weakSelf addPeripheralToConnectedDevice:peripheral];
    }];
    
    //CBUUID *uuid = [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID];// You can use it test custom services
    NSArray *uuids = nil;//@[uuid];
    
    [self.central scanPeripheralWithServices:uuids options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(YES)} onUpdated:^(ZHBLEPeripheral *peripheral,NSDictionary *data){
        if (peripheral) {
            
             [weakSelf addPeripheralToFindDevice:peripheral];
        }
       
    }];

}


-(void)addPeripheralToFindDevice:(ZHBLEPeripheral *)peripheral
{
    NSAssert(peripheral !=nil, @"peripheral can not nil");
    for (ZHBLEPeripheral *ZHBlePeripheral in self.findDeviceArray) {
        if ([[peripheral.identifier UUIDString] isEqualToString:[ZHBlePeripheral.identifier UUIDString]]) {
            return;
        }
    }
    for (ZHBLEPeripheral *ZHBlePeripheral in self.connectedDeviceArray) {
        if ([[peripheral.identifier UUIDString] isEqualToString:[ZHBlePeripheral.identifier UUIDString]]) {
            return;
        }
    }
    [self.findDeviceArray addObject:peripheral];
    [self.tableView reloadData];
    
}

-(void)deletePeripheralInFindDevice:(ZHBLEPeripheral *)peripheral
{
    NSAssert(peripheral !=nil, @"peripheral can not nil");
    for (ZHBLEPeripheral *ZHBlePeripheral in self.findDeviceArray) {
        if ([[peripheral.identifier UUIDString] isEqualToString:[ZHBlePeripheral.identifier UUIDString]]) {
            [self.findDeviceArray removeObject:ZHBlePeripheral];
            [self.tableView reloadData];
            return;
        }
    }
   
}


-(void)addPeripheralToConnectedDevice:(ZHBLEPeripheral *)peripheral
{
    
    NSAssert(peripheral !=nil, @"peripheral can not nil");
    
    for (ZHBLEPeripheral *ZHBlePeripheral in self.connectedDeviceArray) {
        if ([[peripheral.identifier UUIDString] isEqualToString:[ZHBlePeripheral.identifier UUIDString]]) {
            return;
        }
    }
    [self.connectedDeviceArray addObject:peripheral];
    [self.tableView reloadData];

}

-(void)deletePeripheralInConnectedDevice:(ZHBLEPeripheral *)peripheral
{
    NSAssert(peripheral !=nil, @"peripheral can not nil");
    
    for (ZHBLEPeripheral *ZHBlePeripheral in self.connectedDeviceArray) {
        if ([[peripheral.identifier UUIDString] isEqualToString:[ZHBlePeripheral.identifier  UUIDString] ]) {
            [self.connectedDeviceArray removeObject:ZHBlePeripheral];
            [self.tableView reloadData];
            return;
        }
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.connectedDeviceArray.count;
            break;
        case 1:
           return  self.findDeviceArray.count;
            break;
            
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bleCellIdentifier forIndexPath:indexPath];
    
    ZHBLEPeripheral *peripherial = nil;
    switch (indexPath.section) {
        case 0:
        {
            peripherial = [self.connectedDeviceArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = @"Connected";
        }
            break;
        case 1:
        {
            peripherial = [self.findDeviceArray objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = nil;
        }
            break;
            
        default:
            break;
    }
    if (peripherial.name && peripherial.name.length>0) {
         cell.textLabel.text = peripherial.name;
    }else
        cell.textLabel.text = [peripherial.identifier UUIDString];
   
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"My devices";
            break;
        case 1:
            return  @"Other devices";
            break;
            
        default:
            break;
    }
    return 0;

}


#pragma mark - tableview Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZHBLEPeripheral *peripheral = nil;
    switch (indexPath.section) {
        case 0:{
             peripheral = [self.connectedDeviceArray objectAtIndex:indexPath.row];
            //[self pushWithPeripheral:peripheral];
        }
           
            break;
         case 1:
        {
             peripheral = [self.findDeviceArray objectAtIndex:indexPath.row];
            
        }
           
            break;
        default:
            break;
    }
    WEAKSELF;
    [self.central connectPeripheral:peripheral options:nil onFinished:^(ZHBLEPeripheral *peripheral, NSError *error){
        weakSelf.connectedPeripheral = peripheral;
        [weakSelf deletePeripheralInFindDevice:peripheral];
        [weakSelf addPeripheralToConnectedDevice:peripheral];
        
        [peripheral.peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
            CBService *service = obj;
            NSLog(@"serviceUUID:%@",[service.UUID UUIDString]);
        }];
        [weakSelf pushWithPeripheral:peripheral];
        [self.tableView reloadData];

    }];
}


#pragma mark - Push
-(void)pushWithPeripheral:(ZHBLEPeripheral *)peripheral
{
    [self performSegueWithIdentifier:@"serviceViewController" sender:peripheral];
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PeripheralserviceTableViewController *serviceVC = [segue destinationViewController];
    ZHBLEPeripheral *peripheral = (ZHBLEPeripheral*)sender;
    
    serviceVC.connectedPeripheral = peripheral;
    serviceVC.title = peripheral.name;
    
}


@end
