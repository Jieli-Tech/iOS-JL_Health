# iOS-JL_Health
[中文](https://github.com/Jieli-Tech/iOS-JL_Health/blob/main/README.md)|**EN**

<br/>

<div align="center">
	
![iOS](https://img.shields.io/badge/iOS-10.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)       

<strong style="font:24px;color:#000000">Jieli Health SDK (iOS)</strong>

**Jieli Health SDK** is developed by <strong style="color:#ee2233">Zhuhai Jieli Technology Co., Ltd.</strong> (hereinafter referred to as "the Company") to provide functional integration SDK specifically for the Company's Bluetooth wearable products.

</div>

## Quick Start

To help developers quickly integrate <strong style="color:red">Jieli Health SDK</strong>, please read the following carefully before development:

- [Jieli Health SDK (iOS) Development Documentation](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html)
- [Development Instructions](./docs/)
- [Core Libraries](./libs/)

## Development Resources

```tex
 ├── code
      ├── JieliJianKang                   --- Yi Dong Health Source Code
      ├── JLWatchDemo                     --- Simple Function Demo Source Code
      ├── HealthAide_ALi_IOT_V0.1.2(iOS)  --- Alipay Integration Example
      ├── 杰理iOS音频编解码V1.1.0            --- Watch Audio Data Encoding/Decoding Example
 ├── docs
      ├── Jieli_Health_SDK_iOS_Releases.pdf --- Version Release Notes
      ├── 杰理OTA升级(iOS)开发说明.url        --- Online Doc: OTA Development Guide
      ├── 杰理健康SDK开发说明.url             --- Online Doc: Development Guide
      ├── 自定义蓝牙接入方式.url               --- Online Doc: Bluetooth Integration Guide
 ├── libs
      ├── JLDialUnit.framework            --- Watch Face Related
      ├── JL_AdvParse.framework           --- Broadcast Packet Parsing
      ├── JL_BLEKit.framework             --- Main Business Library (Basic Protocol)
      ├── JL_HashPair.framework           --- Device Authentication
      ├── JL_OTALib.framework             --- OTA Upgrade Business Library
      ├── third_party                     --- Third-party Libraries
```

## Release Notes

| Version | Date       | Changelog                                                    |
| ------- | ---------- | ------------------------------------------------------------ |
| V1.9.0 | 2023/9/15  | 1.New Features<br/>(1) Added AI cloud service function        |
| V1.8.0  | 2023/04/23 | 1. Bug Fixes<br/>(1) Fixed error in small file packet transmission<br/>(2) Fixed large file transmission timeout issue<br/>2. New Features<br/>(1) Improved device recording interface, added bidirectional control interface<br/>(2) Added time synchronization setting interface<br/>(3) Added interface to ignore header information in image transcoding<br/>3. Performance Optimization<br/>(1) Optimized RTC module shortage, extended RTC available length<br/>(2) Separated functional modules for SDK libraries:<br/>- JL_OTALib.framework: OTA Upgrade Business Library<br/>- JL_AdvParse.framework: Jieli Bluetooth Device Broadcast Packet Parsing Business Library<br/>- JL_HashPair.framework: Device Authentication Business Library<br/>- JL_BLEKit.framework: Main Business Library<br/>(3) Decoupled lighting control module, optimized watch face deletion thread callback, optimized custom command module |

> Note: For detailed version iteration records, please refer to the release notes document in the docs directory.

## Implementation Examples

### Yi Dong Health

1. Bluetooth Connection Implementation: Refer to the `JL_ManagerM` class in `JL_BLEKit.framework`
   - Device scanning and connection
   - Basic protocol interaction
2. Health Function Implementation: Refer to relevant Managers in `JL_BLEKit.framework`
   - `JL_SportDataModel` / `JL_HealthDataModel`: Sports and health data models
   - `JL_SleepMonitorModel`: Sleep monitoring
3. OTA Function Implementation: Refer to the `JL_OTAManager` class in `JL_OTALib.framework`
   - Firmware upgrade process control
   - Resource file transmission
4. Watch Face Function Implementation: Refer to `JLDialUnit.framework`
   - Watch face switching and customization

**For testing functions, please refer to the sample code in `code/JieliJianKang`**

## Support

- 🌐 **Official Website**: [Jieli Technology](https://www.zh-jieli.com/)
- 📧 **Technical Support**: Please contact via official channels

## License

This project is licensed under the [Apache License 2.0](./LICENSE).

```
Copyright 2024 Zhuhai Jieli Technology Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

<div align="center">

**© 2024 Zhuhai Jieli Technology Co., Ltd. | Licensed under Apache License 2.0**

</div>
