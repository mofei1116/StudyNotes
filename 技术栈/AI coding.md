# 基本概念

- LLM（大语言模型，Large Language Modle）：基于Transformer架构
- Token：大模型处理文本的最基本单位
- Tokenizer：对文字进行编码和解码
	- 编码：先将文字**切分**为多个token，token再**映射**成数字
	- 解码：将数字映射成token，LLM每次只给出一个token
- Context（上下文）：大模型每次处理任务时所收到的信息总和
- Context Window（上下文窗口）：Context能容纳的最大Token数量
- Prompt（提示词）：给LLM的指令或提示
- Tool（工具）：给LLM提供感知外部的能力
- Agent（智能体）：自主规划，自主调用工具，直到解决任务；工作循环：感知->推理->行动->反馈（检查结果）

# Vibe Coding

1. 意图优先：描述效果
2. 快读迭代：生成->测试->修正
3. 信任但验证
4. 上下文经营：维护和优化项目背景信息

# 工程化升级范式

Agentic Engineering

## 智能体协作模式

多个agent协作工作

- 领导者-执行者模式（Leader-Worker）:一个agent负责拆分任务和协调，多个agent负责执行具体任务，比如Qoder智能体协作
- 管道协作（Pipeline）：agent按顺序接力
- 对等协作（Peer-To-Peer）：多个agent相互审查

## 自主决策和任务分解

Plan-Act-Observe-Reflect循环：规划->行动->观察->反思

## 任务分配原则

MECE（Mutually Exclusive, Collectively Exclusive）：任务之间完全独立

将大项目拆解成多个独立的小任务再交给AI

# 规范驱动开发

SDD（Specification-Driven Development）

## 产品需求文档

PRD（Product Requirements Document）：描述要做什么

### 用户故事格式

User Story

1. 作为一个（角色）
2. 我希望（功能）
3. 以便（目的）

### 验收标准

Acceptance Criteria

1. Given（前提条件）
2. When（操作）
3. Then（预期结果）

## 技术规范

SPEC（Technical Specification）

| 模块 | 内容 | 说明 |
| :--- | :--- | :--- |
| 系统架构 | 整体架构设计图 | 前后端如何交互 |
| 技术选型 | 使用什么技术和框架 | 比如 Next.js + Prisma + SQLite |
| 数据模型 | 数据库表结构设计 | 有哪些表、每个表有哪些字段 |
| API接口 | 接口定义 | 每个API的URL、请求参数、返回格式 |
| 目录结构 | 项目文件组织 | 代码放在哪个文件夹 |

# harness工具

## Claude Code

### 常用命令

- `/model`：切换模型
- `/help`：查看帮助
- `/status`：查看配置和使用情况
- `/init`：创建项目级CLAUDE.md，一般在项目有一定规模的基础上使用
- `/compact`：压缩上下文
- `/clear`：清空当前会话
- `/context`：详细查看上下文占比
- `/memory`：自动记忆
- `/cost`：

### 七层扩展

1. **CLAUDE.md**：项目说明书，每次会话自动加载
2. **Hooks**：事件触发器，在特定时机自动执行
3. **Skills**：专业知识包，AI 按需加载
4. **Plugins**：把 Skills + Hooks + MCP 打包分发
5. **LSP**：给 AI 装上 IDE 级的代码导航
6. **MCP**：连接外部工具和数据源
7. **子 Agent**：独立上下文并行干活

前三层是基础配置，后四层是高级扩展

### 配置文件

优先级：
1. `项目/.claude/settings.local.json`：当前项目，个人私有，不提交git（.gitignore）
2. `项目/.claude/settings.json`：当前项目，团队共享，提交git
3. `~/claude/settings.json`：全局

在**全局**配置模型：

```json title:"deepseek"
"env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<使用的API>",
    "ANTHROPIC_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_EFFORT_LEVEL": "max"
  },
```

在**项目**配置操作权限（实际使用不能带注释）：

```Cpp
{
  // 允许 Claude Code 执行的操作（不再需要每次确认）
  "permissions": {
   "allow": [
     "Read",        // 读取文件
     "Write",       // 写入文件
     "Bash(npm *)",   // 执行 npm 命令
     "Bash(git *)",   // 执行 git 命令
     "Bash(node *)"   // 执行 node 命令
   ],
   "deny": [
     "Bash(rm -rf *)" // 禁止执行危险的删除命令
   ]
  },
  // 自动紧凑阈值（上下文使用超过此比例时自动压缩）
  "autoCompactThreshold": 80    //百分比
}
```

### 模型切换

- 启动时指定：`claude --model 模型(opus|sonnet|haiku|"具体其他模型名")`
- 运行中切换：`\model [模型]`
- 配置文件settings.json中：`"model": "模型"`

### 三层记忆体系

#### CLAUDE.md

CLAUDE.md有三层优先级，会同时生效，不冲突：

1. 全局级：`~/.claude/CLAUDE.md`，个人习惯，身份，偏好
2. 项目级：`项目根目录/CLAUDE.md`，技术栈，架构，规范，进度
3. 文件级：`子目录/CLAUDE.md`，专属约定

```markdown title:"项目"
# 项目名称
项目名

## 项目概述
一句话描述这个项目做什么。

## 技术栈
- 前端：Next.js 14 + TypeScript + Tailwind CSS
- 后端：Next.js API Routes
- 数据库：Prisma + SQLite
- 部署：Vercel

## 项目结构
​```
src/
├── app/         # Next.js App Router 页面
│   ├── api/      # API 路由
│   ├── layout.tsx # 全局布局
│   └── page.tsx   # 首页
├── components/   # React 组件
│   ├── ui/      # 通用UI组件
│   └── features/  # 业务组件
├── lib/         # 工具函数和配置
├── prisma/      # 数据库 schema 和迁移
└── types/       # TypeScript 类型定义
​```

## 编码规范
- 使用函数式组件 + React Hooks
- 组件文件使用 PascalCase 命名（如 BookmarkCard.tsx）
- 工具函数使用 camelCase 命名
- API 路由返回统一格式：{ success: boolean, data?: any, error?: string }
- 所有数据库操作通过 Prisma Client 执行

## 当前开发状态
-  项目初始化完成
-  数据库 Schema 设计完成
-  书签 CRUD API 开发中
-  前端页面待开发
-  搜索功能待开发

## 注意事项
- SQLite 数据库文件在 prisma/dev.db，不要提交到 Git
- 环境变量在 .env 文件中，不要提交到 Git
- 所有新功能先创建 Git 分支再开发
```

```markdown title:"全局"
# 沟通方式

- 默认中文回复；代码、命令、变量名、文件路径保持英文
- 结论先行，简洁直接，不先铺垫背景
- 不谄媚，不夸"这是个很好的问题"，不以"当然可以"开头
- 给真实判断——方案有问题直接指出，发现更好做法主动说明

# Git

- 不自动 git commit 或 git push，除非我明确要求
- 提交前先展示将要提交的变更摘要
- commit message 使用简洁英文

# 红线操作

以下操作即使在 auto-accept 模式下也必须先问我：

- 删除文件、目录或 git 历史
- 修改 .env、密钥、token、证书、CI/CD 配置
- git push、git rebase、git reset --hard、强制推送
- 公开发布（npm publish、生产部署等）

```

#### Auto Memory

命令`/memory`

Auto Memory是Claude Code在执行任务过程中记下的设计笔记

记录的信息：

1. `user`：用户的角色，偏好
2. `feedback`：用户给过的反馈
3. `project`：项目相关
4. `reference`：外部资源索引

CLAUDE.md是第一优先级，明确的规则，Auto Memory是第二优先级，隐式规则

#### 专项参考文档

为避免大量文本都写在CLAUDE.md文件，在CLAUDE.md中加上外部的md文件的索引：

```markdown
## 外部参考文档

- 修改前端视觉、调颜色、调间距时 → 必读 `docs/brand-visual.md`
- 写产品文案、按钮文字、提示语时 → 必读 `docs/copywriting-style.md`
- 写 API 、定义返回格式时 → 必读 `docs/api-conventions.md`
```

Claude Code在需要时再查外部文档

#### .claudeignore文件

类似于`.gitignore`文件，指定不需要关注的目录或文件