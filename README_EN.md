##ZHBLE
ZHBLE using Block callback methods, aimed at making the system CoreBluetooth library function is called simple.

![Screenshot0][img0] &nbsp;&nbsp; ![Screenshot1][img1] &nbsp;&nbsp;

![Screenshot2][img2] &nbsp;&nbsp; ![Screenshot3][img3]

##Features
* Based on the original CoreBluetooth, the callback function all packaged into Block mode, calls the associated function simplicity.。
* Central and Peripheral side has packages。
* Using the factory pattern and Block integration makes it easier for initialization and function calls.


## Design Goals
imple and convenient to use Bluetooth。


## Requirements

* iOS 7.0+
* ARC
* CoreBluetooth.framework

##Introduce
[Class name](https://github.com/zhuozhuo/BLE/tree/master/ZHBLE/Classes/ZHBLE) | Function and usage
----- | -----
[ZHBLECentral](https://github.com/zhuozhuo/BLE/blob/master/ZHBLE/Classes/ZHBLE/ZHBLECentral.h) | Equipment as the relevant attributes and operations on the Central side, for example: initialize Central, scanned, connect, retrieve equipment.
[ZHBLEPeripheral](https://github.com/zhuozhuo/BLE/blob/master/ZHBLE/Classes/ZHBLE/ZHBLEPeripheral.h) | Peripheral-side operations such as: discovery service and features, listening, reading and writing, and so on.
[ZHBLEPeripheralManager](https://github.com/zhuozhuo/BLE/blob/master/ZHBLE/Classes/ZHBLE/ZHBLEPeripheralManager.h) | Device as a Peripheral-side operations such as initialization of CBPeripheralManager, radio, adding services and send data.
[ZHBLEStoredPeripherals](https://github.com/zhuozhuo/BLE/blob/master/ZHBLE/Classes/ZHBLE/ZHBLEStoredPeripherals.h) | Equipment local cache operations
[ZHBLEManager](https://github.com/zhuozhuo/BLE/blob/master/ZHBLE/Classes/ZHBLE/ZHBLEManager.h) | Fast access to recently connected devices
[ZHBLEBlocks](https://github.com/zhuozhuo/BLE/blob/master/ZHBLE/Classes/ZHBLE/ZHBLEBlocks.h) | All Block definition

## Usage
### [CocoaPods](https://cocoapods.org/) (recommended)
pod 'ZHBLE', '~> 0.1.5'

### Copy the folder ZHBLE to your project

### Central
```objective-c
#import "ZHBLE.h"

self.central = [ZHBLECentral sharedZHBLECentral];

//Scan

[self.central scanPeripheralWithServices:uuids options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(YES)} onUpdated:^(ZHBLEPeripheral *peripheral,NSDictionary *data){
        if (peripheral) {
            
            //Do Something
        }
       
    }];

//Connection

[self.central connectPeripheral:peripheral options:nil onFinished:^(ZHBLEPeripheral *peripheral, NSError *error){
}onDisconnected:^(ZHBLEPeripheral *peripheral, NSError *error){
                    
        });
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













[img0]:https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Screenshots/screenshot0.png
[img1]:https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Screenshots/screenshot1.png
[img2]:https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Screenshots/screenshot2.png
[img3]:https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Screenshots/screenshot3.png
