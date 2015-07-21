//
//  infoViewController.m
//  BLEFrameTest
//
//  Created by aimoke on 15/7/20.
//  Copyright (c) 2015年 zhuo. All rights reserved.
//

#import "infoViewController.h"
#import "constant.h"
@interface infoViewController ()

@end

@implementation infoViewController


#pragma mark - ViewLife cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self readData];
    self.infoTextView.editable = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark － public Interface
-(void)readData
{
    if (!self.peripheral) {
        NSLog(@"111");
    }
    if (!self.characteristic) {
        NSLog(@"222");
        
    }
     CBCharacteristicProperties temProperties = self.characteristic.properties;
    NSString *string = @"";
     WEAKSELF;
    if (temProperties & CBCharacteristicPropertyNotify)//notify
    {
     
        __block  NSMutableData *data = [[NSMutableData alloc]init];
        [data setLength:0];
        
        string =[string stringByAppendingString:@"CBCharacteristicPropertyNotify"];
        [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic onUpdated:^(CBCharacteristic *obj , NSError *error){
            
            [data appendData:obj.value];
            NSString *temText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            weakSelf.infoTextView.text = temText;
            if ([[[NSString alloc]initWithData:obj.value encoding:NSUTF8StringEncoding] isEqualToString:@"EOM"]) {//结束符号
                //[weakSelf.peripheral setNotifyValue:NO forCharacteristic:weakSelf.characteristic onUpdated:nil];
            }
            
        }];
    }
    if(temProperties & CBCharacteristicPropertyIndicate)//indicate
    {
        string =[string stringByAppendingString:@"-CBCharacteristicPropertyIndicate"];
        [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic onUpdated:^(CBCharacteristic *obj , NSError *error){
            NSMutableData *data = nil;
            [data appendData:obj.value];
            NSString *temText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            weakSelf.infoTextView.text = temText;
            
        }];
    }
    
    if(temProperties & CBCharacteristicPropertyRead)//read
    {
       string =[string stringByAppendingString:@"-CBCharacteristicPropertyRead"];
        [self.peripheral readValueForCharacteristic:self.characteristic onFinish:^(CBCharacteristic *obj, NSError *error){
            NSData *data = obj.value;
            NSString *temText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            weakSelf.infoTextView.text = temText;
        }];
    }
    if(temProperties & CBCharacteristicPropertyWrite)//White
    {
        string =[string stringByAppendingString:@"-CBCharacteristicPropertyWrite"];
        NSString *temString = @"test,test";
        NSData *temData = [temString dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheral writeValue:temData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse onFinish:^(CBCharacteristic *obj, NSError *error){
            NSString *temErrorString = nil;
            if (!error) {
                temErrorString = @"写入成功";
            }else
                temErrorString = [NSString stringWithFormat:@"white data Error :%@",[error localizedDescription]];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:temErrorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }];

    }
    self.propertyLabel.text = string;
    

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
