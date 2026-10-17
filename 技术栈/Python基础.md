python既是交互式语言，也是脚本式语言

# 基础语法

单行注释以`#`开头，多行注释可以利用`"""多行注释"""`

多行语句使用`\`

同一行中使用多条语句，语句之间用`;`分割

多变量同时赋值：`a,b,c=1,5.2,"mofei"`

`print()`输出，`print(a,end=" ")`，输出不换行

`import 模块`导入模块，`from 模块 import 函数`，导入模块中的函数

命令行参数：`python -h`查看参数帮助

# 基本数据类型

- `type(a)`：查询变量所指对象的类型，不会认为子类是一种父类类型
- `isinstance(a,int)`：判断变量所指对象的类型，会认为子类是一种父类类型
- `del a`：删除对象引用

## Number

支持int，float，bool，complex（复数）

## bool

bool是int的子类

- Ture：1
- False：0
- None，0，0.0，0j，空序列（string,list,tuple），空映射：False

## String

`'字符串'`,`"字符串"`,`"""可跨行字符串"""`

相当于特殊的元组

截取：`变量[头下标:尾下标:偏移量]`，不包括尾下标

### Byte类型

`b"hello"`：表示的是数值而不是字符串

### f-string

`f"Hello{变量或表达式}"`

## List

`[列表]`

截取：`变量[头下标:尾下标:偏移量]`，不包括尾下标

元素类型可以不同，元素可变（可变类型）

- `append()`：追加元素
- `del 列表[元素]`：删除元素
- `operator.eq()`：列表比较，需要引入`operator`模块

## Tuple

`(元组)`

截取：`变量[头下标:尾下标:偏移量]`，不包括尾下标

元素类型可以不同，元素不可变

- `()`：空元组
- `(10,)`：只有一个元素的元组

## Set

`{集合}`

无序，元素不重复，元素必须可哈希

- `set()`创建空集合
- `set(可迭代对象)`：从可迭代对象创建集合
- `add()`：添加元素
- `update()`：添加多个元素
- `remove()`：移除元素，不存在抛异常
- `discard()`：移除元素，不存在不抛异常
- `pop()`：移除并返回元素，不存在抛异常
- `clear()`

`frozenset`：不可变集合

## Dictionary

`{key-value集合}`，`key:value`

字典保持插入顺序

key使用不可变类型，唯一

从键值对序列构造字典：`dict([('Runoob', 1), ('Google', 2), ('Taobao', 3)])`

- `{}`：空字典
- 通过`字典[键]`访问值
- `del 字典[键]`：删除键值

## 类型转换

### 强制类型转换

- `int()`
- `float()`
- `str()`
- `ord()`：字符串转为byte类型

# 推导式

- 字典推导式：`{键:值 for 变量 in 序列 if 条件}`
- 列表推导式：`[表达式 for 变量 in 序列 if 条件]`
- 集合推导式：`{表达式 for 变量 in 序列 if 条件}`
- 元组推导式：`(表达式 for 变量 in 序列 if 条件)`

# 运算符

## 算数运算符

- `/`：返回浮点数
- `//`：返回整数
- `**`：幂运算

## 逻辑运算符

- `and`
- `or`
- `not`

## 成员运算符

- `in`
- `not in`


## 集合运算符

- `|`：并集
- `&`：交集
- `-`：差集
- `^`：对称差集

# 流程控制

pass：相当于`{}`空语句

## if

if，elif，else，pass（相当于`{}`空语句）

```python
if condition_1:
    statement_block_1
elif condition_2:
    statement_block_2
else:
    statement_block_3
```

## match-case

相当于switch-case

```python
match subject:
    case <pattern_1>:
        <action_1>
    case <pattern_2>:
        <action_2>
    case <pattern_3>:
        <action_3>
    case _:    # 相当于default
        <action_wildcard>
```

## while

```python
while 条件 :
	语句
[else : 语句]
```

## for

```python
for 变量 in 可迭代对象 :
	语句
[else : 语句]
```

## range()

生成数列，作为一个可迭代对象

`range(5)`：生成从0到4的数列

# 函数

```python
def 函数名(参数列表):
	函数体
	[return 返回值]
```