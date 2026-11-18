<div align="center">

# 🚗 驾考通 · 移动端

**基于 uni-app + Vue3 + TypeScript 的驾考学习 App，一套代码运行在 App / H5 / 微信小程序**

[![uni-app](https://img.shields.io/badge/uni--app-Vue3%20%2B%20TS-2F9E44)](https://uniapp.dcloud.net.cn/)
[![Vue](https://img.shields.io/badge/Vue-3.x-42B883?logo=vue.js&logoColor=white)](https://vuejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Pinia](https://img.shields.io/badge/Pinia-2.x-F7D336)](https://pinia.vuejs.org/)
[![Vite](https://img.shields.io/badge/Vite-5.x-646CFF?logo=vite&logoColor=white)](https://vitejs.dev/)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

</div>

---

## 🔗 源码仓库

| 端 | 仓库地址 |
| --- | --- |
| 移动端（App / H5 / 微信小程序） | [https://github.com/jiangshang-dev/drive-test-app](https://github.com/jiangshang-dev/drive-test-app) |
| 后端服务（管理后台 / API / AI / VOD） | [https://github.com/jiangshang-dev/driver-exam](https://github.com/jiangshang-dev/driver-exam) |

> 建议先 Star 两个仓库再 Clone，方便后续第一时间获取功能更新与问题修复。

---

> ### ⭐ Star First, Clone Later
>
> **如果这个项目对你有帮助，请先点一下右上角的 Star 再 Clone。**
> 不 Star 直接 Clone 的话……小程序可能会在审核时多卡你一天 😄
> （开玩笑的。但 Star 是开源作者持续迭代最大的动力。）

---

## 📖 项目简介

**驾考通移动端** 是驾考学习平台的用户端，覆盖从刷题、模拟考试到视频学习、AI 助手、积分商城的完整学习闭环。

- 一套代码同时支持 **App（Android / iOS）**、**H5**、**微信小程序**
- 与后端 `driver-exam-api` 配套使用，接口统一走 `/api` 前缀
- 支持账号密码、手机号验证码、微信小程序一键登录
- 适合作为毕业设计 / 课程设计，也可直接用于商业项目二次开发

> 💼 **本项目允许商业使用**：采用 Apache License 2.0，个人与企业均可免费用于商业项目，无需额外授权或授权费用。

---

## ✨ 功能一览

### 📚 学习与考试
- 顺序刷题、章节/题型筛选、随机练习
- 全真模拟考试：倒计时、自动交卷、成绩解析
- 错题本、我的收藏、答题记录
- 学习记录、考试记录、学习统计（正确率 / 学习时长 / 积分）
- 每日一练、考点速记、考试计划
- 交通标志图示详解

### 🎬 视频学习
- 交规视频列表、分类筛选
- 视频在线播放、VIP 权限控制
- 视频评论、点赞、收藏

### 🤖 AI 智能助手
- 多轮对话、流式回复、思考过程展示
- 会话新建、上下文记忆
- 会员权限校验（非会员展示开通引导）

### 🛒 积分商城与会员
- 积分商城：商品浏览、积分兑换、订单确认
- 会员中心 / VIP 开通、会员权益
- 积分明细、积分规则
- 我的订单、订单详情、支付与支付结果页
- 每日签到、看视频得会员

### 👤 个人中心
- 个人信息页：头像、昵称、手机号、积分、会员状态
- 准驾车型切换（科目一 / 科目四）
- 退出登录
- 统一原生导航栏，所有页面风格一致

---

## 🧱 技术选型

| 分类 | 技术 |
| --- | --- |
| 跨端框架 | uni-app（Vue3 + TypeScript + `<script setup>`） |
| 构建工具 | Vite 5 |
| 状态管理 | Pinia + pinia-plugin-persistedstate |
| 组件库 | uni-ui |
| 样式 | SCSS / rpx 响应式布局 |
| 请求 | `uni.request` 统一拦截器封装 |
| 代码规范 | ESLint、Prettier、Husky、lint-staged |
| 类型检查 | vue-tsc |

---

## 🗂 工程结构

```text
drive-test-app
├─ src
│  ├─ components           公共组件（车型选择、返回按钮等）
│  ├─ pages                主包页面
│  │  ├─ index             首页 / 顺序刷题 / 模拟考试 / 成绩页
│  │  ├─ daily             每日一练
│  │  ├─ knowledge         考点速记
│  │  ├─ plan              考试计划
│  │  ├─ wrong-questions   错题本
│  │  ├─ favorites         我的收藏
│  │  ├─ study-record      学习记录
│  │  ├─ exam-record       考试记录
│  │  ├─ statistics        学习统计
│  │  ├─ videos            交规视频
│  │  ├─ video-player      视频播放
│  │  ├─ traffic-signs     交通标志图示
│  │  ├─ aichat            AI 助手
│  │  ├─ points-mall       积分商城
│  │  ├─ member-center     会员中心
│  │  ├─ vip               VIP 开通
│  │  ├─ order-list        我的订单
│  │  ├─ order-detail      订单详情
│  │  ├─ payment           确认支付 / 支付成功
│  │  ├─ mall              订单确认
│  │  ├─ question-detail   题目详情
│  │  ├─ profile           个人信息
│  │  ├─ login             登录 / 注册
│  │  └─ my                我的
│  ├─ pagesMember          分包页面（设置等）
│  ├─ services             接口请求（登录、业务接口）
│  ├─ stores               Pinia Store（会员、考试类型）
│  ├─ types                TypeScript 类型声明
│  ├─ utils                http、缓存、VIP 校验、分享等工具
│  ├─ static               图片与 tabBar 图标
│  ├─ styles               全局样式
│  ├─ App.vue              应用入口
│  ├─ main.ts              Vue 初始化入口
│  ├─ pages.json           页面路由与导航栏配置
│  ├─ manifest.json        应用名称、appid 等打包配置
│  └─ uni.scss             全局 SCSS 变量
├─ package.json
├─ tsconfig.json
├─ vite.config.ts
└─ index.html
```

---

## 🚀 快速开始

### 1. 环境要求
- Node.js 18+
- pnpm（推荐）或 npm
- 微信开发者工具（运行小程序）
- HBuilderX（运行 App / 真机调试）

### 2. 启动后端
先启动后端 `driver-exam` 项目中的 API 服务（默认 `http://localhost:8081/api`），否则登录、题库、视频等接口都会请求失败。

### 3. 配置接口地址
打开 [src/utils/http.ts](src/utils/http.ts)，按环境修改：

```ts
const baseURL = 'http://localhost:8081/api'
```

### 4. 安装依赖
```bash
# pnpm
pnpm install

# 或 npm
npm install
```

### 5. 运行项目
```bash
# H5
pnpm dev:h5

# 微信小程序
pnpm dev:mp-weixin

# App（也可用 HBuilderX 运行到手机或模拟器）
pnpm dev:app
```

微信小程序端运行后，用微信开发者工具导入 `dist/dev/mp-weixin` 目录。

### 6. 登录说明
- **账号密码登录**：使用后台「用户管理」中设置过密码的账号，或先在登录页注册
- **手机号验证码登录**：未接短信服务商，验证码打印在 `driver-exam-api` 后端日志中，搜索「【登录验证码】」获取
- **微信一键登录**：仅在微信小程序端显示，H5 / App 不调用 `wx.login`

---

## 📱 平台适配

| 能力 | H5 | App | 微信小程序 |
| --- | --- | --- | --- |
| 账号密码 / 验证码登录 | ✅ | ✅ | ✅ |
| 微信一键登录 | ❌ | ❌ | ✅ |
| 视频播放 | ✅ | ✅ | ✅ |
| 支付 | 视配置 | 视配置 | 需开通微信支付 |

代码中统一通过 `uni.getSystemInfoSync().uniPlatform` 做平台判断与能力降级。

---

## ❓ 常见问题

**Q：登录后接口全部 401 / 请求失败？**
A：确认 `src/utils/http.ts` 的 `baseURL` 指向已启动的后端 API，且后端端口为 `8081`。

**Q：验证码收不到？**
A：项目默认未接短信服务商，验证码会输出在 `driver-exam-api` 日志中，搜索「【登录验证码】」即可。

**Q：H5 端提示 `uni.login not supported`？**
A：微信登录只在微信小程序端可用，项目已做平台判断，H5 / App 请使用账号密码或验证码登录。

**Q：微信开发者工具打开空白？**
A：先执行 `pnpm dev:mp-weixin`，再导入 `dist/dev/mp-weixin` 目录，不要直接导入 `src`。

**Q：图片 / 视频无法显示？**
A：检查后端「文件上传」配置的域名是否可访问，以及小程序后台是否配置了对应的 downloadFile 合法域名。

---

## 🛣️ 持续迭代

移动端会与后端一起**长期维护、持续优化**：

- 持续补充业务页面与交互细节，修复使用中发现的问题
- 持续优化首屏加载、长列表、视频播放等性能体验
- 持续完善 AI 助手、积分商城、会员体系的移动端体验
- 计划方向：消息通知、学习提醒、更多支付方式、深色模式、无障碍适配
- 更新会同步到本仓库与后端仓库，建议 **Watch + Star** 获取最新版本
- 欢迎通过 Issue 反馈问题或提出新需求

---

## 💼 商业使用

- 采用 **Apache License 2.0**，**允许个人和企业免费商用**，包括闭源商用、私有化部署和二次开发
- 无需额外授权，也没有授权费用；商用时请保留原始版权声明与 LICENSE
- 项目按「现状」提供，不附带任何明示或暗示的担保
- 如用于商业项目，欢迎 Star 支持，也欢迎注明来源（非强制）

---

## 🤝 参与贡献

1. Fork 本仓库：[jiangshang-dev/drive-test-app](https://github.com/jiangshang-dev/drive-test-app)
2. 新建分支：`feature/your-feature` 或 `fix/your-fix`
3. 提交代码：建议使用 `feat: xxx`、`fix: xxx`、`docs: xxx`
4. 发起 Pull Request，说明改动内容和测试平台

**如果这个项目帮到了你，别忘了点一个 ⭐ Star，这是对开源最好的支持。**

---

## 📄 License

[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

---

<div align="center">

**⭐ Star 一下，Bug 远离你 ⭐**

</div>
