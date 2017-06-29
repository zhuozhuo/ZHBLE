## ZHBLE
ZHBLE 使用Block回调方式，旨在使调用系统CoreBluetooth库简单明了.

![Screenshot0][img0]    ![Screenshot1][img1]   

![Screenshot2][img2] &nbsp;&nbsp; ![Screenshot3][img3]

## 

## Features
* 基于原生CoreBluetooth,回调函数全部封装成Block方式，使调用相关函数简洁明了。
* 设备作为Central端和Peripheral端都有封装。
* 采用工厂模式和Block结合使得初始化和函数调用更容易。


## Design Goals
简单快捷方便的使用Bluetooth。


## Requirements

* iOS 7.0+
* ARC
* CoreBluetooth.framework

## Introduce
| [类名](https://github.com/zhuozhuo/ZHBLE/tree/master/Demo/ZHBLE/Classes/ZHBLE) |                                    作用及用法 |
| :--------------------------------------- | ---------------------------------------: |
| [ZHBLECentral](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLECentral.h) | 设备作为Central端的相关属性和操作例如:初始化Central,扫描,连接,检索设备等。 |
| [ZHBLEPeripheral](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEPeripheral.h) |    对Peripheral端的相关操作例如:发现服务和特征,监听，读写等操作。 |
| [ZHBLEPeripheralManager](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEPeripheralManager.h) | 设备作为Peripheral端时的相关操作例如:CBPeripheralManager的初始化,广播,添加服务，发送数据等。 |
| [ZHBLEStoredPeripherals](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEStoredPeripherals.h) |                               设备本地缓存相关操作 |
| [ZHBLEManager](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEManager.h) |                              快捷访问最近连接的设备 |
| [ZHBLEBlocks](https://github.com/zhuozhuo/ZHBLE/blob/master/Demo/ZHBLE/Classes/ZHBLE/ZHBLEBlocks.h) |                                所有Block定义 |


## Usage

### [CocoaPods](https://cocoapods.org/) (recommended)
`pod 'ZHBLE'`

### 复制文件夹ZHBLE至你的工程中

### Central
```objective-c
#import "ZHBLE.h"

self.central = [ZHBLECentral sharedZHBLECentral];

//扫描

[self.central scanPeripheralWithServices:uuids options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(YES)} onUpdated:^(ZHBLEPeripheral *peripheral,NSDictionary *data){
   if (peripheral) {
      //Do Something
}}];

//连接

[self.central connectPeripheral:peripheral options:nil onFinished:^(ZHBLEPeripheral *peripheral, NSError *error){
}];
```

## Peripheral

```objective-c
#import "ZHBLE.h"

self.peripheralManager = [ZHBLEPeripheralManager sharedZHBLEPeripheralManager];

//广播
CBUUID *temUUID = [CBUUID UUIDWithString:@"902DD287-69BE-4ADD-AACF-AA3C24D83B66"];
NSArray *temUUIDArray = [NSArray arrayWithObjects:temUUID, nil];
NSDictionary *temServiceDic = @{CBAdvertisementDataServiceUUIDsKey:temUUIDArray};
[self.peripheralManager startAdvertising:temServiceDic onStarted:^(NSError *error){
}];


//添加服务
[self.peripheralManager addService:_transferService onFinish:^(CBService *service,NSError *error){
}];
            
            
```


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

[img0]:http://ac-unmt7l5d.clouddn.com/a5ad110235345af7.png
[img1]:http://ac-unmt7l5d.clouddn.com/2eba95e19897014b.png
[img2]:http://ac-unmt7l5d.clouddn.com/14f697de1198d56e.png
[img3]:http://ac-unmt7l5d.clouddn.com/0d058858c36c60c5.png
