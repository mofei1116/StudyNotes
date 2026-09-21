> IO，即输入输出，程序和外部设备进行信息交换

# IO模型

- 阻塞IO：在调用的函数返回之前什么也不做，不断检查函数是否返回
- 非阻塞IO：每隔一段时间检查IO事件是否就绪，调用的函数总是立即返回，对于`accept`,`recv`,`send`函数，事件未就绪时，`errno`被设置成`EAGAIN`或`EWOULDBLOCK`
- 信号驱动IO：给信号设置处理方式，接收到信号后处理IO事件
- IO复用：同时阻塞多个IO操作
- 异步IO：内核把数据拷贝到缓冲区后再通知应用

同步IO通知的是就绪事件，需要用户代码自行执行IO操作
异步IO通知的是完成事件，由内核完成IO操作

# 标准IO

> 系统提供的库函数实现，提供了缓冲区，先把数据放在缓冲区，再一次性系统调用（文件IO），把数据刷入内核空间
> `<stdio.h>`头文件（standard buffer input/output）：标准**缓冲**输入

## 标准IO的缓冲区

- 行缓存：和终端文件相关的缓冲区，大小为1024字节，对应文件指针`stdin`，`stdout`
- 全缓存：和外部文件相关的缓冲区，大小为4096字节，对应文件指针`fp`
- 不缓存：大小为0字节，对应文件指针`stderr`

缓冲区在第一次使用之前不会分配空间，大小为0

输出行缓存区大小：
```C
printf("size of line buffer:%d\n",stdout->_IO_buf_end - stdout->_IO_buf_base);
```

### 缓存刷新时机

#### 行缓存

1. 程序结束
2. 遇到换行'\n'
	%% - 终端读入时，遇到换行符'\n'就刷新缓冲区，但'\n'还留在缓冲区
	- 终端输出时，遇到换行符'\n'就刷新缓冲区，且'\n'也一起刷到内核 %%
3. 输入输出发生切换
	```C
	printf("hello");
	scanf("%d");    //发生了输入切换到输出，刷新缓冲区，输出hello
	```
4. 关闭文件指针
	```C
	//注意stdout在程序开始时默认打开
	printf("hello");
	fclose(stdout);    //fclose会调用fflush
	```
5. 通过fflush函数手动刷新缓冲区（头文件stdio.h）
	`int fflush(FILE *stream);`
6. 行缓存区满（行缓冲区大小是1024字节）
	```C
	for(int i=0;i<1025;i++){
		fputc('a',stdout);
	}
	while(true);
	```

#### 全缓存

1. 程序结束
2. 输入输出发生切换
	```C
	fputc('a',fp);
	char ch=fgetc(fp);
	```
3. 关闭文件指针
4. 通过fflush函数手动刷新缓冲区
5. 全缓冲区满（全缓冲区大小是4086字节）
	```C
	for (int i = 0;i < 4097;i++) {
		fputc('a', fp);
	}
	while (true);
	```

**注意**：遇到换行符'\n'不会刷新全缓冲区

#### 不缓存

放入数据立即刷新

```C
fputc('a', stderr);
while (true);
```

## FILE结构体

> FILE结构体包含关于文件的信息

```C
struct FILE{    //有省略
	char *_io_buf_base;    //缓冲区起始地址
	char *_io_buf_end;    //缓冲区终止地址
	int _fileno;    //文件描述符，用于系统调用
}
```

三个特殊的FILE指针：都是针对终端文件
- `stderr`：标准出错指针
- `stdin`：标准输入指针
- `stdout`：标准输出指针
- 三个指针在程序启动时系统默认打开，都是关于终端的文件指针

## 标准IO接口

### 错误码

> 内核提供的函数出错后，内核空间会向用户空间反馈一个错误信息，每个错误信息对应一个错误码（>0）

- 错误码`errno`全局变量定义在`errno.h`头文件中
	- `EINTR`：被中断的系统调用
	- `EAGAIN`,`EWOULDBLOCK`：资源暂时不可用
- `char *strerror(int errnum);`：
	把错误码转化成错误信息字符串
	- 头文件：`<string.h>`
- `void perror(const char *s);`：
	直接打印错误信息先打印提示信息和`:`，末尾自动换行，使用的是stderr缓冲区
	- 头文件：`<stdio.h>`
	- 参数：提示信息

### fopen&fclose

- `FILE *fopen(const char *path, const char *mode);`
	- 头文件：`<stdio.h>`
	- 参数：
		- 要打开的文件名
		- 打开模式（注意打开模式是字符串）
			- `r`:打开以读，==文件必须存在==，文件不存在就返回NULL，存在就返回文件指针，指针定位在开头
			- `w`:打开以写，==文件存在就清空文件==，不存在就创建，指针定位在开头
			- `a`:打开以追加，返回文件文本末尾的指针，不存在就创建，==不能修改原有内容==，指针定位在末尾
			- 需要可读可写就在后面加`+`，比如`a+`，`wb+`
			- 以二进制方式打开就加`b`，比如`ab`，`wb`，`rb`
	- 返回值：成功返回文件指针，错误返回`NULL`并置位错误码
- `int fclose(FILE *stream);`
	- 头文件：`<stdio.h>`
	- 参数：文件指针
	- 返回值：成功返回0，失败返回`EOF`并置位错误码

### fget&fput

- `int fgetc(FILE *stream);`
	- 头文件：`<stdio.h>`
	- 参数：文件指针
	- 返回值：成功返回读取的字符的ASC码（无符号整形转int），失败返回`EOF`
	- 每读取一次，文件指针向后偏移
- `int fputc(int c, FILE *stream);`
	- 头文件：`<stdio.h>`
	- 参数：
		- 输出的字符对应的ASC码
		- 文件指针
	- 返回值：成功返回输出的字符对应的ASC码，失败返回`EOF`
	- 每写入一次，文件指针向后偏移
- `char *fgets(char *s, int size, FILE *stream);`
	- 头文件：`<stdio.h>`
	- 参数：
		- 用于接受读取的容器起始地址
		- 最多读size-1个字符
		- 文件指针
	- 返回值：成功返回容器的起始地址，失败返回NULL
	- 末尾自动添加'\0'，遇到'\n'或EOF停止读入，会把'\n'读进去
- `int fputs(const char *s, FILE *stream);`
	- 头文件：`<stdio.h>`
	- 参数：
		- 要写入的字符串
		- 文件指针
	- 返回值：成功返回写入的字符的个数，失败返回`EOF`

### 文件流格式化读写

- `int fprintf(FILE *stream, const char *format, ...);`：格式化输出
	- 头文件`<stdio.h>`
	- 参数：
		- 文件指针
		- 格式化字符串
		- 输出项列表（对应格式化字符串中的格式控制符）
	- 返回值：成功返回写入的字符个数，失败返回一个负数
- `int fscanf(FILE *stream, const char *format, ...);`：格式化输入
	- 头文件`<stdio.h>`
	- 参数：
		- 文件指针
		- 格式化字符串
		- 读入项列表地址（对应格式化字符串中的格式控制符）
	- 返回值：成功返回读入的项数，失败返回`EOF`并置位错误码 
	- 遇到空格或换行符'\n'停止读入，'\n'会留在缓冲区

### 字符串格式化转化

- `int sprintf(char *str, const char *format, ...);`
	- 头文件`<stdio.h>`
	- 参数：
		- 容器字符数组的起始地址
		- 格式化字符串
		- 可选参数
	- 返回值：转换成功返回字符个数，失败返回`EOF`
	- 若容器小了可能会越界访问
- `int snprintf(char *str, size_t size, const char *format, ...);`：
	比`sprintf`更安全
	- 头文件`<stdio.h>`
	- 参数：
		- 容器字符数组的起始地址
		- 最多转换size-1个字符（末尾会添加'\0'）
		- 格式化字符串
		- 可选参数
	- 返回值：转换成功返回字符个数，失败返回`EOF`

### 模块化读写

- `size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);`
	- 头文件：`<stdio.h>`
	-  参数：
		- 存数据的容器首地址
		- 读取的每项数据的大小
		- 要读取的数据项数
		- 文件指针
	-  返回值：成功返回读取到的数据项数，失败也返回读取到的数据项数（小于numemb）
- `size_t fwrite(const void *ptr, size_t size, size_t nmemb,FILE *stream);`
	- 头文件：`<stdio.h>`
	- 参数：
		- 存数据的容器首地址
		- 写入的每项数据大小
		- 要写入的数据项数
		- 文件指针
	- 返回值：成功返回写入的数据项数，失败也返回写入的数据项数（小于numemb）

```Cpp title:"模块化读写类"
#include <iostream>
#include <stdio.h>
#include <string>

using namespace std;

class Stu {
public:
    char name[20];
    //string name;
    int age;
    double score;
};

int main(int argc, char* argv[]) {
    FILE* fp = NULL;
    Stu s[3] = {
        {"mofei",16,100.0},
        {"ohu",18,90.0},
        {"kaguya",20,95.0}
    };

    if ((fp = fopen("hello.txt", "w")) == NULL) {
        perror("fopen error");
        return -1;
    }
    fwrite(s, sizeof(s[0]), sizeof(s) / sizeof(s[0]), fp);
    fclose(fp);

    Stu temp;
    if ((fp = fopen("hello.txt", "r")) == NULL) {
        perror("fopen error");
        return -1;
    }
    fread(&temp, sizeof(Stu), 1, fp);
    printf("%s %d %.2f\n", temp.name, temp.age, temp.score);
    fclose(fp);

    return 0;

}
```

### 文件光标

- `int fseek(FILE *stream, long offset, int whence);`：偏移文件指针
	- 参数：
		- 文件指针
		- 偏移量，从指定位置开始偏移，正为右，负为左
		- 起始位置
			- `SEEK_SET`：文件开头
			- `SEEK_CUR`：文件指针当前位置
			- `SEEK_END`：文件末尾
	- 返回值：成功返回0，失败返回-1并置位错误码
- `long ftell(FILE *stream);`：返回当前指针位置
	- 参数：
		- 文件指针
	- 返回值：成功返回相较于文件开头偏移量，失败返回-1并置位错误码
- `void rewind(FILE *stream);`：文件光标定位到文件开头
	- 参数：
		- 文件指针
	- 相当于`fseek(fp,0,SEEK_SET)`

# 文件IO

> 基于系统调用（内核提供的函数），每次调用，进程从用户空间切换到内核空间，每次切换进程会**挂起**，效率较低（没有缓冲区）

## 文件描述符

- 一个无符号整数，用`open`函数打开文件时，会产生一个用于操作文件的句柄，即文件描述符
- 一个进程中能打开的文件描述符个数是有限的，一般是$1024$个，即$[0,1023]$
	- 限制大小通过`ulimit -a`查看
	- `ulimit -n 大小`：修改限制
- 文件描述符的使用是最小未分配原则
- 文件关闭后文件不再占用文件描述符
- 特殊的文件描述符：`0`，`1`，`2`，进程启动时默认打开
	- `0`：标准输入
	- `1`：标准输出
	- `2`：标准错误

利用控制函数`fcntl`设置文件描述符为非阻塞模式：
```Cpp
int flag=fcntl(fd,F_GETFL);    //获取旧的flag
flag|=O_NONBLOCK;    //添加非阻塞选项
fcntl(fd,F_SETFL,flag);
```

## 文件处理函数

- `int access(const char *pathname, int mode);`：判断当前进程对文件是否有权限或文件是否存在
	- 头文件：`<unistd.h>`
	- 参数：
		- 要被检测的文件
		- 检测模式：多个使用`|`隔开
			- `F_OK`：文件是否存在
			- `R_OK`：存在且可读
			- `W_OK`：存在且可写
			- `X_OK`：存在且可执行
	- 返回值：正确返回0，错误返回-1并置位错误码
- `int unlink(const char *path);`：删除指定的文件
	- 头文件：`<unistd.h>`
	- 参数：要删除的文件
	- 返回值：成功返回0，失败返回-1并置位错误码
- `int stat(const char *pathname, struct stat *statbuf);`：获取文件状态，文件不存在返回-1
	- 头文件：
		- `<sys/types.h>`
		- `<sys/stat.h>`
		- `<unistd.h>`
	- 参数：
		- 要获取状态的文件
		- 用于存放状态信息的结构体的地址
			- `st_mode`
				- `S_IROTH`：可读
				- 函数`S_ISDIR(st_mode)`：判断是否为目录
			- `st_size`：文件大小
	- 返回值：成功返回0，失败返回值-1并置位错误码
- `void* mmap(void* start,size_t length,int prot,int flags,int fd,off_t offset)`：将文件或其他对象映射到虚拟内存上，提高文件访问速度
	- 参数：
		- 映射区起始地址，0表示由系统决定
		- 映射区的长度
		- 期望的内存保护标志，不能与文件的打开模式冲突
			- `PROT_READ`：表示页内容可以被读取
		- 指定映射对象的类型，映射选项和映射页是否可以共享
			- `MAP_PRIVATE`：建立一个写入时拷贝的私有映射，内存区域的写入不会影响到原文件
			- 有效的文件描述符，一般是由`open`函数返回
			- 偏移量
- `int munmap(void start, size_t length);`：取消映射
	- 参数：
		- 映射区起始地址，即`mmap`得到的地址
		- 映射区大小


## 文件IO接口

### open&close

- `int open(const char *pathname, int flags);`
- `int open(const char *pathname, int flags, mode_t mode);`
	- 头文件：
		- `<sys/types.h>`
		- `<sys/stat.h>`
		- `<fcntl.h>`
	- 参数：
		- 要打开的文件
		- 打开模式：多个模式用`|`相连
			- `O_RDONLY`只读，`O_WRONLY`只写，`O_RDWR`可读可写，三者必须选一个
			- `O_CREAT`：用于创建文件，文件不存在则创建文件，文件存在则打开文件，如果flag中包含了该模式，则函数的第三个参数必须要加上
			- `O_APPEND`：以追加的形式打开文件，光标定位在结尾
			- `O_TRUNC`：清空文件
			- `O_EXCL`：常跟`O_CREAT`一起使用，确保本次要创建一个新文件，如果文件已经存在，则open函数报错
			- 标准IO中的打开模式：
				- `w`：`O_WRONLY|O_CREAT|O_TRUNC`
				- `w+`：`O_RDWR|O_CREAT|O_TRUNC`
				- `r`：`O_RDONLY`
				- `r+`：`O_RDWR`
				- `a`：`O_WRONLY|O_APPEND|O_CREAT`
				- `a+`：`O_RDER|O_APPEND|O_CREAT`
		- 创建新文件的权限：参数`flag`中有`O_CREAT`时必须给出`mode`参数
			- 若没给`mode`参数，所得新文件的权限为随机值
			- 最终新文件的权限为`mode&(~umask)`
				- `umask`：查看当前终端的`umask`，一般默认为`0022`
				- `umask 数字`：设置当前终端的`umask`
			- 最高权限为`0777`
			- 普通文件的权限一般为`0644`
			- 目录的权限一般为`0755`
	- 返回值：成功打开文件返回文件描述符，打开失败返回-1并置位错误码
- `int close(int fd);`：关闭文件描述符对应的文件
	- 头文件：`<unistd.h>`
	- 参数：文件描述符
	- 返回值：成功关闭文件返回文件描述符，关闭失败返回-1并置位错误码

### 读写

- `ssize_t read(int fildes, void *buf, size_t nbyte);`：文件指针会随读取往后偏移
	- 头文件：`<unistd.h>`
	- 参数：
		- 打开的文件对应的文件描述符
		- 容器的起始指针
		- 要写入的数据字节数
	- 返回值：读取成功返回读取到的数据字节数（$\leq nbyte$），失败返回-1并置位错误码
- `ssize_t write(int fildes, const void *buf, size_t nbyte);`
	- 头文件：`<unistd.h>`
	- 参数：
		- 打开的文件对应的文件描述符
		- 要写入的数据的起始地址
		- 要写入的数据的字节数
	- 返回值：成功返回写入的数据字节数（$\leq nbyte$），失败返回-1并置位错误码
- `ssize_t writev(int fd, const struct iovec *iov, int iovcnt);`：聚集写，将多块缓冲区的内容依次写入文件描述符
	- 参数：
		- 要写入的文件描述符
		- `iovec`结构体数组
			```Cpp
			struct iovec {
			   void   *iov_base;    //内存的起始地址
			   size_t  iov_len;    //缓冲区大小
			};
			```
		- 结构体的个数
	- 返回值：成功返回写入的字节数，失败返回-1并置位错误码

### 光标移动

- `off_t lseek(int fd, off_t offset, int whence);`：移动光标并返回光标所在位置
	- 头文件：
		- `<sys/types.h>`
		- `<unistd.h>`
	- 参数：
		- 打开的文件对应的文件描述符
		- 偏移量
		- 起始位置
			- `SEEK_SET`：文件开头
			- `SEEK_CUR`：文件指针当前位置
			- `SEEK_END`：文件末尾
	- 返回值：返回光标当前的位置

```Cpp title:"处理图像文件"
#include<myHead.h>

int main(int argc, const char *argv[])
{
	//以读写的形式打开文件
	int fd = -1;
	if((fd = open("./wukong.bmp", O_RDWR)) == -1)
	{
		perror("open error");
		return -1;
	}
	//获取文件的大小
	printf("文件大小为：%ld\n", lseek(fd, 0, SEEK_END)); //输出的就是文件大小
	//定义变量存储文件大小
	int pic_size = 0;
	lseek(fd, 2, SEEK_SET); //将文件从起始位置向后偏移两个字节，跳过文件类型
	read(fd, &pic_size, 4); //将文件头的 第3-6字节的内容读取出来
	printf("pic_size = %d\n", pic_size); //文件的大小
	//将文件光标向后偏移54字节，跳过文件头和信息头
	lseek(fd, 54, SEEK_SET);
	//定义一像素的颜色：颜色规律是蓝绿红
	unsigned char color[3] = {0, 0, 255}; //定义一个绿色
	for(int i=0; i<100; i++) //以像素为单位遍历行数,遍历前100行
	{
		for(int j=0; j<684; j++) //遍历所有列数
		{
			//此时的 (i,j) 定位的就是一个像素点，是一个三字节为单位的颜色点
			write(fd, color, sizeof(color)); //光标所在位置的像素点变成绿色
		}
	}
	//关闭文件
	close(fd);
	return 0;
}
```