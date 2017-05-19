//
//  peripheralserviceTableViewController.m
//  ZHBLE
//
//  Created by aimoke on 15/7/20.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import "PeripheralserviceTableViewController.h"
#import "Constant.h"

@interface PeripheralserviceTableViewController ()

@end

@implementation PeripheralserviceTableViewController


#pragma mark － LifeView cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Services";
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.characteristicArray = [NSMutableArray array];
    WEAKSELF;
    if (self.connectedPeripheral) {
        [self.connectedPeripheral discoverServices:nil onFinish:^(NSError *error){
            weakSelf.serviceArray = [NSArray arrayWithArray:weakSelf.connectedPeripheral.services];
            [weakSelf.tableView reloadData];
            for (CBService *service in weakSelf.serviceArray) {
                [weakSelf retriveCharacteristicWithService:service];
            }
        }];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - public Interface
-(void)retriveCharacteristicWithService:(CBService *)service
{
    WEAKSELF;
    [self.connectedPeripheral discoverCharacteristics:nil forService:service onFinish:^(CBService *service, NSError *error){
        if (!error) {
            NSInteger temIndex = [self.serviceArray indexOfObject:service];
            [weakSelf.characteristicArray insertObject:service.characteristics atIndex:temIndex];
            [weakSelf.tableView reloadData];
        }
        
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.serviceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.characteristicArray.count>section) {
        NSArray *array = [self.characteristicArray objectAtIndex:section];
        if (!array) {
            return 0;
        }
        return array.count;
    }
    return 0;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peripheralServiceCell" forIndexPath:indexPath];
    NSArray *array = [self.characteristicArray objectAtIndex:indexPath.section];
    CBCharacteristic *characteristic = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = [@"Characteristic:"stringByAppendingString:[characteristic.UUID UUIDString]];
    NSString *string = [self GetCharacteristicProperties:characteristic];
    cell.detailTextLabel.text = string;
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    CBService *service = [self.serviceArray objectAtIndex:section];
    return [@"Service:"stringByAppendingString:service.UUID.UUIDString];
    
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSArray *array = [self.characteristicArray objectAtIndex:indexPath.section];
    CBCharacteristic *characteristic = [array objectAtIndex:indexPath.row];
    CBCharacteristicProperties temProperties = characteristic.properties;
    if (temProperties & CBCharacteristicPropertyNotify)//Notify
    {
        __block  NSMutableData *data = [[NSMutableData alloc]init];
        [data setLength:0];
        [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic onUpdated:^(CBCharacteristic *obj , NSError *error){
            if (error) {
                NSLog(@"Error:%@",error);
            }
           [data appendData:obj.value];
            NSString *value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"NotifyValue:%@",value);
        }];
    }
    if(temProperties & CBCharacteristicPropertyIndicate)//Indicate
    {
        __block  NSMutableData *data = [[NSMutableData alloc]init];
        [data setLength:0];
        [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic onUpdated:^(CBCharacteristic *obj , NSError *error){
            [data appendData:obj.value];
            NSString *value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"IndicateValue:%@",value);
        }];
    }
    
    if(temProperties & CBCharacteristicPropertyRead)//Read
    {
        [self.connectedPeripheral readValueForCharacteristic:characteristic onFinish:^(CBCharacteristic *obj, NSError *error){
            NSData *data = obj.value;
            NSString *value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"readValue:%@",value);
        }];
    }
    if(temProperties & CBCharacteristicPropertyWrite)//White
    {
        NSString *temString = @"test,test";
        NSData *temData = [temString dataUsingEncoding:NSUTF8StringEncoding];
        [self.connectedPeripheral writeValue:temData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse onFinish:^(CBCharacteristic *obj, NSError *error){
            NSString *result = nil;
            if (!error) {
                result = @"Write success";
            }else{
                 result = [NSString stringWithFormat:@"Write data Error :%@",[error localizedDescription]];
            }
            NSLog(@"Write Result:%@",result);
        }];
    }

}



#pragma mark - Private Methods
-(NSString *)GetCharacteristicProperties:(CBCharacteristic *)characteristic
{
    CBCharacteristicProperties temProperties = characteristic.properties;
    NSString *string = @"CBCharacteristicProperty:";
    if (temProperties & CBCharacteristicPropertyNotify)//notify
    {
        string =[string stringByAppendingString:@"Notify "];
    }
    if(temProperties & CBCharacteristicPropertyIndicate)//indicate
    {
        string =[string stringByAppendingString:@"Indicate "];
    }
    
    if(temProperties & CBCharacteristicPropertyRead)//read
    {
        string =[string stringByAppendingString:@"Read "];
    }
    if(temProperties & CBCharacteristicPropertyWrite)//White
    {
        string =[string stringByAppendingString:@"Write "];
    }
  
    return string;
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
        
}


@end
