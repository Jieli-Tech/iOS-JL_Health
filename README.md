[tag download]:https://github.com/Jieli-Tech/iOS-JL_Health/tags
[tag_badgen]:https://img.shields.io/github/v/tag/Jieli-Tech/iOS-JL_Health?style=plastic&logo=apple&labelColor=ffffff&color=informational&label=Tag&logoColor=blue

# iOS-JL_Health[![tag][tag_badgen]][tag download]

<div align="center">

**杰理健康 SDK（iOS）- 专为杰理蓝牙穿戴类产品提供功能集成开发平台**

![iOS](https://img.shields.io/badge/iOS-10.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-14.0+-orange.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

[中文](./README.md) · [English](./README_EN.md) · [文档中心](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html) · [SDK 版本历史](#八版本历史) · [报告问题](https://github.com/Jieli-Tech/iOS-JL_Health/issues)

</div>

---

## 📋 目录

- [一、概述](#一概述)
- [二、运行环境](#二运行环境)
- [三、快速开始](#三快速开始)
- [四、工程结构](#四工程结构)
- [五、配置说明](#五配置说明)
- [六、调试技巧](#六调试技巧)
- [七、社区与支持](#七社区与支持)
- [八、版本历史](#八版本历史)
- [九、许可证](#九许可证)

---

## 一、概述

`iOS-JL_Health` 是**珠海市杰理科技股份有限公司**为杰理蓝牙穿戴类产品提供的功能集成 SDK。本 SDK 提供完整的健康数据管理、OTA 升级、表盘定制、音频编解码等功能，支持以下应用场景：

| 应用类型 | 典型产品 |
|---------|---------|
| **智能手表** | 儿童手表、成人智能手表、健康监测手表 |
| **健康手环** | 运动手环、睡眠监测手环 |
| **穿戴设备** | 智能徽章、智能戒指等可穿戴设备 |

**杰理健康SDK**提供了丰富的功能接口：

| 功能           | 说明                                                     |
| -------------- | -------------------------------------------------------- |
| **OTA升级**    | 固件空中升级、4G模块OTA、差分升级等                        |
| **表盘管理**   | 表盘文件浏览、插入、删除、自定义背景等                     |
| **健康数据**   | 心率、血氧、血压、体温、睡眠等健康监测数据同步             |
| **运动数据**   | 运动信息同步、步数统计、卡路里消耗等                       |
| **消息同步**   | 短信、电话、社交软件消息推送                               |
| **天气信息**   | 同步天气情况                                               |
| **联系人**     | 常用联系人同步、紧急联系人设置                             |
| **闹钟管理**   | 闹钟的增删改查                                             |
| **文件传输**   | 大文件传输(如音乐文件)、文件浏览、文件管理                 |
| **跌倒/久坐提醒** | 健康设置与安全提醒功能                                   |
| **音乐控制**   | 音乐文件传输、播放控制、ID3信息显示                        |
| **图像转换**   | BMP/JPEG/PNG图像编解码转换                     |
| **设备查找**   | 查找设备或查找手机                                         |
| **支付宝**     | 支付宝激活、支付功能                                       |
| **AI表盘**     | AI云服务、AI表盘功能                                     |
| **自定义命令** | 支持客户拓展功能                                         |


本仓库包含完整的 SDK 框架库（XCFramework 格式）、iOS 示例工程源码及开发文档，帮助开发者快速集成杰理蓝牙健康功能到 iOS 应用中。

---

## 二、运行环境

| 类别 | 要求 | 说明 |
|------|------|------|
| **iOS 系统** | iOS 10.0+ | 支持 BLE 功能 |
| **Xcode 版本** | 14.0+ | 建议使用最新版本 |
| **硬件要求** | 支持杰理 RCSP 协议的 SDK | AC701N、AC707N、AC695N等 |
| **语言支持** | Objective-C / Swift | 提供完整的 API 支持 |

---

## 三、快速开始

### 3.1 克隆仓库

```bash
git clone https://github.com/Jieli-Tech/iOS-JL_Health.git
cd iOS-JL_Health
```

### 3.2 集成 SDK

1. **导入框架**：将 `libs/` 目录下的 XCFramework 添加到项目中
2. **配置权限**：在 `Info.plist` 中添加蓝牙使用权限描述
3. **初始化 SDK**：参考示例工程的初始化代码进行集成
4. **开始开发**：使用 SDK 提供的 API 进行健康功能开发

### 3.3 功能实现指南

本 SDK 提供多种功能模块：

| 功能模块 | 参考库 | 说明 |
|---------|--------|------|
| **蓝牙连接** | `JL_BLEKit.xcframework` | 设备扫描与连接、基础协议交互 |
| **健康数据** | `JL_BLEKit.xcframework` | 运动健康数据模型、睡眠监测 |
| **OTA 升级** | `JL_OTALib.xcframework` | 固件升级流程控制、资源文件传输 |
| **表盘功能** | `JLDialUnit.xcframework` | 表盘切换与自定义 |
| **音频编解码** | `JLAudioUnitKit.xcframework` | 音频数据编码与解码 |
| **图片转码** | `JLBmpConvertKit.xcframework` | 自定义表盘图像转换 |
| **资源打包** | `JLPackageResKit.xcframework` | 音频数据、表盘 res 资源打包 |

### 3.4 快速集成步骤

1. 集成必要的 XCFramework 库并设置 `Embed & Sign`
2. 配置权限：`Privacy - Bluetooth Peripheral/Always Usage Description`
3. 核心调用流程：设备连接 → 协议交互 → 功能调用 → 数据回调
4. 详细实现与最佳实践请参考对应的示例文档和开发资料

---

## 四、工程结构

```
iOS-JL_Health/
├── code/                           # 示例程序源码
│   ├── JL_Health/                  #   宜动健康源码
│   ├── SDKTestHelper/              #   简单功能源码
│   ├── JLAudioUnitKitDemo/         #   音频编解码业务库示例
│   ├── HealthAide_ALi_IOT_V0.1.2(iOS)/ #   阿里支付宝集成示例
│   └── 杰理iOS音频编解码V1.1.0/      #   手表录音数据编解码示例
├── libs/                           # 核心 SDK 库 (XCFramework 格式)
│   ├── JL_AdvParse.xcframework     #   广播包解析库
│   ├── JL_BLEKit.xcframework       #   主业务库（基础协议相关）
│   ├── JL_HashPair.xcframework     #   设备认证库
│   ├── JL_OTALib.xcframework       #   OTA 升级业务库
│   ├── JLAudioUnitKit.xcframework  #   音频编解码业务库
│   ├── JLBmpConvertKit.xcframework #   图片转码业务库
│   ├── JLDialUnit.xcframework      #   表盘相关库
│   ├── JLLogHelper.xcframework     #   日志助手库
│   └── JLPackageResKit.xcframework #   健康功能业务库
└── docs/                           # 文档资源
    ├── Jieli_Health_SDK_iOS_Releases.pdf #   版本发布记录
    ├── 杰理OTA升级(iOS)开发说明.url      #   在线文档：OTA开发说明
    ├── 杰理健康SDK开发说明.url           #   在线文档：开发说明
    └── 自定义蓝牙接入方式.url             #   在线文档：接入方式介绍
```

### 4.1 关键目录说明

| 目录 | 作用 |
|------|------|
| `code/JL_Health/` | **完整示例**：宜动健康应用源码 |
| `code/SDKTestHelper/` | **测试示例**：简单功能测试源码 |
| `libs/` | **核心 SDK**：XCFramework 格式的健康功能库 |
| `docs/` | **开发文档**：版本记录、在线文档链接 |

---

## 五、配置说明

### 5.1 必须导入的库

| 库名 | 说明 |
|------|------|
| **JL_AdvParse.xcframework** | 广播包解析库 |
| **JL_BLEKit.xcframework** | 主业务库（基础协议相关） |
| **JL_HashPair.xcframework** | 设备认证库 |
| **JLLogHelper.xcframework** | 日志助手库 |

### 5.2 可选导入的库

| 库名 | 说明 |
|------|------|
| **JL_OTALib.xcframework** | OTA 升级业务库（需要 OTA 功能时导入） |
| **JLAudioUnitKit.xcframework** | 音频编解码业务库（需要音频功能时导入） |
| **JLBmpConvertKit.xcframework** | 图片转码业务库（需要图像转换时导入） |
| **JLDialUnit.xcframework** | 表盘相关库（需要表盘功能时导入） |
| **JLPackageResKit.xcframework** | 健康功能业务库（需要资源打包时导入） |

### 5.3 权限配置

在 `Info.plist` 中添加以下权限：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要使用蓝牙功能连接杰理设备</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>需要作为蓝牙外设连接杰理设备</string>
```

### 5.4 日志管理

JLLogHelper.xcframework 提供了日志管理功能，可通过相关接口控制日志输出和存储。

---

## 六、调试技巧

- **日志输出**：SDK 提供详细的日志输出，可通过日志查看蓝牙连接状态和数据交互
- **设备调试**：使用 Xcode 的 Console 查看器查看实时日志
- **问题排查**：
  - SDK：参考 [SDK 开发文档](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html)
  - 示例代码：参考 `code/` 目录下的示例工程

---

## 七、社区与支持

### 资源链接

| 资源 | 链接 |
|------|------|
| 📖 **在线文档中心** | [https://doc.zh-jieli.com/](https://doc.zh-jieli.com/) |
| 📄 **SDK 接入文档** | [https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html) |
| 🌐 **官方网站** | [https://www.zh-jieli.com/](https://www.zh-jieli.com/) |
| 🐛 **问题反馈** | [https://github.com/Jieli-Tech/iOS-JL_Health/issues](https://github.com/Jieli-Tech/iOS-JL_Health/issues) |

---

## 八、版本历史

### SDK 版本

| 版本 | 发布日期 | 主要更新 |
|------|----------|----------|
| **V1.14.0(Beta)** | 2026/03/03 | 1. 新增功能<br/>(1) 更替 SDK 版本为 V1.14.0（Beta） |
| **V1.13.0(Beta)** | 2026/03/02 | 1. 新增功能<br/>(1) 更替 SDK 版本为 V1.13.0（Beta） |
| **V1.12.0** | 2024/11/22 | 1. 新增功能<br/>(1) 增加兼容 AC707N 的自定义表盘图像转换<br/>(2) 分离图像转换工具作为独立模块库 |
| **V1.11.0** | 2024/03/15 | 1. 新增功能<br/>(1) 增加 4G 模块 OTA 功能<br/>(2) 增加表盘拓展参数和补充 AI 表盘流程 |
| **V1.10.0** | 2024/01/05 | 1. 新增功能<br/>(1) 增加 AI 表盘功能<br/>(2) Nand Flash 存储器信息拓展支持 |
| **V1.9.0** | 2023/09/15 | 1. 新增功能<br/>(1) 增加 AI 云服务功能 |
| **V1.8.0** | 2023/04/23 | 1. 修复问题<br/>(1) 修复小文件分包传输出错问题<br/>(2) 修复大文件传输超时问题<br/>2. 新增功能<br/>(1) 设备录音接口完善，新增双向控制接口<br/>(2) 新增时间同步设置接口<br/>(3) 新增图片转码增加忽略头文件信息接口<br/>3. 性能优化<br/>(1) 优化 RTC 模块不足，扩展 RTC 可用长度<br/>(2) 对 SDK 库进行功能模块分离<br/>(3) 解耦灯光控制模块、优化删除表盘线程回调、优化自定义命令模块 |

> 注：详细的版本迭代记录请参考 docs 目录下的发布记录文档。

---

## 九、许可证

本项目采用 [Apache License 2.0](./LICENSE) 开源协议。

```
Copyright 2024 珠海市杰理科技股份有限公司

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
  <sub>Copyright © 2024-2026 珠海市杰理科技股份有限公司. All rights reserved.</sub>
</div>
