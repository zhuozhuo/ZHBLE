## ZHBLE
ZHBLE using Block callback methods, aimed at making the system CoreBluetooth library function is called simple.

![Screenshot0][img0]    ![Screenshot1][img1]   

[Chinese README LINK](https://github.com/zhuozhuo/ZHBLE/blob/master/README_CN.md)

## Features

* Based on the original CoreBluetooth, the callback function all packaged into Block mode, calls the associated function simplicity.。
* Central and Peripheral side has packages。
* Using the factory pattern and Block integration makes it easier for initialization and function calls.


## Design Goals
simple and convenient to use Bluetooth。


## Requirements

* iOS 7.0+
* ARC
* CoreBluetooth.framework

## Introduce

| [Class name](https://github.com/zhuozhuo/ZHBLE/tree/master/Demo/ZHBLE/Classes/ZHBLE) |                       Function and usage |
| :--------------------------------------- | ---------------------------------------: |
| [ZHBLECentral](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLECentral.h) | Equipment as the relevant attributes and operations on the Central side, for example: initialize Central, scanned, connect, retrieve equipment. |
| [ZHBLEPeripheral](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEPeripheral.h) | Peripheral-side operations such as: discovery service and features, listening, reading and writing, and so on. |
| [ZHBLEPeripheralManager](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEPeripheralManager.h) | Device as a Peripheral-side operations such as initialization of CBPeripheralManager, radio, adding services and send data. |
| [ZHBLEStoredPeripherals](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEStoredPeripherals.h) |         Equipment local cache operations |
| [ZHBLEManager](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEManager.h) | Fast access to recently connected devices |
| [ZHBLEBlocks](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEBlocks.h) |                      All Block definitio |

## Usage
###  [CocoaPods](https://cocoapods.org/) (recommended)
`pod 'ZHBLE'`

### Copy the folder ZHBLE to your project

### Central
```objective-c
#import "ZHBLE.h"

self.central = [ZHBLECentral sharedZHBLECentral];

//Scan

[self.central scanPeripheralWithServices:uuids options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(YES)} onUpdated:^(ZHBLEPeripheral *peripheral,NSDictionary *data){
   if (peripheral) {
       //Do Something
}}];

//Connection

[self.central connectPeripheral:peripheral options:nil onFinished:^(ZHBLEPeripheral *peripheral, NSError *error){
}];
```

## Peripheral

```objective-c
#import "ZHBLE.h"


self.peripheralManager = [ZHBLEPeripheralManager sharedZHBLEPeripheralManager];

//Advertise
CBUUID *temUUID = [CBUUID UUIDWithString:@"902DD287-69BE-4ADD-AACF-AA3C24D83B66"];
NSArray *temUUIDArray = [NSArray arrayWithObjects:temUUID, nil];
NSDictionary *temServiceDic = @{CBAdvertisementDataServiceUUIDsKey:temUUIDArray};
[self.peripheralManager startAdvertising:temServiceDic onStarted:^(NSError *error){
}];


//Add Service
[self.peripheralManager addService:_transferService onFinish:^(CBService *service,NSError *error){
}];
            
            
```




## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).













[img0]:http://ac-unmt7l5d.clouddn.com/a5ad110235345af7.png
[img1]:http://ac-unmt7l5d.clouddn.com/2eba95e19897014b.png
[img2]:http://ac-unmt7l5d.clouddn.com/14f697de1198d56e.png
[img3]:http://ac-unmt7l5d.clouddn.com/0d058858c36c60c5.png
