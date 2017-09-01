
Pod::Spec.new do |s|
  s.name         = "ZHBLE"
  s.version      = "0.2.1"
  s.summary      = "ZHBLE Block way, aim to make call BlueTooth more simple."
  s.description  = <<-DESC
* 旨在快捷方便的使用系统CoreBluetooth库.
* 基于原生CoreBluetooth,回调函数全部封装成Block回调方式，使调用相关函数简洁明了>。
* 设备作为Central端和Peripheral端都有封装。
* 采用工厂模式和Block方法结合使得初始化和函数调用更容易.
                   DESC

   s.homepage     = "https://github.com/zhuozhuo/ZHBLE"
   s.screenshots  = ['http://ac-unmt7l5d.clouddn.com/a5ad110235345af7.png', 'http://ac-unmt7l5d.clouddn.com/2eba95e19897014b.png']
   s.license      = { :type => "MIT", :file => "LICENSE" }
   s.author             = { "Mr.jiang" => "414816566@qq.com" }
   s.platform     = :ios, "7.0"
   s.source       = { :git => "https://github.com/zhuozhuo/ZHBLE.git", :tag => s.version }
   s.source_files  = "Classes", "Demo/ZHBLE/Classes/ZHBLE/*.{h,m}"
   s.public_header_files = "Demo/ZHBLE/Classes/ZHBLE/*.h"
   s.framework  = "CoreBluetooth"
end
