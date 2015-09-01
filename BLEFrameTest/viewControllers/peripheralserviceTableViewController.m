//
//  peripheralserviceTableViewController.m
//  BLEFrameTest
//
//  Created by aimoke on 15/7/20.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import "peripheralserviceTableViewController.h"
#import "constant.h"
#import "infoViewController.h"
@interface peripheralserviceTableViewController ()

@end

@implementation peripheralserviceTableViewController


#pragma mark － LifeView cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"连接的设备Service";
    
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
    NSString *string = [NSString stringWithFormat:@"Identifier:%@--Name:%@",[self.connectedPeripheral.identifier UUIDString],self.connectedPeripheral.name];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Identifier" message:string  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
    
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
    cell.textLabel.text = [@"characteristic:"stringByAppendingString:[characteristic.UUID UUIDString]];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [self.characteristicArray objectAtIndex:indexPath.section];
    CBCharacteristic *characteristic = [array objectAtIndex:indexPath.row];
    NSDictionary *dic =@{ @"peripheral":self.connectedPeripheral,@"characteristic":characteristic};
    [self performSegueWithIdentifier:@"infoViewController" sender:dic];
    
}



#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSDictionary *dic = (NSDictionary *)sender;
    
    ZHBLEPeripheral *peripheral = [dic objectForKey:@"peripheral"];
    CBCharacteristic *characteristic = [dic objectForKey:@"characteristic"];
    infoViewController *infoVC = [segue destinationViewController];
    infoVC.peripheral = peripheral;
    infoVC.characteristic = characteristic;
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
