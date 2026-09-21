> 七个基本函数：fopen(),fclose(),fflush(),fwrite(),fread(),fseek(),ftell()
> 头部依赖：<stdio.h>

>VS2022函数不安全报错处理：
>\#pragma warning(disable:4996)
>\#define _CRT_SECURE_NO_WARNINGS 1

# fopen()

两个参数：要打开的文件名，打开模式

**打开模式**：大部分情况只需三种

- `r`:打开以读，==文件必须存在==，文件不存在就返回NULL，存在就返回文件指针
- `w`:打开以写，==文件存在就清空文件==，不存在就创建
- `a`:打开以追加，返回文件文本末尾的指针，不存在就创建，==不能修改原有内容==
- 需要可读可写就在后面加`+`，比如`a+`，`wb+`
- 以二进制方式打开就加`b`，比如`ab`，`wb`，`rb`

 **注意：用r打开就只能用来读不能用来写，相对的，用w打开就只能用来写不能用来读，要可写可读就加`+`**

```C
char a[50] = { 0 };
char b[50] = { 0 };
FILE* fp = fopen("filetest", "wb");
fwrite("月色真美", 1, 8, fp);
fflush(NULL);
//fp = fopen("filetest", "rb");    //如果不写这行fread就无效
fseek(fp, 4, SEEK_SET);
fread(b, 1, 4, fp);
printf("%s\n", b);
fclose(fp);
```

- 打开一个文件以读写，文件存在就直接打开，文件不存在就创建

```C
FILE* myOpenfile(const char* filename){
	FILE *fp=fopen(filename,"r+");//试探文件是否存在
	if(!fp){
		if(errno==ENOENT){    //文件不存在，头文件errno.h
			fp=fopen(filename,"w+");
			if(!fp){
				perror("fopen");
				return NULL;
			}
		}
		else perror("fopen");    //打印错误日志
		return NULL;
	}
	printf("fopen success\n");
	return fp;
}
```

**将文件创建到指定目录的方式：**

首先在项目文件夹里面创建好待放入的文件夹，比如"users//"

用sprintf函数将文件名读到一个字符串里面用来当fopen的参数

```
char username[100]={0};    //注意要把字符数组初始化为0
scanf("%s",username);  
sprintf(filePath,".//users//%s",username);  
FILE *fp=fopen(filePath,"wb");
```

# fclose()

关闭文件流，刷新所有缓冲区（输入输出）

一个文件指针作为参数，指定要关闭的流

关闭成功返回0

# fflush()

刷新输出缓冲区（把某个字符串write到某个文件里面）

参数为一个文件指针

若为NULL，刷新所有流的输出缓冲区
若为某个文件指针，刷新该流的输出缓冲区

**如果不用fflush()，缓冲区满或关闭流才会被动flush**

# fwrite()

参数：一个字符串，元素大小（单位字节）（默认写1就行了），元素个数(**注意汉字是两个字节**)，文件指针

把字符串写到文件指针所指的位置

返回元素总数

**记得fflush()**

# fread()

参数返回值和fwrite()一样，相反是从文件读一段字符串到指定的字符串

# fseek()

参数：文件指针，偏移量（以字节为单位,正向右，负向左）**注意汉字是两个字节**，开始偏移的位置

开始的位置可以有三个值：SEEK_SET,SEEK_END,SEEK_CUR

# ftell()

参数：文件指针

返回值：该指针所指的位置到文件顶部的距离（单位字节）

可用于获取文件大小：

先将指针用fseek偏移到文件末尾，再用ftell获得整个文件的长度（单位字节）