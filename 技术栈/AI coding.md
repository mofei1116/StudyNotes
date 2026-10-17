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

# Vibe Coding

1. 意图优先：描述效果
2. 快读迭代：生成->测试->修正