[tag download]:https://github.com/Jieli-Tech/iOS-JL_Health/tags
[tag_badgen]:https://img.shields.io/github/v/tag/Jieli-Tech/iOS-JL_Health?style=plastic&logo=apple&labelColor=ffffff&color=informational&label=Tag&logoColor=blue

# iOS-JL_Health[![tag][tag_badgen]][tag download]

<div align="center">

**Jieli Health SDK (iOS) - Development Platform for Jieli Bluetooth Wearable Products**

![iOS](https://img.shields.io/badge/iOS-10.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-14.0+-orange.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

[中文](./README.md) · [English](./README_EN.md) · [Documentation Center](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html) · [SDK Version History](#8-version-history) · [Report Issue](https://github.com/Jieli-Tech/iOS-JL_Health/issues)

</div>

---

## 📋 Table of Contents

- [1. Overview](#1-overview)
- [2. Runtime Environment](#2-runtime-environment)
- [3. Quick Start](#3-quick-start)
- [4. Project Structure](#4-project-structure)
- [5. Configuration](#5-configuration)
- [6. Debugging Tips](#6-debugging-tips)
- [7. Community & Support](#7-community--support)
- [8. Version History](#8-version-history)
- [9. License](#9-license)

---

## 1. Overview

`iOS-JL_Health` is a feature integration SDK provided by **Zhuhai Jieli Technology Co., Ltd.** for Jieli Bluetooth wearable products. This SDK provides comprehensive health data management, OTA upgrade, watch face customization, audio codec, and other features, supporting the following application scenarios:

| Application Type | Typical Products |
|------------------|------------------|
| **Smart Watches** | Kids' watches, adult smart watches, health monitoring watches |
| **Health Bands** | Sports bands, sleep monitoring bands |
| **Wearable Devices** | Smart badges, smart rings, and other wearable devices |

**Jieli Health SDK** provides rich functional interfaces:

| Feature | Description |
|---------|-------------|
| **OTA Upgrade** | Firmware OTA, 4G module OTA, differential upgrade, etc. |
| **Watch Face Management** | Watch face file browsing, insertion, deletion, custom background, etc. |
| **Health Data** | Heart rate, blood oxygen, blood pressure, temperature, sleep and other health monitoring data sync |
| **Sports Data** | Sports info sync, step counting, calorie consumption, etc. |
| **Message Sync** | SMS, phone call, social app message push |
| **Weather Info** | Weather condition synchronization |
| **Contacts** | Frequently used contacts sync, emergency contacts setup |
| **Alarm Management** | Alarm CRUD operations |
| **File Transfer** | Large file transfer (e.g. music files), file browsing, file management |
| **Fall/Sedentary Reminder** | Health settings and safety reminder features |
| **Music Control** | Music file transfer, playback control, ID3 info display |
| **Image Conversion** | BMP/JPEG/PNG image codec conversion |
| **Device Find** | Find device or find phone |
| **Alipay** | Alipay activation and payment features |
| **AI Watch Face** | AI cloud service, AI watch face features |
| **Custom Commands** | Support for customer extended features |

This repository contains the complete SDK framework library (XCFramework format), iOS sample project source code, and development documentation to help developers quickly integrate Jieli Bluetooth health features into iOS applications.

---

## 2. Runtime Environment

| Category | Requirement | Description |
|----------|-------------|-------------|
| **iOS System** | iOS 10.0+ | BLE support required |
| **Xcode Version** | 14.0+ | Latest version recommended |
| **Hardware Requirement** | SDK supporting Jieli RCSP protocol | AC701N, AC707N, AC695N, etc. |
| **Language Support** | Objective-C / Swift | Complete API support provided |

---

## 3. Quick Start

### 3.1 Clone Repository

```bash
git clone https://github.com/Jieli-Tech/iOS-JL_Health.git
cd iOS-JL_Health
```

### 3.2 Integrate SDK

1. **Import Frameworks**: Add XCFrameworks from the `libs/` directory to your project
2. **Configure Permissions**: Add Bluetooth usage descriptions in `Info.plist`
3. **Initialize SDK**: Refer to sample project initialization code for integration
4. **Start Development**: Use SDK APIs for health feature development

### 3.3 Feature Implementation Guide

This SDK provides multiple functional modules:

| Feature Module | Reference Library | Description |
|----------------|-------------------|-------------|
| **Bluetooth Connection** | `JL_BLEKit.xcframework` | Device scanning, connection, and basic protocol interaction |
| **Health Data** | `JL_BLEKit.xcframework` | Sports health data models, sleep monitoring |
| **OTA Upgrade** | `JL_OTALib.xcframework` | Firmware upgrade flow control, resource file transfer |
| **Watch Face** | `JLDialUnit.xcframework` | Watch face switching and customization |
| **Audio Codec** | `JLAudioUnitKit.xcframework` | Audio data encoding and decoding |
| **Image Conversion** | `JLBmpConvertKit.xcframework` | Custom watch face image conversion |
| **Resource Packaging** | `JLPackageResKit.xcframework` | Audio data and watch face resource packaging |

### 3.4 Quick Integration Steps

1. Integrate necessary XCFramework libraries and set `Embed & Sign`
2. Configure permissions: `Privacy - Bluetooth Peripheral/Always Usage Description`
3. Core call flow: Device connection → Protocol interaction → Feature invocation → Data callback
4. Refer to sample documentation and development resources for detailed implementation and best practices

---

## 4. Project Structure

```
iOS-JL_Health/
├── code/                           # Sample application source code
│   ├── JL_Health/                  #   YiDong Health application source
│   ├── SDKTestHelper/              #   Simple feature source code
│   ├── JLAudioUnitKitDemo/         #   Audio codec library demo
│   ├── HealthAide_ALi_IOT_V0.1.2(iOS)/ #   Alibaba Alipay integration demo
│   └── Jieli_iOS_Audio_Codec_V1.1.0/   #   Watch recording data codec demo
├── libs/                           # Core SDK libraries (XCFramework format)
│   ├── JL_AdvParse.xcframework     #   Advertisement packet parsing library
│   ├── JL_BLEKit.xcframework       #   Main business library (basic protocols)
│   ├── JL_HashPair.xcframework     #   Device authentication library
│   ├── JL_OTALib.xcframework       #   OTA upgrade business library
│   ├── JLAudioUnitKit.xcframework  #   Audio codec business library
│   ├── JLBmpConvertKit.xcframework #   Image conversion business library
│   ├── JLDialUnit.xcframework      #   Watch face related library
│   ├── JLLogHelper.xcframework     #   Log helper library
│   └── JLPackageResKit.xcframework #   Health feature business library
└── docs/                           # Documentation resources
    ├── Jieli_Health_SDK_iOS_Releases.pdf #   Version release notes
    ├── Jieli_OTA_iOS_Development_Guide.url #   Online doc: OTA development guide
    ├── Jieli_Health_SDK_Development_Guide.url #   Online doc: Development guide
    └── Custom_Bluetooth_Access_Method.url    #   Online doc: Access method introduction
```

### 4.1 Key Directory Description

| Directory | Purpose |
|-----------|---------|
| `code/JL_Health/` | **Complete Sample**: YiDong Health application source code |
| `code/SDKTestHelper/` | **Test Sample**: Simple feature test source code |
| `libs/` | **Core SDK**: XCFramework format health feature libraries |
| `docs/` | **Development Docs**: Version records, online documentation links |

---

## 5. Configuration

### 5.1 Required Libraries

| Library Name | Description |
|--------------|-------------|
| **JL_AdvParse.xcframework** | Advertisement packet parsing library |
| **JL_BLEKit.xcframework** | Main business library (basic protocols) |
| **JL_HashPair.xcframework** | Device authentication library |
| **JLLogHelper.xcframework** | Log helper library |

### 5.2 Optional Libraries

| Library Name | Description |
|--------------|-------------|
| **JL_OTALib.xcframework** | OTA upgrade business library (import when OTA features needed) |
| **JLAudioUnitKit.xcframework** | Audio codec business library (import when audio features needed) |
| **JLBmpConvertKit.xcframework** | Image conversion business library (import when image conversion needed) |
| **JLDialUnit.xcframework** | Watch face related library (import when watch face features needed) |
| **JLPackageResKit.xcframework** | Health feature business library (import when resource packaging needed) |

### 5.3 Permission Configuration

Add the following permissions in `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth is required to connect to Jieli devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Required to connect to Jieli devices as Bluetooth peripheral</string>
```

### 5.4 Log Management

JLLogHelper.xcframework provides log management functionality. Log output and storage can be controlled through related interfaces.

---

## 6. Debugging Tips

- **Log Output**: SDK provides detailed log output. Check Bluetooth connection status and data interaction through logs
- **Device Debugging**: Use Xcode Console viewer to check real-time logs
- **Troubleshooting**:
  - SDK: Refer to [SDK Development Documentation](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html)
  - Sample Code: Refer to sample projects in the `code/` directory

---

## 7. Community & Support

### Resource Links

| Resource | Link |
|----------|------|
| 📖 **Online Documentation Center** | [https://doc.zh-jieli.com/](https://doc.zh-jieli.com/) |
| 📄 **SDK Integration Documentation** | [https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html) |
| 🌐 **Official Website** | [https://www.zh-jieli.com/](https://www.zh-jieli.com/) |
| 🐛 **Issue Feedback** | [https://github.com/Jieli-Tech/iOS-JL_Health/issues](https://github.com/Jieli-Tech/iOS-JL_Health/issues) |

---

## 8. Version History

### SDK Versions

| Version | Release Date | Major Updates |
|---------|--------------|---------------|
| **V1.14.0(Beta)** | 2026/03/03 | 1. New features<br/>(1) Updated SDK version to V1.14.0 (Beta) |
| **V1.13.0(Beta)** | 2026/03/02 | 1. New features<br/>(1) Updated SDK version to V1.13.0 (Beta) |
| **V1.12.0** | 2024/11/22 | 1. New features<br/>(1) Added AC707N compatible custom watch face image conversion<br/>(2) Separated image conversion tool as independent module library |
| **V1.11.0** | 2024/03/15 | 1. New features<br/>(1) Added 4G module OTA functionality<br/>(2) Added watch face extended parameters and supplemented AI watch face workflow |
| **V1.10.0** | 2024/01/05 | 1. New features<br/>(1) Added AI watch face functionality<br/>(2) Extended Nand Flash storage information support |
| **V1.9.0** | 2023/09/15 | 1. New features<br/>(1) Added AI cloud service functionality |
| **V1.8.0** | 2023/04/23 | 1. Bug fixes<br/>(1) Fixed small file packet transmission errors<br/>(2) Fixed large file transfer timeout issues<br/>2. New features<br/>(1) Improved device recording interface, added bidirectional control interface<br/>(2) Added time synchronization setting interface<br/>(3) Added image conversion interface to ignore header file information<br/>3. Performance optimization<br/>(1) Optimized RTC module limitations, extended RTC available length<br/>(2) Separated SDK library into functional modules<br/>(3) Decoupled light control module, optimized watch face thread callback deletion, optimized custom command module |

> Note: For detailed version iteration records, please refer to the release notes document in the docs directory.

---

## 9. License

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

---

<div align="center">
  <sub>Copyright © 2024-2026 Zhuhai Jieli Technology Co., Ltd. All rights reserved.</sub>
</div>
