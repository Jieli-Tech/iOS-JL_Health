# SDKTestHelper

当前 App 的编写是为了对 SDK 进行功能测试，验证 SDK 的流程以及相关接口，同时也有可能会提供给到客户，让客户更方便接入开发。

## SDK 功能说明

当前包含了手表/耳机/音箱耳机的 SDK 汇总 Demo 示例。

### JL_AdvParse.framework 

当前版本 V1.0.0 处理广播报内容（几乎所有SDK 都要用到）


### JL_BLEKit.framework

当前版本 V1.11.0 
RCSP、设备音乐播放控制、查找设备、闹钟、大数据传输、大文件传输、小文件传输、EQ 设置、灯光控制、音量、TWS 设置、语音录制、声卡设置、FM 设置、手表设置相关

### JL_HashPair.framework

当前版本 V1.0.0 设备配对认证（几乎所有SDK 都要用到）

### JL_OTALib.framework

当前版本V2.1.0 设备OTA 升级（几乎所有SDK 都要用到）

### JLDialUnit.framework

当前版本V1.0.0 表盘操作 （手表 SDK 用到）

### SpeexKit.framework

当前版本 V1.0.1 设备录音相关 （录音相关会用到，手表/耳机）

### JLGifLib

当前版本 V1.0.0 GIF 动画相关，当前用来压缩gif图片

### JLWtsToCfgLib

当前版本 V1.0.0 当前 SDK 用于提示音打包



## 示例说明

当前的示例 demo 架构如下：

    Project/
    |── AppDelegate.m 定义了整个应用程序的入口
    ├── Main.storyboard 程序架构使用 storyboard 的架构
    ├── Assets.xcassets 图片/icon 资源存放
    ├── Info.plist 配置
    ├── Resources/ 其他资源文件存放
    ├── Frameworks/ 引用第三方库，一般这里引用的都是非开源性质的库，如科大讯飞、高德地图等
    │   ├── DFUnits.framework 一些基础工具库
    │   ├── SpeexKit.framework JL语音解码库
    │   └── ZipZap.framework 解压文件库
    ├── Models/ 数据处理模型
    ├── Views/ 自定义视图以及业务处理
    │   ├── WeatherView 天气选择
    │   ├── FileLoadView 加载本地文件列表
    │   ├── FileListView 展示文件列表
    │   ├── CreateVoiceView 创建自定义提示音 
    │   └── ...
    ├── Adptaers/ 自定义适配器，如 Cell 的适配器
    │   ├── FuncSelectCell 功能列表Cell适配
    │   └── ...
    │
    ├── Controllers 
    │   ├── MainViewController 主页面
    │   ├── SettingViewControllers 设置
    │   │   └── SettingViewControllers 
    │   ├── SearchBleViewControllers 搜索蓝牙
    │   │   └── SearchBleViewController
    │   ├── FileTransportViewControllers 文件传输相关
    │   │   ├── FileTransportViewController
    │   │   ├── File 文件传输/文件读回
    │   │   │   └── TransportFileViewController
    │   │   ├── Contact 联系人同步
    │   │   │   └── ContactViewController 
    │   │   ├── WatchDial 表盘传输
    │   │   │   └── DialTpViewController
    │   │   ├── SmallFile 小文件传输
    │   │   │   ├── SmallFileDetailViewController 子页面，小文件内容
    │   │   │   └── SmallFileViewController 小文件传输
    │   │   ├── FileBrowse 文件浏览
    │   │   │   └── FileBrowseViewController
    │   │   ├── Gif2Device 发送 Gif 到设备（一般用于彩屏舱）
    │   │   │   └── Gif2DeviceViewController
    │   │   └── ...
    │   ├── DefaultSetViewControllers 普通设置/基础通讯相关
    │   │   ├── DefaultSetViewController
    │   │   ├── Weather 天气设置
    │   │   │   └── WeatherTestViewController
    │   │   ├── Voice 语音传输解码
    │   │   │   ├── VoiceViewController.xib
    │   │   │   └── VoiceViewController
    │   │   ├── EQ EQ设置
    │   │   │   ├── EQSettingViewController.xib
    │   │   │   └── EQSettingViewController
    │   │   ├── PromptTonePackage 提示音打包替换
    │   │   │   ├── PackageResViewController 打包替换
    │   │   │   └── CreateVoicesViewController 创建提示音
    │   │   ├── AIHelper AI 助手测试
    │   │   │   └── AIHelperViewController
    │   │   └── ...
    │   ├── CustomDataViewControllers 自定义命令调试相关
    │   │   ├── CustomDataViewController.xib
    │   │   └── CustomDataViewController
    │   ├── UpdateViewControllers 设备升级相关
    │   │   ├── UpdateViewController
    │   │   ├── OTA 
    │   │   │   └── OTAViewController
    │   │   ├── 4G OTA 
    │   │   │   └── OTA4GViewController
    │   │   └── ...
    │   └── ...
    ├── Basics/ 基础组件视图或其他组件
    │   ├── BaseViewController
    │   ├── BaseView
    │   └── NavViewController
    ├── Tools/ 工具类
    │   ├── SourceHelper
    │   ├── Colors
    │   ├── OCHelper
    │   └── EnumsHelper
    └── ...

    Pods/ 第三方开源库接入方式统一使用 CocoaPods
    │── Podfile  配置
    │── Pods
    │── Frameworks
    │── Products
    └── ...
