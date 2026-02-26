# iOS-JL_Health
**中文**|[EN](https://github.com/Jieli-Tech/iOS-JL_Health/blob/main/README-en.md)

<br/>

<div align="center">

![iOS](https://img.shields.io/badge/iOS-10.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)       

<strong style="font:24px;color:#000000">杰理健康SDK(iOS)</strong>

**杰理健康SDK**是<strong style="color:#ee2233">珠海市杰理科技股份有限公司</strong>(以下简称“本公司”)开发，专门提供本公司蓝牙穿戴类产品的功能集成SDK。

</div>

## 快速开始

为了帮助开发者快速接入<strong style="color:red">杰理健康SDK</strong>，请开发前详细阅读:

- [杰理健康SDK(iOS)开发文档](https://doc.zh-jieli.com/Apps/iOS/health/zh-cn/master/index.html)
- [开发说明文档](./docs/)
- [核心库](./libs/)

## 开发资料介绍

```tex
 ├── code
      ├── JieliJianKang                   --- 宜动健康源码
      ├── JLWatchDemo                     --- 简单功能源码
      ├── HealthAide_ALi_IOT_V0.1.2(iOS)  --- 阿里支付宝集成示例
      ├── 杰理iOS音频编解码V1.1.0            --- 手表录音数据编解码示例
 ├── docs
      ├── Jieli_Health_SDK_iOS_Releases.pdf --- 版本发布记录
      ├── 杰理OTA升级(iOS)开发说明.url        --- 在线文档：OTA开发说明
      ├── 杰理健康SDK开发说明.url             --- 在线文档：开发说明
      ├── 自定义蓝牙接入方式.url               --- 在线文档：接入方式介绍
 ├── libs
      ├── JLDialUnit.framework            --- 表盘相关
      ├── JL_AdvParse.framework           --- 广播包解析
      ├── JL_BLEKit.framework             --- 主业务库（基础协议相关）
      ├── JL_HashPair.framework           --- 设备认证
      ├── JL_OTALib.framework             --- OTA升级业务库
      ├── third_party                     --- 第三方库
```

## 版本说明

| 版本   | 日期       | 修改记录                                                     |
| ------ | ---------- | ------------------------------------------------------------ |
| V1.9.0 | 2023/9/15  | 1、新增功能<br />(1)增加 AI 云服务功能                       |
| V1.8.0 | 2023/04/23 | 1. 修复问题<br/>(1) 修复小文件分包传输出错问题<br/>(2) 修复大文件传输超时问题<br/>2. 新增功能<br/>(1) 设备录音接口完善，新增双向控制接口<br/>(2) 新增时间同步设置接口<br/>(3) 新增图片转码增加忽略头文件信息接口<br/>3. 性能优化<br/>(1) 优化 RTC 模块不足，扩展 RTC 可用长度<br/>(2) 对 SDK 库进行功能模块分离：<br/>- JL_OTALib.framework: OTA 升级业务库<br/>- JL_AdvParse.framework: 杰理蓝牙设备广播包解析业务库<br/>- JL_HashPair.framework: 设备认证业务库<br/>- JL_BLEKit.framework: 主业务库<br/>(3) 解耦灯光控制模块、优化删除表盘线程回调、优化自定义命令模块 |

> 注：详细的版本迭代记录请参考 docs 目录下的发布记录文档。

## 功能实现示例

### 宜动健康

1. 蓝牙连接实现，可以参考 `JL_BLEKit.framework` 中的 `JL_ManagerM` 类
   - 设备扫描与连接
   - 基础协议交互
2. 健康功能实现，可以参考 `JL_BLEKit.framework` 中的相关 Manager
   - `JL_SportDataModel` / `JL_HealthDataModel`: 运动健康数据模型
   - `JL_SleepMonitorModel`: 睡眠监测
3. OTA功能实现，可以参考 `JL_OTALib.framework` 中的 `JL_OTAManager` 类
   - 固件升级流程控制
   - 资源文件传输
4. 表盘功能实现，可以参考 `JLDialUnit.framework`
   - 表盘切换与自定义

**测试功能可以参考 `code/JieliJianKang` 中的示例代码**

## 技术支持

- 🌐 **官方网站**: [杰理科技](https://www.zh-jieli.com/)
- 📧 **技术支持**: 请通过官方渠道联系

## 许可证

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

<div align="center">

**© 2024 珠海市杰理科技股份有限公司 | Licensed under Apache License 2.0**

</div>
