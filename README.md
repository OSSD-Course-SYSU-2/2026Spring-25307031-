# 老年人健康管理系统 (Elderly Health Management System)

## 项目简介

这是一个专为老年人设计的健康管理HarmonyOS应用，提供健康打卡、用药提醒、健康指标记录和紧急联系等功能。应用采用简洁直观的界面设计，方便老年人日常使用。

## 技术栈

- **开发语言**: ArkTS (TypeScript扩展)
- **UI框架**: ArkUI (HarmonyOS原生UI框架)
- **目标平台**: HarmonyOS 5.0.2(14)
- **数据存储**: HarmonyOS Preferences API
- **构建工具**: Hvigor

## 功能模块

### 1. 健康打卡 (Health Check)
- 每日健康状态记录（良好/一般/不适）
- 健康状态统计和历史记录查看
- 备注信息添加
- 数据持久化存储

### 2. 用药提醒 (Medication Reminder) ✅ 已完善
- 药品信息录入（名称、剂量、服药时间、频率、备注）
- 服药状态跟踪（已服用/未服用）
- 用药记录管理（添加、编辑、删除）
- **定时提醒功能** - 基于HarmonyOS提醒代理管理API
- **通知推送** - 使用NotificationManager发送用药提醒
- **智能检查** - 每分钟自动检查是否需要提醒
- **统计面板** - 显示总提醒数、待服用、已服用统计
- **时间选择器** - 直观的小时分钟选择界面

### 3. 健康指标 (Vital Signs) ✅ 已完善
- 血压、血糖、心率记录
- 历史数据查看和管理
- **数据统计分析** - 平均值、最大值、最小值、记录数
- **时间范围筛选** - 周、月、全部数据筛选
- **健康建议系统** - 基于数据提供个性化健康建议
- **数据验证** - 血压格式验证、正常范围提示
- **单位显示** - mmHg、mmol/L、次/分
- 备注信息支持

### 4. 紧急联系 (Emergency Contact) ✅ 已完善
- **SOS紧急呼叫** - 一键触发紧急呼叫，自动拨打联系人并发送位置
- 紧急联系人管理（添加/编辑/删除）
- **快速拨号** - 一键拨打联系人电话
- **位置信息共享** - 获取当前位置并发送短信
- **短信通知** - 自动发送位置信息给所有紧急联系人
- 关系标注（子女、配偶、医生、朋友等）
- **权限管理** - 自动请求电话、短信、位置权限
- **关系图标** - 根据关系显示对应图标

## 项目结构

```
entry/
├── src/main/
│   ├── ets/
│   │   ├── pages/              # 页面组件
│   │   │   ├── Index.ets       # 主页面（底部导航）
│   │   │   ├── HealthCheckPage.ets    # 健康打卡页面
│   │   │   ├── MedicationPage.ets     # 用药提醒页面 ✅ 已完善
│   │   │   ├── VitalSignPage.ets      # 健康指标页面 ✅ 已完善
│   │   │   └── EmergencyPage.ets      # 紧急联系页面 ✅ 已完善
│   │   ├── model/              # 数据模型
│   │   │   ├── HealthCheckRecord.ts   # 健康打卡记录模型
│   │   │   ├── MedicationRecord.ts    # 用药记录模型 ✅ 已增强
│   │   │   ├── VitalSignRecord.ts     # 健康指标记录模型
│   │   │   └── EmergencyContact.ts    # 紧急联系人模型
│   │   ├── service/            # 业务服务
│   │   │   ├── StorageService.ts      # 数据存储服务
│   │   │   └── NotificationService.ts # 通知提醒服务 ✅ 新增
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets       # 应用入口
│   │   └── entrybackupability/
│   │       └── EntryBackupAbility.ets # 备份能力
│   ├── resources/              # 资源文件
│   │   └── base/element/
│   │       └── string.json     # 字符串资源（含权限说明）
│   └── module.json5            # 模块配置 ✅ 已添加权限
├── build-profile.json5         # 构建配置
└── oh-package.json5            # 依赖管理
```

## 核心特性

### 新增功能亮点 ✨

#### 1. 智能用药提醒系统
- **定时提醒**: 使用HarmonyOS ReminderAgentManager实现精确定时提醒
- **通知推送**: 通过NotificationManager发送用药提醒通知
- **自动检查**: 每分钟自动检查是否需要提醒
- **提醒管理**: 支持添加、编辑、删除提醒
- **状态跟踪**: 实时跟踪服药状态

#### 2. 健康数据分析系统
- **统计计算**: 自动计算平均值、最大值、最小值
- **时间筛选**: 支持周、月、全部数据筛选
- **健康建议**: 基于数据提供个性化健康建议
- **数据验证**: 血压格式验证、正常范围提示

#### 3. 紧急救援系统
- **一键SOS**: 长按SOS按钮触发紧急呼叫
- **自动拨号**: 自动拨打第一个紧急联系人电话
- **位置共享**: 获取当前位置并发送给所有联系人
- **短信通知**: 自动发送包含位置信息的短信

### 数据持久化
- 使用HarmonyOS Preferences API实现本地数据存储
- 单例模式管理存储服务
- JSON序列化/反序列化支持
- 自动数据加载和保存

### UI设计原则
- 大字体、高对比度设计，适合老年人阅读
- 简洁直观的底部导航栏
- 清晰的功能分区和操作引导
- 响应式布局适配不同屏幕尺寸

### 状态管理
- 使用ArkTS装饰器进行状态管理
- @State装饰器管理组件内部状态
- 生命周期管理（aboutToAppear/aboutToDisappear）

## 开发环境要求

- DevEco Studio 5.0+
- HarmonyOS SDK 5.0.2(14)
- Node.js 14+
- Git

## 安装和运行

### 1. 克隆项目
```bash
git clone <repository-url>
cd olddirect
```

### 2. 打开项目
使用DevEco Studio打开项目目录

### 3. 同步依赖
项目会自动同步依赖，或手动执行：
```bash
ohpm install
```

### 4. 运行应用
- 连接HarmonyOS设备或启动模拟器
- 点击DevEco Studio的运行按钮

## 构建配置

### 模块配置 (module.json5)
- **模块类型**: entry（入口模块）
- **设备类型**: phone
- **主Ability**: EntryAbility
- **备份支持**: 已启用

### 构建模式
- **Debug模式**: 开发调试使用
- **Release模式**: 生产发布使用

## 数据模型说明

### HealthCheckRecord
```typescript
{
  healthStatus: '良好' | '一般' | '不适',
  timestamp: Date,
  note: string
}
```

### MedicationRecord
```typescript
{
  medicineName: string,
  dosage: string,
  time: string,
  isTaken: boolean
}
```

### VitalSignRecord
```typescript
{
  type: '血压' | '血糖' | '心率',
  value: string,
  note: string,
  timestamp: Date
}
```

### EmergencyContact
```typescript
{
  name: string,
  phone: string,
  relationship: string
}
```

## 已实现功能 ✅

- [x] 用药定时提醒通知系统
- [x] 健康数据统计分析
- [x] 智能健康建议系统
- [x] SOS紧急呼叫功能
- [x] 快速拨号和位置共享
- [x] 权限自动申请管理

## 待完善功能

- [ ] 健康数据趋势图表可视化
- [ ] 数据导出功能（CSV/PDF）
- [ ] 多语言支持
- [ ] 深色模式适配
- [ ] 数据云同步
- [ ] 家属远程查看功能
- [ ] 语音输入辅助
- [ ] 无障碍功能增强

## 贡献指南

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

如有问题或建议，请提交Issue或联系开发团队。

## 致谢

感谢HarmonyOS开发社区的支持和贡献。
