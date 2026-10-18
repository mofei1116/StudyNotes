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

- 领导者-执行者模式（Leader-Worker）:一个agent负责拆分任务和协调，多个agent负责执行具体任务，比如Qoder
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

