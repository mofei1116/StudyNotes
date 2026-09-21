# 环境搭建

> gcc编译C程序，g++编译C++程序
> gdb调试工具，cmake构建工具

## 下载

```shell
sudo yum install gcc
sudo yum install gcc-c++
sudo yum install gdb
sudo yum install cmake
```

## 查看版本

```shell
gcc -v
g++ -v
gdb -v
cmake --version
```

## 卸载
```shell
sudo yum remove gcc
sudo yum remove gcc-c++
sudo yum remove gdb
sudo yum remove cmake
```

# 编译

## 一步到位

```shell
g++ -o build hello.cpp    //生成名为build的可执行文件
g++ hello.cpp    //默认生成名为a.out的可执行文件
```

## 分步编译

> ESc-->iso

- 预处理`g++ -E -o a.i hello.cpp`
- 编译`g++ -S -o a.s a.i`
- 汇编`g++ -c -o a.o a.s`
- 链接`g++ -o hello a.o`

## 联合编译

`g++ -o build main.cpp solve.cpp`：将`main.cpp`和`solve.cpp`源文件联合编译

# GDB

> 警告不影响可执行文件产生，警告可以忽略，错误不会产生可执行文件

## 常用指令

- `g++ -g -o build hello.cpp`：编译产生调试信息（必要）
- `gdb build`：进入gdb调试
- `q`/`quit`：退出gdb调试
- `run`：运行可执行程序，直到遇到断点
- `l`/`list`：展示程序相关信息，默认前十行，继续使用list会展示剩下的部分
	- `l 6,10`：展示从6到10行
	- `l funct`：展示funct函数周围
- `break 3`/`b 3`：在第3行设置断点
	- `break funct`：在funct函数内第一条语句设置断点
	- `info break`：查看断点信息
	- `delete breakpoint 1`：删除编号为1的断点
- `next`/`n`：执行下一条语句，若下一条语句是函数执行函数内所有语句
- `continue`/`c`：从当前语句执行到下一个断点或程序结束
- `step`/`s`：单步进入当前函数
- `print i`：打印变量`i`的内容
	- `print &i`：打印变量i的地址信息
- `set variable i=10`：设置变量`i`的值为10

## 使用技巧

- `shell 终端指令`：在gdb中执行shell指令
- `set logging on`：将日志内容保存到当前目录的`gdb.txt`文件
- `watch i`：为变量`i`添加监视，当`i`的值改变时显示旧值和新值
	- `watch 0x7fffffffe3bc`：为`0x7fffffffe3bc`地址添加监视

## 调试出错程序

- `gdb core_build_1793_1767752286`：查看程序`build`出错原因

### 不生成core文件

1. `demesg`：显示开机信息，查看是否转储core
2. core文件大小限制
	- `ulimit -a`：查看所有Linux限制内容
	- `ulimit -c unlimited`设置core文件大小为无限制
	- 添加`ulimit -c unlimited`到`/etc/profile`永久设置
3. 保存位置
	- `echo  "./core-%e-%p-%t" > /proc/sys/kernel/core_pattern`：临时设置保存路径为当前路径，`%e`可执行文件名，`%p`进程id，`%t`时间戳
	- 添加`kernel.core_pattern=./core-%e-%p-%t`到`/etc/sysctl.conf`并`sysctl -p`使配置生效，永久设置

## 调试运行中的进程

- `./build &`：后面加`&`使程序在后台运行，然后显示作业号和进程号
- `gdb -p 1754`：调试进程号为1754的进程
- `pidof build`：查看程序进程号
- `kill -9 1754`：强制杀死1754进程

# 库

> Linux下静态库为`.a`文件，动态库为`.so`文件
> Windows下静态库为`.lib`文件，动态库为`.dll`文件

库是二进制文件

## 静态库

> 编译时库和源文件一起生成可执行程序，每个可执行程序单独拥有一个静态库，体积大，效率高

1. 编译：
	`g++ -c -o add.o add.cpp`：编译源文件`add.cpp`为二进制文件`add.o`
2. 生成：
	`ar -crs libadd.a add.o`：将`add.o`编译生成静态库文件`libadd.a`，`ar`生成静态库，`-c`创建静态库，`-r`插入到库中或替换同名文件，`-s`重置静态库索引
3. 使用：
	`g++ main.cpp -L 库的路径 -l库名 -I 头文件路径 -o build01`：编译源文件时使用静态库
	- 比如：`g++ main.cpp -L . -ladd -I . -o build01`，库和头文件都在同目录下
	- 使用多个静态库：
		`g++ main.cpp -L . -ladd -I . -L . -lsub -I . -o build02`，使用了`libadd.a`和`libsub.a`
	- 多路径编译：
		`g++ main.cpp -L ../lib -ladd -I ../haead -o ../build03`

## 动态库

> 编译时库中相关函数的索引表和源文件一起生成可执行程序，每个可执行程序只有函数的索引表，体积小，效率低

1. 编译：
	`g++ -fPIC -c add.cpp -o add.o`：编译源文件`add.cpp`为二进制文件`add.o`
2. 生成：
	`g++ -shared add.o -o libadd.so`：生成动态库文件
	编译和生成合并：`g++ -fPIC -shared -o libadd.so add.cpp`
3. 使用：
	`g++ main.cpp -L 库的路径 -l库名 -I 头文件的路径 -o build`

### 动态库加载失败

> error while loading shared libraries: libadd.so: cannot open shared object file: No such file or directory

法一：把自己的库放到系统的库文件目录中`/lib64`或`/usr/lib64`
法二：设置全局变量
	`export LD_LIBRARY_PATH=库的路径`，比如设置路径为`./mylib`，要永久设置需要添加到`/etc/profile`（全局）或`~/.bashrc`（用户）

## 第三方库

> C/C++默认链接标准输入输出库，其他库需要手动链接
`-l库名`

`g++ main.cpp -lc -lm -lpthread -o build01`：`-lc`标准c库，`-lm`数学库，`-lpthread`线程库

# 头文件

1. 将多个头文件包含在一个头文件`myHead.h`中
2. 将`myHead.h`移动到`/usr/include`目录下
3. 源文件直接包含头文件`#include <myHead.h>`

# Makefile和CMake

## Makefile

> 名为`Makefile`的管理项目的文本文件，M一般大写，如果是小写系统默认执行小写的
> 相当于脚本

面向依赖：
`.exe`依赖于`.o`，`.o`依赖于`.s`，`.s`依赖于`.i`，`.i`依赖于`.cpp`

### 编写Makefile

```Makefile
build01:hello.o
	g++ hello.o -o hello

hello.o:hello.s
	g++ -c hello.s -o hello.o

hello.s:hello.i
	g++ -S hello.i -o hello.s

hello.i:hello.cpp
	g++ -E hello.cpp -o hello.i

clear:
	rm build01 hello.[^cpp]
```

简化：
```Makefile
build01:hello.o
	g++ -o build01 hello.o
	
hello.o:hello.cpp
	g++ -c -o hello.o hello.cpp
	
clear:
	rm build01 hello.[^cpp]
```

### 执行Makefile

- `make`：默认从第一个目标开始执行，直到解决所有依赖
- `make 目标`：从指定的目标开始执行，直到解决所有依赖

### 规则

> 构成依赖关系

```
目标:依赖
	命令
```

- 一个规则必须要有一个目标
- 可以没有依赖，只实现某种操作
- 可以没有命令，只描述依赖关系
	比如：`all:build01`


#### 目标

- 默认目标是第一个目标
- 一个规则可以有多个目标
- 一个目标可以间接拥有多个规则，比如：
	```Makefile
	all:test01
	all:test02
	test01:
		@echo "hello"
	test02:
		@echo "world"
	```
- 伪目标：相当于标签，没有依赖，无条件执行，不会生成文件，比如：
	```Makefile
	.PHONY:clear    #设置伪目标
		rm build01 hello.[^cpp]
	```

#### 依赖

- 文件时间戳：
	- 根据时间戳来判断依赖是否要进行更新
	- 所有文件都更改过，则对所有文件进行编译，生成可执行程序
	- 在上次make之后修改过的cpp文件，会被重新编译
	- 在上次make只写修改过的头文件，依赖该头文件的目标依赖也会重新编译
- 一个目标可以有多个依赖

#### 命令

- 以制表符开头的shell指令
- 每条命令开一个进程，命令执行完make会检查该命令的返回码，返回成功继续执行后面的命令，返回失败终止当前规则并退出
- 并发执行：
	- `make -j4`：开4个线程执行
	- `time make`：执行make时显示执行时间

#### 模式匹配

- `%`：Makfile规则通配符
- `$@`：目标
- `$^`：依赖
- `$<`：第一个依赖
- `*`：普通通配符

```Makefile
all:build01

build01:main.o add.o
    g++ -o $@ $^

%.o:%.cpp
    g++ -c -o $@ $^

clean:
    rm *.o build01
```

### 变量

> 相当于宏

- 变量定义：`变量名=值`
- `+=`：追加赋值
- `?=`：条件赋值，没有值就赋值，有值就不赋值
- 使用变量：`$(变量名)`或`${变量名}`
- `:=`：立即展开变量
- `=`：延迟展开变量，用最后的赋值展开
- 一般命令用延迟展开，目标和依赖用立即展开
- 命令行赋值：`make test AA="hello"`

```Makefile
var1?=main.o add.o

CC = g++

all:build01

build01:$(var1)
    $(CC) -o $@ $^

%.o:%.cpp
    $(CC) -c -o $@ $^

clean:
    rm *.o build01

test:
    @echo "----$(AA)----"
```

### 条件控制

```Makefile
var1?=main.o add.o

ifeq ($(COMPILE),g++)
    CC=g++
else
    CC=gcc
endif

all:build01

build01:$(var1)
    $(CC) -o $@ $^

%.o:%.cpp
    $(CC) -c -o $@ $^

clean:
    rm *.o build01
```

外部给`COMPILE`赋值：`make all COMPILE=g++`

## CMake

> CMake是跨平台构建工具，自动添加源文件到对应平台的构建工具

### 基本语法

- `指令(参数1 参数2...)`：参数之间用逗号或空格隔开，指令不分大小写
- 在if控制语句中变量取值不需要用`$()`
- 语句末尾没有分号

### 基本指令

- `cmake_minimum_required(VERSION 4.0)`：指定CMake最小版本支持为4.0版本
- `project(TEST CXX)`：定义项目名称为TEST并指定项目支持的语言为C++
- `set(SRC main.cpp add.cpp)`：设置变量SRC，值为`main.cpp add.cpp`，引用变量用`${SRC}`
- `add_executable(build ${SRC})`：依赖`${SRC}`生成`build`可执行文件
- `aux_source_directory(./src SRC)`：将源文件目录下的所有源文件添加到指定变量
- `includ_directories(./head)`：添加头文件路径，相当于`g++`中的`-I`选项
- `link_directories(./lib)`：添加库文件路径，相当于`g++`中的`-L`选项
- `add_library(add SHARED add.cpp)`：依赖`add.cpp`生成动态库
	- `add_library(add STATIC add.cpp)`：依赖`add.cpp`生成静态库
- `add_compile_options(-Wall -std=c++11)`：添加`-Wall`（显示所有警告）和`-std=c++11`（设置C++版本为11）编译选项
- `target_link_libraries(build add)`：添加`add`库到`build`程序中

### 基本变量

1. `CMAKE_C_FLAGS`：`gcc`编译选项的值
2. `CMAKE_CXX_FLAGS`：`g++`编译选项的值
	- `set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")`：在编译选项中追加`-std=c++11`选项
3. `CMAKE_BUILD_TYPE`：编译类型
	- `set(CMAKE_BUILD_TYPE Debug)`：设置编译类型为调试模式
	- `set(CMAKE_BUILD_TYPE Release)`：设置编译类型为发布模式
4. `CMAKE_CXX_STANDARD`：C++标准
	- `set(CMAKE_CXX_STANDARD 11) set(CMAKE_CXX_STANDARD_REQUIRED ON)`：设置C++11标准
5. `PROJECT_NAME`：项目名
6. `PROJECT_SOURCE_DIR`：项目资源目录
7. `EXECUTABLE_OUTPUT_PATH`：可执行文件的产生路径

### 构建项目

#### 内部构建

> 中间文件产生在项目主目录，杂乱

在项目主目录：
1. `cmake ./`：编译`CMakeLists.txt`，中间文件生成在项目主目录
2. `make`：编译项目主目录中的`Makefile`

#### 外部构建

在项目主目录：
1. `mkdir temp`：创建`./temp`目录用来存放临时文件
2. `cd ./temp`：进入`./temp`目录
3. `cmake ../`：编译项目主目录中的`CMakeLists.txt`，中间文件生成在`temp`目录
4. `make`：编译`temp`目录中的`Makefile`