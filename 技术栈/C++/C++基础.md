# 变量

## 基本内置类型

- bool：布尔
- char：字符
- int：整型
- float：单精度浮点
- double：双精度浮点
- void：无类型
- wchar_t：宽字符，相当于`typedef short int wchar_t`
- auto ：自动类型推断
- decltype：获取表达式类型，比如`decltype(x) y=10;`

## 结构体

C++11中的结构体可以在定义时初始化
```Cpp
struct person{
	string name="mofei";
	int age=18;
	int score=100;
};
```

## 基本修饰符

- signed：有符号（默认）
- unsigned：无符号
- short：短整形
- long：长整形
- const：常量，C++中的常量不可用指针修改

## 类型别名

- typedef：`typedef pair<int,int> PII;`
	给数组起别名：`typedef int C[10];`，使用：`C a;   //int a[10];`
- using ：`using PII=pair<int,int>;`

## 数据类型转换

### 自动类型转换

低精度往高精度转换

### 强制类型转换

`double a=1.2;`

- `int b=(int)a;   //C方式`
- `int b=int(a);`
- `const_cast<type> (expr)`：增加或去除expr的const属性，expr源类型必须与type类型相同
- `reinterpret_cast<type> (expr)`：将一种类型的指针转换为其他类型的指针

## 引用

### 本质

> 引用本质是一个指针常量，编译器帮助简化了指针操作，编译器不为引用分配地址

`int a=10;`

```Cpp title:"引用"
int& b=a;
b+=10;
cout<<b<<endl;
```

```Cpp title:"指针常量"
int* const p=&a;
(*p)+=10;
cout<<*p<<endl;
```

### 使用

引用需在定义时初始化（不能指向空值），且值不可改变，引用最多为一级

函数中：
- 作为函数参数
- 作为函数返回值，注意不能返回栈区数据的引用

常量引用：
`const int& b=a;`，不可通过常量引用修改值

# 流程控制

## 随机数

### rand函数

> 头文件cstdlib

`int rand(void)`产生伪随机数，返回值在0到`RAND_MAX`（定义在cstdlib里面）之间，默认种子是1

### srand函数

> 头文件cstdlib

`void srand(unsigned seed)`设置随机数种子

利用time函数（头文件ctime）设置随机数种子：

`srand((unsigned)time(NULL));`

# 函数

## 参数

### 可变参数

#### 边长参数列表

> C风格
> 头文件`<cstdarg>`

- `va_list`，参数指针
- `void va_start(va_list argptr,last_arg)`，用最后一个**固定**参数初始化参数指针
- `type va_arg(va_list argptr,type)`，访问参数列表中下一个参数，type是下一个参数的类型
- `va_end(va_list artptr)`，结束参数列表的访问

```Cpp title:"求和函数"
int getSum(int num,...){    //num表示可变参数个数，是固定参数
	va_list valist;
	va_start(valist,num);
	int sum=0;
	for(int i=1;i<=num;i++){
		sum+=va_arg(valist,int);
	}
	va_end(valist);
	return sum;
}
```

- `int vsprintf(char *restrict str,const char *restrict format, va_list ap);`：通过边长参数列表写入字符串

### 默认参数

在定义时给参数一个默认值，若调用函数时没有给这个参数传值，则这个参数的值就是默认值；声明写了默认参数，定义就不要写默认参数了

`void funct(int a,int b=10);`

## 内联函数

> 相当于宏替换，省略了函数调用的时间开销，只适合函数体简单的函数

`inline returnType funct(pareType p){}`，inline关键字必须放在函数**定义**前面

## 函数重载

> 编译器会根据参数列表对函数重载进行重命名，本质上仍是不同的函数

- 共用相同函数名
- 参数列表不完全相同（个数，类型，顺序）
- 返回值可以相同可以不同

# 指针

## 万能指针

> 万能指针`void*`

1. 万能指针可以指向任意类型的变量
2. 不能直接通过万能指针**取值**，需要强转成需要取值的数据类型的指针再取值
3. 任何数据类型的指针都可以赋值给万能指针

## NULL指针和nullptr指针

> 一般定义一个指针需要初始化为`NULL`或`nullptr`，防止出现野指针


`#define NULL ((void *)0)`，将数值0强转为无类型指针（万能指针），在C++11摒弃了其定义

- `NULL`本质是一个宏定义，在C++中退化成数值0，在C++11舍弃
- `nullptr`本质上是一个关键字，特指空指针，只能赋值给指针类型

# 动态内存

> 相较于malloc，new可以在创建对象时传参

使用`new`关键字分配内存，使用`delete`关键字回收内存

```Cpp
int* p=new int;
if(p){
	delete p;
	p=nullptr;
}
```

```Cpp title:"分配数组"
int* a=new int[10];
if(a){
	delete[] a;
	a=nullptr;
}
int* b=new int[3]{1,2,3};
if(b){
	delete b;
	b=nullptr;
}
```

# 作用域和多文件

## 存储类

| 存储类 | 关键字      | 生存期 | 作用域 | 描述                  |
|:---:|:--------:|:---:|:---:|:-------------------:|
| 自动  | auto     | 函数  | 局部  | 默认，C++11后改为自动类型推导                  |
| 静态  | static   | 程序  | 局部  | 只初始化一次              |
| 可变  | mutable  | 类   | 局部  | 成员可在const对象中修改      |
| 外部  | extern   | 程序  | 全局  | 多文件共享               |
| 寄存器 | register | 函数  | 局部  | 将变量直接存在寄存器中，C++11废除 |

## 命名空间

> 编译器会在变量名前加上命名空间前缀

### 定义

```Cpp
namespace mySpace{
	int a;
	void funct1(int x){    //声明时定义
		std::cout<<x<<std::endl;
	}
	void funct2(int x);
}

void mySpace::funct2(int x){    //先声明再定义
	std::cout<<x+10<<std::endl;
}
```

### 使用

- `using namespace mySpace;`
- `using namespace mySpace::a;`
- `mySpace::a`，访问`mySpace`中的`a`
- `::a`，访问无名空间中的`a`

## 多文件

### 防止重复包含

- 宏定义：
	```Cpp
	#ifndef _HEAD_AA
	#define _HEAD_AA
	void funct();   //写声明
	#endif
	```
- `#pragma once`
- `_Pragma("once")`

注意头文件内声明类，源文件写实现要加作用域

# 预处理

> 以`#`开头

1. 文件包含：
	`#include`
2. 宏定义：
	1. `#define`，定义宏
	2. `#define(x)`，条件定义
	3. `#undef`，取消宏定义
3. 条件编译：
	1. `#if`，判断条件是否为真
	2. `#else`
	3. `#elif`，else if
	4. `#ifdef`，如果定义了宏
	5. `#ifndef`，如果没有定义宏
	6. `#endif`，结束if
	7. `#error compile false`，终止编译并打印`compile false`

## 可变参数宏

`...`和`__VA_ARGS__`搭配使用

`#define myprint(...) printf(__VA_ARGS__)`或`#define myprint(format,...) printf(format,__VA_ARGS__)`

## 编译器扩展宏

- `__PRETTY_FUNCTION__`：输出类名和函数名
- `__LINE__`：输出代码所在行数

# 面向对象

> 面向对象比面向过程更易维护，易扩展，易复用，但是性能比面向过程低

面向对象三大特征：封装，继承，多态

## 定义

> 定义类使用`class`关键字

```Cpp
class Student{
public:
	string name;
	int age;
	int score;
	void printName(){
		cout<<this->name<<endl;
	}
};
```

## 构造函数

> 实例化：使用类创建类对象
> 默认构造函数是空实现

- `类名(参数){函数体}`
- 空间分配方式：
	1. 在程序开始前分配在静态区
	2. 分配在栈区
	3. 手动分配在堆区

`explicit`在构造函数前修饰表示只能显示调用

### 初始化列表

- 传参：`Person(string n,int a):name(a),age(a){}`
- 不传参：`Person():name("mofei"),age(18){}`

### 拷贝构造函数

```Cpp
Student a("mofei",18,100);
Student b(a);    //拷贝构造
Student c=a;     //拷贝构造
```

- 只有一个同类的参数，可以是常量（const）也可以不是，一般传引用
- **默认**的拷贝构造函数一般是逐个字节复制
- 有堆区的成员变量需要**深拷贝**

## 析构函数

> 默认析构函数是空实现

- 用以释放空间，关闭文件等
- 没有返回值，没有参数，不能显式调用，不能重载，在销毁对象前自动执行
- `~类名(){函数体}`

## 成员

> 成员包括成员变量和成员函数

### 静态成员

> 在定义前加static关键字

- 静态成员在声明后必须在类外初始化
- 类的静态成员由所有类对象共有，可以更新，可以使用**类名**或**对象名**访问：`cout<<Person::country<<" "<<a.country<<endl;`
- 静态成员函数只能访问静态成员变量，静态成员函数没有`this`指针

### 常量成员

- 常量成员变量定义时必须用**初始化列表**或直接赋值（`const int x=0;`）初始化
- 常函数不能修改对象中的值，用`const`修饰：`void funct()const{}`

### this指针

指向当前对象的指针常量

### 访问权限

#### 访问限定符

> 默认是private

- `public`：可以被该类中的成员函数，子类的成员函数，友元函数，类对象访问
- `protected`：不能被类对象访问
- `private`：只能由类中的成员函数，友元函数访问

#### 友元

> 用`friend`关键字在声明前修饰

- 友元可以访问类的所有成员
- 类内声明，类外实现

##### 友元函数

将全局函数声明为友元，友元函数可以访问其私有和保护成员

```Cpp
class Person{
private:
	int age;
public:
	friend void print(Person& a);    //声明
}
void print(Person& a){    //实现
	cout<<a.age<<endl;
}
```

##### 友元类

将另一个类声明为友元，友元类中的成员函数就可以访问其私有和保护成员

## 运算符重载

> 本质上是函数重载

- `返回值 operator重载符号(参数){函数体}`
- 可以用类成员函数实现也可以在全局实现，用全局函数实现可以声明成友元

### +

```Cpp
class Person{
public:
	int a,b;
	//成员函数实现
	Person operator+(const Person& p){
		Person temp;
		temp.a=this->a+p.a;
		temp.b=this->b+p.b;
	}
};
```

若在全局实现，需要定义`Person operator+(const Person& p1,const Person& p2){函数体}`，相当于`p1+p2`

### <<

用全局函数实现：
```Cpp
//相当于cout<<p
ostream& operator<<(ostream& cout, Person& p) {    //cout可以任意取名
	cout<<p.a<<" "<<p.b;
	return cout;    //ostream对象只能有一个，所以返回引用
}
```

### ++

```Cpp
class Person{
public:
	int a;
	//前置++
	Person& operator++(){
		this->a++;
		return *this;
	}
	//后置++
	Person operator++(int){    //int是占位参数，区分前置和后置
		Person temp=*this;
		this->a++;
		return temp;
	}
};
```

### =

若类中有堆中的数据，赋值前要先把原来的堆区数据释放了

```Cpp
class Person{
public:
	int a;
	Person& operator=(const Person& p){
		this->a=p.a;
		return *this;
	}
};
```

### ==

```Cpp
class Person{
public:
	int a,b;
	bool operator==(const Person& p){
		if(this->a==p.a&&this->b==p.b)return true;
		else return false;
	}
};
```

### ()

函数调用运算符`()`实现**仿函数**，仿函数是一个**类**

定义一个仿函数作为容器的排序规则需要加`const`关键字

### \[]

```Cpp
#define M 10

class Person{
public:
	int a[M];
	int operator[](int i){
		if(i>=M)return -1;
		return a[i];
	}
};
```

## 继承

- `class 派生类:继承方式 基类{}`

### 继承方式

默认是private，任何继承方式都不能继承父类中的private成员
1. public：子类继承的成员的访问权限与父类相同
2. protected：子类继承的成员的访问权限为protected
3. private：子类继承的成员的访问权限为private

### 继承的构造和析构

- 子类实例化时优先调用父类的构造函数再调用子类的构造函数，没有父类的默认构造函数编译失败，可以使用参数列表的方式初始化父类：`父类(父类构造需要的参数)`
- 先调用子类的析构函数再调用父类的析构函数

### 多继承

> 一个子类有多个父类

- `class 类名:继承方式1 父1,继承方式2 父2,...{}`
- 父类构造函数的调用顺序和子类声明时的顺序一样
- 同名的父类成员需要加作用域区分

```Cpp
class Person{
public:
	int a;
	void func();    //同名
	Person(int x):a(x){}
};
class Teanager{
public:
	int b;
	void func();    //同名
	Teanager(int x):b(x){}
};
class Student:public Person,public Teanager{
public:
	int c;
	Student(int x,int y,int z):Person(x),Teanager(y),c(z){}
	void f(){
		Person::funct();    //作用域解析运算符区分
	}
};
```

#### 菱形继承

> 两个派生类继承同一个基类，又有某个类同时继承者两个派生类

菱形继承造成的问题是子类继承了爷爷类两份相同的数据

解决冲突：**虚继承**，使用virtual关键字：`class B:virtual pulbic A`
两个父类虚继承爷爷类能解决子类的冲突

在虚继承中，爷爷类（虚基类）最终是由孙子类（最终的派生类）初始化的

## 多态

1. 编译时多态：函数重载
2. 运行时多态：继承，虚函数

实现运行时多态条件：
1. 存在继承关系
2. 父类和子类有同名的虚函数，子类重写父类的虚函数
3. 存在父类指针或引用，通过该指针或引用调用虚函数

```Cpp
class A{
public:
	virtual void print(){
		cout<<"world"<<endl;
	}
};
class B:public A{
	void print(){
		cout<<"hello"<<endl;
	}
};
class C:public A{
	void print(){
		cout<<"fuck"<<endl;
	}
};

int main(){
	//这里省略了内存回收
	A* a=nullptr;
	a=new B;
	a->print();    //打印hello
	a=new C;
	a->print();    //打印fuck
	a=new A;
	a->print();    //打印world
}
```


### 虚函数

实现虚函数：在函数前面加virtual关键字，子类的重写的虚函数可以不加，在函数后加上override关键字

构造函数不能声明为虚函数，析构函数可以声明为虚函数，开发中一般把基类中的析构函数声明为虚函数

#### 虚构析构

> 为了避免内存泄漏

若有父类指针指向一个子类对象，通过父类指针释放子类对象时，只会调用父类的析构函数，不会调用子类的析构函数，可能造成子类堆区的属性内存泄漏；将父类的析构函数声明为虚函数，释放子类对象时，先调用子类的虚构函数，再调用父类的虚构函数

#### 虚函数表

> 虚函数由虚函数表实现

- 类包含虚函数表vtable，对象包含虚函数指针vpointer
- 派生类的虚函数表兼容基类的虚函数表
- 虚函数表储存每个虚函数的地址
- 实例化对象时初始化vptr，指向类的虚函数表

#### 抽象类&纯虚函数

> 抽象类只作为派生类的接口，不能实例化

在类中加入**纯虚函数**，使其成为**抽象类**

纯虚函数：`virtual 返回值 函数名(参数)=0;`

若子类不重写父类中的纯虚函数，则子类也是抽象类

## 嵌套类

```Cpp
class A{    //外围类
	class B{}    //嵌套类
}
```

1. 嵌套类不能访问外围类的任何成员
2. 外围类可以通过对象访问嵌套类的公有成员，不能访问保护和私有成员
3. 嵌套类只能由外围类使用（需要加外围类的作用域）

## 局部类

1. 定义在函数体中，作用域是局部的
2. 成员函数必须定义在类体中
3. 不能有静态成员函数

# 异常处理

> C++中的异常处理是指处理**运行时**的错误
> 所有异常都派生自`std::exception`类

`exception`中的标准异常构成父子类层次

## 抛出异常

> 用`throw`关键字抛出异常

- 抛出异常程序仍然无法正常结束，需要捕获异常
- `throw`语句的操作数表达式结果的类型决定抛出异常的类型

```Cpp
int test01(int a,int b){  
   if( b == 0 )  
   {  
      throw "Division by zero";    //抛出const char*类型的异常
   }  
   return (a/b);  
}
```

## 捕获异常

> 用`try`和`catch`关键字

- `try`语句块后可以跟多个`catch`语句块
- `ExceptionName`即抛出的异常的类型，可以是标准异常类型
- 用`...`代替`ExceptionName e`的`catch`块可以从处理`try`块抛出的任何类型异常

```Cpp
try{
	//保护代码，即可能出现异常的代码
}
catch(ExceptionName e){    //类型为ExceptionName的异常e
	std::cout<<"error"<<std::endl;
}
/*    打印抛出的异常（抛出的异常是const char*类型）
catch(const char* msg){
	std::cout<<msg<<std::endl;
}
*/
```

## 自定义异常

```Cpp title:"自定义异常类"
class MyException: public exception {  //继承exception类
public:  
	//改写what方法
	//what是exception类中的公共方法，返回异常原因
    const char* what() const throw(){
	    return "MyException";
    }
};
```

```Cpp title:"抛出异常"
int test01(int a,int b){  
   if(b==0){  
       MyException myex;  
       throw myex;  
   }  
   return (a/b);  
}
```

```Cpp title:"捕获异常"
    try {  
        cout<<test01(10, 0)<<endl;  
    }  
    catch(exception& e){  
        cout<<e.what()<<endl;  
    }
```

# 模板

> 模板提高代码复用性

模板中编译器一般不会进行类型转换

模板化代码实现不应该放在`.cpp`文件中

## 函数模板

```Cpp
//typename关键字可以换成class
template<typename T1,typename T2,typename T3>
函数声明或定义
```

1. 利用函数模板参数显式实例化函数模板：`myFunct<int>(a);`，显式实例化可以进行类型转换
2. 普通函数比函数模板优先级高
3. 可以用空模板参数`<>`强行调用函数模板
4. 具体化的函数模板以`template<>`开头，给出具体的实现，本质上是函数重载

## 类模板

```Cpp
//typename关键字可以换成class
template<typename T1,typename T2,typename T3>
类声明或定义
```

1. 类模板必须**显示**实例化，即给出类模板参数
2. 类成员函数在类外定义需要在前面加上`template<class T>`模板参数列表

### 模板别名

```Cpp
template<typename T>
class Myclass{
	//类的声明
}

typedef Myclass<int> t1;    //实例化：t1 a;
using t2=Myclass<T>    //实例化：t2<int> a;
```

# STL类

STL包含容器，迭代器，算法

## 迭代器

- `begin()`：获取起始迭代器
- `end()`：获取末尾迭代器，末尾迭代器指向空
- `rbegin()`：获取从右开始的迭代器，`rend()`同理
- `cbegin()`：获取const的起始迭代器，`crbegin()`同理

## string

- `string s`读入整行：`getline(cin,s)`
- 成员函数`c_str()`将`string`转化为C风格的字符串

### 构造

- `string s;`，空字符串
- `string s(const char* src);`，用字符数组
- `string s(cosnt string& src);`，用string类
- `string s(const string& src,int start=0,int len=string::npos)`，用`src`从`start`开始长度为`len`的子串
- `string s(const int n,const char c);`，填n个c
- `string s="mofei"`，直接初始化

### 赋值

#### =赋值

- `string& operator=(const char* src);`，用字符数组
- `string& operator=(const string& src);`，用string类
- `strng& operator=(const char c);`，用单个字符

#### assign赋值

> 比=更灵活

- `string& assign(const char *src);`，用字符数组
- `string& assign(const char *src, int n);`，用字符数组的前n个字符
- `string& assign(const string& src);`，用string类
- `string& assign(cosnt string& src,int n);`，用stirng类的前n个字符
- `string assign(const int n,const char c);`，用n个c字符

### 拼接

#### +=拼接

- `string& operator+=(const char* src);`，拼接字符数组
- `string& operator+=(const string& src);`，拼接string类
- `string& operator+=(const char c);`，拼接单个字符

#### append拼接

> 比+=更灵活

- `string& append(const char* src);`，拼接字符数组
- `string& append(const string& src);`，拼接string类
- `string& append(const char* src,int start,int n=string::npos);`，从字符数组下标start开始拼接n个
- `string& append(const string& src,int start,int n=string::npos);`，从string类下标start开始拼接n个

### find查找

> find函数，从左往右，没找到返回`string::npos`

- `int find(const char* s, int start=0, int n=npos) const;`，从下标start开始查找第一个`s`的前n个字符的子串
- `int find(const string& s, int start=0, int n=npos) const;`，从下标start开始查找第一个`s`的前n个字符的子串
- `int find(const char c, int start=0) const;`，从下标start开始查找第一个`c`

rfind函数于find函数类似，只是从右往左查找

### replace替换

> replace 函数

- `string& replace(int start,int len, const string& str);`，从下标start开始的len个字符替换为`str`
- `string& replace(int start,int len,const char* s);`，下标start开始的len个字符替换为`s`
- `string& replace(int start,int len,int n,const char c)`，下标start开始的len个字符替换为n个c字符

### 访问

#### \[ ]访问

- `cout<<s[3]<<endl;`，直接通过下标访问

#### at访问

- `s.at(3)='x';`，将下标传给at函数

### insert插入

- `string& insert(int start, const char* s);`，在下标start插入`s`
- `string& insert(int start, const string& str);`，在下标start插入`str`
- `string& insert(int start, int n, cosnt char c);`，在下标start插入n个c字符

### erase删除

- `string& erase(iterator beg,iterator end);`
- `string& erase(iterator posi);`

### substr子串

- `string& substr(int start=0,int len=string::npos);`，返回从下标start开始长度为len的子串

## vector

`deque`类与`vector`相似，`deque`可以在头部插入和删除

注意：`vector`在扩张过程中，内部维护的数组的首地址可能会改变，所以不要用指针指向`vector`中的元素

### 构造

- `vector<int> a;`，提供模板参数
- `vector a(vector::iterator begin,vector::iterator end)`，用迭代器
- `vector a(int n,int val)`，用n个val
- `vector a(const vector& src)`，用vector
- `vector<int> a(int capa)`，指定容量

### 赋值

#### =赋值

- `vector& operator=(const vector& src);`，用vector

#### assign赋值

- `assign(vector::interator begin,vector::interator end)`，用迭代器
- `assign(int n,int val)`，用n个val

### 容量&大小

- `empty()`，判空
- `capacity()`，容器容量
- `size()`，大小，即元素个数
- `resize(int new_size,int val=0)`，重新分配大小，不够的部分用val填充，容量不变
- `reserve(int capa)`，指定容量，预留空间，避免频繁动态扩展容量


### 插入

- `push_back()`
- `insert(start,int val)`，在start插入一个val
- `insert(start,int n,int val)`，在start插入n个val

### 删除

- `pop_back()`
- `erase(iterator posi)`
- `erase(iterator beg,iterator end)`
- `clear()`，全部删除

### 访问

- `[]`
- `at(int posi)`，传下标
- `front()`，只能取
- `back()`，只能取

### 交换

- `swap(const vector& src)`
- 收缩内存：`vector<int>(v).swap(v)`，`vector<int>(v)`是用v初始化的匿名对象，容量只有`v.size()`

## stack

- `push(val)`，入栈
- `pop()`，出栈
- `top()`，取栈顶
- `empty()`，判空
- `size()`，大小

## queue

- `push(val)`，入队
- `pop()`，出队
- `front()`，取队首
- `back()`，取队尾
- `empty()`，判空
- `size()`，大小

### priority_queue

`priority_queue<T,c,cmp> q`

- `T`：优先队列的数据类型
- `c`：底层容器，默认是vector
- `cmp`：自定义二元谓词比较函数，`priority_queue`默认是最大堆，要实现最小堆可以用内建的函数对象`greater<T>`

若`T`为`pair<int,int>`类型，`cmp`可以使用`greater<pair<int,int>>`，比较的是`first`

## list

基本操作与`deque`类似

- `remove(val)`，删除容器中所有val
- `back()`，`front()`，只能访问链首和链尾，迭代器只能++或--
- `reverse()`，反转
- `sort()`，排序

## pair

构建：
- `pair<type1,type2> p(val1,val2);`
- `pair<type1,type2> p=make_pair(val1,val2);`

`tuple`于`pair`类似，`tuple`成员不一定是两个

## set

> 底层用红黑树实现，默认升序排序

`set`不能有重复元素，`multiset`可以有重复元素

- `insert(val)`，插入，返回`pair<set<int>::iterator,bool>`表示插入结果
- `erase(val)`，删除val
- `erase(set::iterator beg,set::iterator end)`，从beg删到end
- `erase(set::iterator posi)`，删除posi位置的元素，返回下个元素的迭代器
- `find(val)`，查找
- `count(val)`，计数

用仿函数实现自定义排序规则

对于自定义类型，必须自定义排序规则

`set<int,myCompare> s;`，`myCompare`是二元谓词

## map

> 底层用红黑树实现，默认升序排序 

`map`中每个元素都是一个类，由键`key`（first），值`val`（second）组成

`map`不能有重复元素，`multimap`可以有重复元素

- `insert({key,val})`，插入，返回`pair<set<int>::interator,bool>`表示插入结果
- `myMap[key]=val`，插入
- `erase(key)`，删除key对应的元素
- `erase(map::iterator beg,map::iterator end)`，从beg删到end
- `erase(map::iterator posi)`，删除posi位置的元素，返回下个元素的迭代器
- `find(key)`，查找
- `count(key)`，计数

通过迭代器访问键值：`first()`访问键，`second()`访问值

自定义排序规则与`set`类似

## 内建函数对象

> 函数对象即仿函数

算数，关系，逻辑等内建函数对象

### 关系仿函数

常用：
- `template<class T> bool equal_to<T>` ，等于
- `template<class T> bool not_equal_to<T>` ，不等于
- `template<class T> bool greater<T>` ，大于
- `template<class T> bool greater_equal<T>` ，大于等于
- `template<class T> bool less<T>` ，小于
- `template<class T> bool less_equal<T>` ，小于等于

## 常用算法

  
算法主要是由头文件`<algorithm>` `<functional>` `<numeric>`组成

### 遍历

- `for_each(iterator start,iterator end,funct);`，`funct`是函数或仿函数

### 搬运

- `transform(iterator src_start,iterator src_end,iterator des_start,funct)`

funct是仿函数，比如：
`int funct(int val){return val+10;}`


### 查找

- `find(iterator beg,iterator end,val)`，返回迭代器
- `find_if(iterator beg,iterator end,funct)`，按条件查找，`funct`是函数或谓词
- `adjacent_find(iterator beg, iterator end)`，查找相邻重复元素，返回第一个元素的迭代器
- `binary_search(iterator beg,iterator end,int val)`，在有序序列中二分查找，返回bool类型

### 计数

- `count(iterator beg, iterator end,val)`，计数
- `count_if(iterator beg, iterator end,funct)`，按条件计数，`funct`是函数或谓词

### 排序

> 底层实现包含快排，堆排，插入排序

`sort(iterator beg, iterator end,funct)`，`funct`是函数或谓词

### 洗牌

- `random_shuffle(iterator beg, iterator end)`

### 合并

> 将两个**有序**容器合并到另一个容器中

- `merge(iterator beg1, iterator end1, iterator beg2, iterator end2, iterator dest_beg)`

目标容器需要提前开辟空间

### 反转

- `reverse(iterator beg, iterator end)`

### 拷贝

- `copy(iterator beg,iterator end,iterator dest_beg)`

目标容器需要提前开辟空间

### 替换

- `replace(iterator beg,iterator end,oldval,newval)`，将beg到end范围内的oldval替换为newval
- `replace_if(iterator beg,iterator end,funct,newval)`，按条件替换，funct为函数或谓词

### 交换

- `swap(c1,c2)`，交换两个容器c1和c2

### 算数生成算法

> `<numeric>`头文件，属于小型算法

#### 求和

- `accumulate(iterator beg,iterator end,val)`，求beg到end的和，val是起始值

#### 填充

- `fill(iterator beg,iterator end,val)`，会覆盖原来的值

需要提前开辟空间

### 集合算法

> 两个容器需要**有序**，目标容器需要提前开辟空间

返回目标容器的最后一个元素的迭代器

#### 交集

- `set_intersection(iterator beg1, iterator end1, iterator beg2, iterator end2,iterator dest_beg)`

#### 并集

- `set_union(iterator beg1, iterator end1, iterator beg2, iterator end2, iterator dest_beg)`

#### 差集

- `set_difference(iterator beg1, iterator end1, iterator beg2, iterator end2, iterator dest_beg)`

# 文件操作

## 流

- 数据流：有序，有起点和终点的字节的数据，包括输入流和输出流
- C++通过流进行输入输出，流是面向对象的，包含控制台流，文件流，字符串流

### 控制台流

输入流`istream`，输出流`ostream`，由输入流和输出流派生出输入输出流`iostream`

- `cin`，标准输入的`istream`类对象
- `cout`，标准输出的`ostream`类对象
- `cerr`，标准错误的`ostream`类对象

### 文件流

1. `ifstream`，派生于`istream`，管理文件输入
2. `ofstream`，派生于`ofstream`，管理文件输出
3. `fstream`，派生于`iostream`，管理文件输入输出

### 字符串流

> 头文件`<sstream>`

控制字符串类型对象进行输入输出，支持C风格字符串流

1. `istringstream`，派生于`istream`，管理字符串输入
2. `ostringstream`，派生于`ofstream`，管理字符串输出
3. `stringstream`，派生于`iostream`，管理字符串输入输出

通过字符串构造字符串流：
有`string s`

1. 声明时初始化：`istringstream istr(s)`
2. `str(string s)`成员函数：`istr.str(s)`

`istr.str()`返回字符串流对应的字符串

多次使用字符串流对象需要用`clear()`成员函数清空

## 文件处理

> 头文件`<fstream>`和`iostream`，处理的文件分为文本文件和二进制文件

### 打开文件

> 使用成员函数`open`

- `open(const char* fileName,ios::openmode mode)`，打开的文件名和路径，打开模式
- 使用多种打开模式用`|`隔开
- `is_open()`判断是否打开成功

| 打开方式    | 作用                       |
| ----------- | -------------------------- |
| `ios::in`     | 打开以读         |
| `ios::out`    | 打开以写         |
| `ios::ate`    | 定位到文件尾           |
| `ios::app`    | 追加方式写文件             |
| `ios::trunc`  | 如果文件存在先删除再创建 |
| `ios::binary` | 二进制方式                 |

默认打开模式：
1. `ofstream`：`ios::out|ios::trunc`
2. `ifstream`：`ios::in`
3. `fstream`：`ios::in|ios::out`

### 读写

- 使用`<<`写到`ofstream`或`fstream`对象，`>>`从`ifstream`或`fstream`对象读

```Cpp title:"写入"
void test01(){
	ofstream ofs;
	ofs.open("./myfile.txt");    //默认打开模式是ios::out|ios::trunc
	ofs<<"i love mofei"<<endl;
	ofs.close();
}
```

```Cpp title:"读取"
void test02(){
	ifstream ifs;
	ifs.open("./myfile.txt");    //默认打开方式是ios::in
	string s;
	ifs>>s;
	cout<<s<<endl;
	ifs.close();
}
```

#### 读写方式

1. 使用`get`成员函数
	```Cpp
	char ch;
	while(!ifs.eof()){    //eof()判定是否到文件末尾
		ifs.get(ch);
		cout<<ch;
	}
	```
2. 使用`getline`函数（`<string>`头文件）
	```Cpp
	string s;
	while(getline(ifs,s)){
		cout<<s<<endl;
	}
	```
3. 使用`getline`成员函数
	```Cpp
	char s[100]={0};
	while(ifs.getline(s,sizeof(s))){
		cout<<s<<endl;
	}
	```
4. 使用`>>`
	```Cpp
	string s;
	while(ifs>>s){
		cout<<s<<endl;
	}
	```

#### 二进制文件读写

> 二进制文件可以用于存储类等数据

##### 写入

- `write(const char* s,int size)`，要读入的数据`s`，读入数据的大小

```Cpp title:"写入"
class MyClass;

void test02(){
	Myclass a;
	ofstream bof;
	bof.open("./myfile.txt",ios::out|ios::binary);
	bof.write((const char*)& a,sizeof(a));
}
```

##### 读取

- `read(char* dest,int size)`，目标容器，要读取的字节数

```Cpp
class MyClass;

void test01(){
	MyClass a;
	ifstream bif;
	bif.open("./myfile.txt",ios::in|ios::binary);
	bif.read((char*)&a,sizeof(a));
	cout<<a.x<<endl;
	bif.close();
}
```

### 关闭文件

> 使用`close`成员函数

C++程序结束时会自动关闭刷新所有流

### 文件偏移&文件大小

基准：`ios::beg`文件开头，`ios::end`文件结尾，`ios::cur`当前位置

- 偏移读位置`seekg(-2,ios::end)`，从文件结尾开始向左偏移2个字节
- 偏移写位置`seekp(3,ios::beg)`，从文件开头向右偏移3个字节
- 返回读位置`tellg()`
- 返回写位置`tellp()`

```Cpp title:"获取文件大小"
void test01(){
	int start,end;
	ifstream ifs;
	ifs.open("./file.txt",ios::in);
	start=ifs.tellg();
	ifs.seekg(0,ios::end);
	end=ifs.tellg();
	cout<<end-start<<endl;    //文件字节大小
	ifs.close();
}
```

# 新特性

## C++11

### atomic

对原子类型的数据的操作有原子性，防止多线程的竞态

- 定义一个原子类型：`std::atomic<数据类型> value{初始值};`
- 赋值`store(值)`
- 取值`load()`

### auto

> 自动类型推导，推导变量的类型

1. 类型不为引用时，`auto`推导不保留`const`
2. 类型为引用时，`auto`推导保留`const`
3. `auto`可以推导出半个类型

限制：
1. 不能在函数参数中使用，C++14可以作为函数返回值
2. 不能作为非静态成员变量
3. 不能作为模板参数
4. 不能用于推导数组类型

### decltype

> 推导表达式的类型

可以应用于模板参数

C++中返回值是前置语法，`decltype`用于返回值：`auto funct(参数)->decltype(表达式);`，C++14可以直接用`auto`作为返回值

### 右值引用&&

- 左值：可以取地址，一般在等号左边  
- 右值：不可以取地址，只能在等号右边
- 右值引用：某个右值的别名

### 移动语义

> 移动语义将资源直接从一个对象转移到另一个对象，减少额外的开销

自定义类实现移动语义需要**移动构造函数**

```Cpp
MyClass::MyClass(MyClass&& a){    //拷贝数据
	this->num=a.num;
	this->p=a.p;    //转移堆区的地址
	//必须重置a的成员变量，防止a析构时把堆区数据释放了
	a.num=0;
	a.p=nullptr;
}
```

- `std::move`：把左值转变为右值

### 基于范围的迭代

`for(auto p:a){}`，`a`是容器

### Lambda表达式

> 本质上是匿名函数

- `[捕获列表](参数列表)->返回类型{函数体}`，返回类型可以省略
- 在参数列表后面加`mutable`取消`const`属性
- 用Lambda表达式构造：`auto funct02(funct01);`
- Lambda表达式可以赋值给同类型的函数指针
- Lambda表达式的使用方式和仿函数类似

#### 捕获列表

- `[&]`：按引用的方式捕获**所有**外部变量
- `[=]`：按拷贝的方式捕获**所有**外部变量
- `[this]`：捕获当前对象
- `[*this]`：捕获当前对象的的副本，C++17
- `[a,&b]`：按拷贝的方式捕获变量a，按引用的方式捕获变量b，按拷贝的方式捕获的变量在函数体内不可作左值，加`mutable`就可以作左值
	```Cpp
	int a=10;
	auto fun01=[=]()mutable->int{a=a+1;return a;};
	cout<<fun01()<<endl;    //输出11
	cout<<a<<endl;    //输出10
	```
- 捕获列表可以是Lambda表达式
	```Cpp
	auto fun01=[]{};
	auto fun02=[fun01]{cout<<"hello"<<endl;};
	```

### 智能指针

> 避免内存泄漏，头文件`<memory>`，由类模板实现

自动回收内存，不用手动`delete`回收

#### shared_ptr

多个`shared_ptr`指针共用一块内存，使用引用计数机制，计数为0自动释放内存，空指针不计数

- 成员函数`use_count()`返回计数

##### 构建

- `shared_ptr<int> p(new int(5));`，`new`分配
- `shared_ptr<int> p=make_shared<int>(5);`，`make_shared`成员函数
- `shared_ptr<int> p(p1);`，拷贝构造
- `shared_ptr<int> p(move(p1))`，移动构造

##### 释放

需要在构造时时定释放规则

- `shared_ptr<int> p(new int,default_delete<int>());`，使用默认释放规则，默认释放规则不能释放数组
- `shared_ptr<int> p(new int[3],funct)`，`funct`为自定义释放规则函数

#### unique_ptr

每个`unique_ptr`指针不共享内存

#### weak_ptr

`weak_ptr`不会增加引用计数

`shared_ptr`引用计数会造成循环计数问题，用`weak_ptr`解决

```Cpp
class B;
class A{
public:
	//造成循环引用问题就把其中一个类的成员属性换成weak_ptr
	shared_ptr<B> _ptr_B;
	//weak_ptr<B> _ptr_B;
};

class B{
public:
	shared_ptr<A> _ptr_A;
};
```

### 可变参数模板

```Cpp
template<class...T>
void funct(T...args){//T是包类型，args是包形参
	cout<<sizeof...(args)<<endl;  //参数包中参数个数
	cout<<sizeof...(T)<<endl;    //T类型参数的个数
}

static void test() {
	//会输出两个6
	funct01(1, 2, 3, 4, 5, 6);
}
```

#### 参数包展开

##### 递归展开

```Cpp
void funct01() {
	cout << "递归函数终止" << endl;
}

template<class T,class...L>
void funct01(T first, L...others) {
	cout << "参数：" << first << endl;
	funct01(others...);
}

static void test() {
	funct01(1, 2, 3, 4, 5, 6);
}
```

##### 编译期语句

> C++17

`constexpr()`表示常量或编译时求值

```Cpp
template<class T, class...L>
void funct01(T first, L...args) {
	cout << "参数：" << first << endl;
	if constexpr (sizeof...(args)) > 0) {
		funct01(args...);
	}
}

static void test() {
	funct01(1, 2, 3, 4, 5, 6);
}
```

### 默认成员函数控制

对于默认成员函数，若有显式定义，编译器有时会生成有时不会生成

- 使用`default`和`delete`关键字指定编译器是否要生成

```Cpp
class Myclass {
public:
	int n;
	//让编译器提供无参构造，若是delete就不提供
	Myclass() = default;
	Myclass(int x):n(x){}    //有参构造
	//让编译器不提供拷贝构造
	Myclass(const Myclass&) = delete;
	//让编译器提供=重载，若是delete就不提供
	Myclass& operator=(const Myclass& m) = default;
};
```

### 新增容器

#### array

> 于`vector`类似

- `array`保存在栈区中，`vector`保存在堆区
- 在编译时创建**固定**大小的数组，使用时指定类型和大小：`array<int,5> a;`
- 访问：`[]`，`at(int index)`成员函数，`get<index>(arr)`函数

#### forward_list

- `list`是双向链表，`forward_list`是单项链表，只能向前遍历，不提供`size()`成员函数

#### unordered系列

> 内部使用哈希实现

`unordered_set`，`unordered_multiset`，`unordered_map`，`unordered_multimap`

- 内部无序，不支持排序
- 插入和搜索时间复杂度为$O(1)$

## C++17

### 折叠表达式

> 为了方便模板编程

```Cpp
template<typename... Args>
bool all(Args... args) { return (... && args); }
bool b = all(true, true, true, false);
// 在 all() 中，一元左折叠展开成
// return ((true && true) && true) && false;
// b 是 false
```

### 类模板参数推导

```Cpp
template<class T>  
class Myclass {  
public:  
    T a, b;  
};  

void test01() {  
    Myclass c = {100, 200};    //自动推导T为int
}
```

### auto占位的非类型模板形参

```Cpp
#include <iostream>
using namespace std;
template <auto T>
void func1() {
	cout << T << endl;
}

void test() {
	func1<100>();
	return 0;
}
```

### constexpr

- `constexpr()`表示常量或编译时求值

```Cpp
template <bool ok>
constexpr void func2() {
	//在编译期进行判断，if和else语句不生成代码
	if constexpr (ok == true) {
		//当ok为true时，下面的else块不生成汇编代码
		cout << "ok" << endl;
	}
	else {
		//当ok为false时，上面的if块不生成汇编代码
		cout << "not ok" << endl;
	}
}
```

### inline变量

> 扩展了`inline`用法

- 在变量定义声明前加`inline`关键字，使得可以在头文件或类内初始化**静态成员变量**

### 结构化绑定

```Cpp
auto student=make_tuple("mofei",18,"man");  
auto [name,age,gender] =student;      //结构化绑定
cout<<name<<" "<<age<<" "<<gender;
```

### if switch初始化

```Cpp
unordered_map<string, int> m{ {"zhangsan", 18}, {"wangwu", 19} };
// C++11
auto it = m.find("wangwu");
if (it != m.end()) {
	cout << it->second << endl;
}
// C++17
if (auto it = m.find("wangwu"); it != m.end()) {
	cout << it->second << endl;
}
```

### 嵌套的命名空间

```Cpp
// C++17之前
namespace A {
	namespace B {
		namespace C {
			void func1() {}
		}
	}
}
// C++17
namespace A::B::C {
	void func1() {}
}
```

### Lambda表达式捕获\*this

- 捕获`this`时，若对象的生命周期比Lambda表达式的生命周期短，会造成未定义行为
- 捕获`*this`，本质上是捕获对象的副本，只读不写

### __has_include

> 预处理指令，检测当前环境下是否存在某个头文件

```Cpp
#if __has_include(<iostream>)
	cout<<"has <iostream>"<<endl;
#endif
```

### 新增属性

#### \[\[nodiscard]]

- 修饰的内容不能被忽略，主要用于修饰函数返回值

`[[nodiscard]] auto funct(int a,int b){return a+b;}`，若调用处没有获取返回值编译器会给警告

#### \[\[maybe_unused]]

用于描述暂时没有被使用的函数或变量，避免编译器给警告


### charconv

- `chars_format`类，格式控制
- `from_chars`类，由字符串转为其他类型
- `to_chars`类，其他类型转为字符串类型

### variant

> 类似于`union`，存放复合类型

- `variant<int,char,string> a;`，`int`的下标为0，`char`的下标为1，`string`的下标为2
- `index()`成员函数，返回当前类型的下标
- `holds_alternative<int>(a)`，成员函数，查询对象`a`当前的类型是否为`int`，返回布尔值

### optional

> 模板类，存在有值和无值两种状态，`nullopt`表示无值，类似指针，不同版本有改动

```Cpp title:"构造"
optional<int> o1;   //默认为nullptr
optional<int> o2 = nullopt;    //无值
optional<int> o3 = 10;    //有值
optional<int> o4 = o3;
```
 
- 查看一个`option`对象是否有值，直接用`if`或用`has_value()`成员函数
- 取值，用`*`或`->`或`value()`成员函数
- 有值变为无值：`reset()`成员函数，会将对象析构

### any

> 类似于`auto`，但可以随时改变类型

```Cpp title:"构造"
any a=1;
any b=make_any<double>(1.2);
any c(10);
```

- `has_value()`，判空
- `type().name()`，得到类型名
- `emplace<int>(5)`，重新赋值
- `reset`，清空

### apply

> 将`pair`或`tuple`解包，作为参数传入函数中

```Cpp
void test01(){  
    auto add=[](int a,int b){return a+b;};  
    pair<int,int> p(2,3);  
    cout<<apply(add,p)<<endl;      //使用apply解包
}
```

### make_from_tuple

> 将`tuple`解包，作为构造函数参数构造对象

```Cpp
class MyClass;    //省略实现
MyClass::MyClass(int x,double y,string s);

void test01(){
	tuple<int,double,string> a(18,1.2,"mofei");
	make_from_tuple<MyClass>(move(a));
}
```

### stirng_view

> 相当于由`char*`构造的`string`，不会新开辟空间，只读不写

- 构造：`string_view str_v(const char*,int len)`

### as_const

> 将左值转为`const`

- `string a="mofei";`，转为`const`：`const string b=as_const(a);`

### filesystem

> 文件系统，方便处理文件
> 头文件`<filesystem>`，命名空间`std::filesystem`

常用类：
- `path`类，路径处理
- `directory_entry`类，文件入口
- `directory_iterator`类，获取文件的迭代容器
- `file_status`类，获取和修改文件属性

常用函数：
1. `exist(const path& p)`，判断是否存在
2. `copy(const path& src,const path& dest)`，复制
3. `absolute(const path& p,const path& base=current_path())`，获取基于`base`的绝对路径
4. `create_directory(const path& p)`，目录不存在时创建目录
5. `file_size(const path& p)`，返回目录大小

## C++20

