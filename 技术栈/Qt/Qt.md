# Qt简介

Qt是一个C++图形用户界面应用程序框架

跨平台：
- 硬件平台：计算机，嵌入式设备，微控制器等设备
- 软件平台：Windows，Linux，MacOS，Android等操作系统

![[Pasted image 20260918084431.png | 跨平台]]

CLI（Command Line Interface）程序：命令行界面，顺序设计
GUI（Graphical User Ingerface）程序：事件等待，事件分发，事件处理

## 安装

windows下安装：

1. 下载在线安装器
2. 在在线安装器所在目录打开cmd
3. 带参数执行`.\qt-unified-windows-x86-online.exe --mirror https://mirrors.ustc.edu.cn/qtproject`，指定镜像源下载
4. 安装套件
5. 配置系统环境变量如`D:\Qt\6.5.3\mingw_64\bin`

需要配置cmake环境

Qt框架下开发的程序的可执行文件需要依赖Qt提供的库文件，若要直接运行可执行文件，需要配置环境变量

# Widget程序

![[Pasted image 20260918215257.png]]

## UI文件

1. 通过UI设计器设计UI界面，对应.ui文件
2. 通过.ui文件编译工具UIC将.ui文件转换成.cpp文件
3. 编译器将用户设计的cpp文件和ui文件转换后的cpp文件编译链接生成可执行文件

双击ui文件打开UI设计器

spacers弹簧可以实现居中效果

## 信号和槽

元对象系统MOC实现信号和槽

发送者（比如QPushButton）发送信号（比如clicked()）给接收者（比如QWidget），接收者执行槽函数（比如close()）

槽函数函数名的命名规范：`on_发送者的对象名_信号`，比如`on_bntCalcu_clicked()`

## qrc文件

qrc文件是资源文件

前缀是一个虚拟目录

qrc文件通过RCC子系统转换为cpp文件（包含资源的所有信息）再编译

## cmake

### 兼容Qt5的cmake

部分：

```cmake
cmake_minimum_required(VERSION 3.16)    # cmake版本最低要求

project(cmake_test VERSION 0.1 LANGUAGES CXX)   # 工程信息，支持语言

set(CMAKE_AUTOUIC ON)   # UIC的开关，自动完成.ui文件生成对应的.h文件
set(CMAKE_AUTOMOC ON)   # MOC的开关，支持元对象系统的头文件生成对应的cpp文件
set(CMAKE_AUTORCC ON)   # RCC的开关，.qrc文件生成对应的cpp文件，完成资源管理的映射

set(CMAKE_CXX_STANDARD 17)    # C++的标准
set(CMAKE_CXX_STANDARD_REQUIRED ON)    # 需要编译器支持C++17的标准

# 通过camke查找第三方开发包的信息，最终生成QT6的变量名
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)
```

### Qt6的cmake

部分：

```cmake
cmake_minimum_required(VERSION 3.19)
project(cmake6_test LANGUAGES CXX)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets)    # 查找组件Core和Widgets

qt_standard_project_setup()    # AUTO RCC默认关闭，建议使用cmake引入资源

qt_add_executable(cmake6_test
    WIN32 MACOSX_BUNDLE
    main.cpp
    widget.cpp
    widget.h
    widget.ui
)

target_link_libraries(cmake6_test    # 链接库文件
    PRIVATE
        Qt::Core
        Qt::Widgets
)
```

# 环境搭建

## clangd

clangd是一个代码检查工具，需要服务器端运行clangd服务

1. 安装clangd服务并配置环境变量
2. 在vscode安装clangd插件

在项目目录下创建`.clang-format`文件用于配置代码格式化规则

## cmake

1. 安装cmake并配置环境变量
2. 在vscode安装cmake插件

# Qt对象管理

## 对象树

Qt对象树：一个对象包含另一个对象，父对象显示子对象也会显示，父对象消失，子对象也消失

```Cpp
QWidget w1;    //父对象
QPushButton btn(&w1);    //子对象
//btn.setParent(&w1);     //显式设置父对象
w1.show();
```

1. Qt控件都有一个父对象指针，依附于一个父对象，一旦父对象释放，其所有子对象都自动调用析构函数
2. 父对象有一个子对象列表，一个对象销毁时，遍历其子对象列表里的对象，执行子对象的析构函数，再通过parent指针通知父对象删除自身
3. 若控件放到了栈空间上，可能多次释放导致错误，栈空间上的资源获取和释放顺序相反，若子对象先于父对象释放，释放父对象时会重复释放子对象
4. 设计准测：最上层的控件放在栈区，其下的子控件放在堆区，子控件不需要手动释放

```Cpp
QWidget w1;
Widget* x1=new Widget(&w1);
w1.show();
```

## QDebug调试类

头文件`<QDebug>`

qDebug等方法的使用：`qDebug() << "debug";`

日志打印级别：
1. qDebug()：调试信息，在生产开发中一般禁用
2. qInfo()：记录程序运行过程中重要但非错误的信息
3. qWarning()：警告信息，表示可能有问题但程序可正常运行
4. qCritical()：严重错误，但程序不至于终止
5. qFatal()：致命错误，输出后程序立即终止

关闭debug日志打印：在CMakeLists.txt中添加编译宏`QT_NO_INFO_OUTPUT`：`target_compile_definitions(目标 PRIVATE QT_NO_DEBUG_OUTPUT)`，关闭其他级别的日志打印同理

## 利用对象树实现自定义类

自定义类以public方式继承`QObject`类或其子类，构造函数传参给`QObject`的构造函数，析构重写`QObject`的析构，就可以实现父对象自动释放子对象

```Cpp
class Person:public QObject{
public:
    explicit Person(QObject* parent=nullptr):QObject(parent){
        cout<<__PRETTY_FUNCTION__<<endl;    //打印类名和函数名
    }
    ~Person()override{
        cout<<__PRETTY_FUNCTION__<<endl;    //打印类名和函数名
    }
};

void test01(){
    Person a1;
    auto d1=new Dog(&a1);    //d1自动释放
}
```

# QString

## 字符串编码

字符的表示：编码方法，C/C++的字符串，Qt的字符串

- 英语系符号：ASCII，7位
- 非英语系符号：GBK，2字节， 不同国家的编码传输时可能有冲突（字节数不同）
- Unicode：所有国家的编码统一占2字节
- 变长编码：UTF8，根据概率确定编码字节数，汉字3字节，英语字母1字节

使用一种规则编码，用另一种规则解码时会乱码

## QString跨平台原理

源码中的字符以一种编码方式存在可执行文件中，在终端显示时以另一种方式解码会导致乱码

QString先将UTF8（默认）的字符以Unicode中间方式转码，根据SDK包表示的环境再编码，保证编码和解码方式一致

QString类的字符需要使用QDebug中的方法输出到终端

QString默认将UTF8的源文件转换成Unicode，若源文件不是UTF8编码，需要使用`QString::from*()`函数转换，比如`QString::fromLocal8Bit(const char *str, qsizetype size)`

## 写时拷贝

Qt的容器的dataPointer指针指向的空间一部分是元属性，一部分是数据比如QChar

Qt容器的写时拷贝（COW）：赋值时两个容器指向的空间相同，只有要执行写操作时才另外开一块内存用来存新的容器

## QString的使用

### 创建&转换

- `QString(const char *_str_)`：利用C的UTF8字符串构造
- `QString(const QChar *_unicode_, qsizetype _size_ = -1)`：直接用unicode的字符串构造，需要指定长度

### 转换

- `QString QString::fromStdString(const std::string &_str_)`：静态利用C++的string转换
- `QString QString::fromUtf8(const char *_str_, qsizetype _size_)`：静态利用UTF8的字符构造
- `QString QString::number(long _n_, int _base_ = 10)`：将数字按指定基数进制转换成数字字符串
- `std::string toStdString() const`：私有方法转换成C++std的string
- `int toInt(bool *ok = nullptr, int base = 10) const`：私有方法转成int数字，ok用于存储是否转换成功，可以忽略开头和结尾的空格
- `const char* result=str1.toUtf8().constData();`：转换成utf8的字符串

### 格式化

- `QString QString::asprintf(const char format,...)`：C风格的静态格式化构造方法
- `QString arg()`：Qt风格的格式化构造方法
	```Cpp
	const char* format="%1 is %2 years old";
	QString str1(format);
	QString result=str1.arg("mofei").arg(18);
	qDebug()<<result;
	```

### 增加

- `QString &QString::append(const QString &str)`：在后面追加，`operator+=()`同理
- `QString &QString::prepend(const QString &str)`：在前面追加，效率和append一样
- `QString &QString::insert(qsizetype position, const QString &str)`：在指定位置插入，位置是QChar字符索引（Unicode存储）而不是char字节索引，即qsizetype和size_t的区别

### 删除

- `void QString::clear()`：清除
- `bool QString::isNull() const`：判空，`isEmpty()`同理
- `void QString::chop(qsizetype _n_)`：从字符串末尾删除n个字符
- `QString QString::chopped(qsizetype _len_) const &`：得到从末尾删除n个字符后的QString
- `QString& QString::remove(qsizetype position,qsizetype n)`：从指定位置删除n个字符

### 替换

- `QString &QString::replace(qsizetype position, qsizetype n, const QString &after)`：从指定位置开始用after替换n个字符

### 查找

- `operator[]()`
- `at()`
- `front()`
- `back()`
- `indexOf()`：从前往后查找，返回查找到的索引，可以指定查找起点
- `lastIndexOf()`：从后往前查找，返回查找到的索引，可以指定查找起点
- `contains()`：判断是否包含
- `count()`：计数

### 提取

- `left()`：截取左边n个字符
- `right()`：截取右边n个字符
- `mid()`：从指定位置截取n个字符，n为-1表示截取后面的所有

### 实例

```Cpp
//提取文件名  
void test02() {  
  
    QString str1("/home/mofei/Code/my.txt");  
    qsizetype posi=str1.lastIndexOf('/');  
    QString filename=str1.mid(posi+1);  
  
    qDebug()<<filename;  
}  
  
//提取value  
void test03() {  
  
    QString str1("Content-Length: 6380\r\n");  
    QString key("Content-Length: ");  
    qsizetype start_posi=str1.indexOf(key);  
    qsizetype end_posi=str1.indexOf("\r\n",start_posi+key.size());  
    QString value=str1.mid(start_posi+key.size(),end_posi-start_posi-key.size());  
    //qDebug()<<value;  
    bool result=false;  
    int len=value.toInt(&result);  
    if (result) {  
        qDebug()<<len;  
    }  
    else {  
        qDebug()<<"to int error";  
    }  
}
```

# 容器

## 常用容器

- 顺序容器：QVector，QList，QStack，QQueue；Qt中QVector是QList的别名，QList底层是动态数组而不是双向链表，Qt没有提供链式容器
- 关联容器：
	- 基于红黑树（有序）的关联容器：QMap，QMultiMap
	- 基于哈希（无序）的关联容器：QHash，QSet，QMultiHash

## 容器的遍历

支持基于范围的遍历，利用索引遍历，利用迭代器访问，foreach遍历（和基于范围的遍历类似，不是stl的函数，需要拷贝，效率较低）

对QMap和QHash的迭代器使用`value()`取值，`key()`取键

# 布局

QLayOut最终继承QObject，没有继承QWidget，布局不是可视化的组件

布局的约束：组件自己的sizePolicy约束，最小最大值约束，LayOut的layoutStretch约束

代码中设计布局按从左到右，从上到下的顺序设计

## 常用布局

- QHBoxLayout：水平布局
- QVBoxLayout：垂直布局
- QGridLayout：网格布局
- QFormLayout：表单布局

### 设计水平垂直布局

```Cpp title:"Widget::show1()"
void Widget::show1(){

    this->setGeometry(100,200,280,260);    //设置窗口的几何属性

    auto * main_layout=new QHBoxLayout(this);    //创建一个水平布局
    auto * group=new QGroupBox(this);    //创建一个gourpBox
    auto * edit=new QTextEdit(this);    //创建一个textEdit

    auto * group_layout=new QVBoxLayout(group);    //创建group内的垂直布局
    QList<QString> btn_names={"bnt1","bnt2","bnt3"};
    QSizePolicy sizePolicy(QSizePolicy::Minimum, QSizePolicy::Expanding);    //用于设置组件的sizePolicy属性
    for(auto& x:btn_names){    //创建3个按钮并加入到group_layout布局中
        auto *btn=new QPushButton(x,group);    //创建按钮
        btn->setSizePolicy(sizePolicy);    //设置组件属性
        group_layout->addWidget(btn);    //加入布局
    }

    //设置group_layout的布局属性
    group_layout->setStretch(1,1);    //序号（0开始），比例
    group_layout->setStretch(2,2);

    //向main_layout布局中添加控件
    main_layout->addWidget(group);
    main_layout->addWidget(edit);

    //设置main_layout的布局属性
    main_layout->setStretch(0,1);
    main_layout->setStretch(1,2);
}
```

在Widget的构造函数中调用show1()：
```Cpp
Widget::Widget(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::Widget)
{
    //ui->setupUi(this);    UIC生成的代码
    this->show1();    //代码设计的布局
}
```

![[Pasted image 20260919145557.png | 水平垂直布局]]

### 设计网络布局

```Cpp
void Widget::show2(){

    this->setGeometry(100,200,280,280);    //设置窗口的几何属性

    auto * main_layout=new QVBoxLayout(this);    //创建main_layout布局
    auto * group=new QGroupBox(this);    //创建一个gourpBox
    auto * group_layout=new QGridLayout(group);    //创建group内的网络布局

    auto * btn1=new QPushButton("bnt1",group);    //创建按钮1
    auto * btn2=new QPushButton("bnt2",group);    //创建按钮2
    auto * com1=new QComboBox(group);    //创建下拉表
    auto * edit=new QTextEdit(group);    //创建testEdit

    //将控件加入groupBox
    group_layout->addWidget(btn1,0,0);    //第0行第0列
    group_layout->addWidget(btn2,0,1);    //第0行第1列
    group_layout->addWidget(com1,1,0,1,2);    //占1行占2列
    group_layout->addWidget(edit,2,0,1,2);

    main_layout->addWidget(group);    //将group加入main_layout布局
}
```

在Widget构造函数中调用show2()

![[Pasted image 20260919153356.png | 网路布局]]


### 设计表单布局

```Cpp
void Widget::show3(){

    this->setGeometry(100,200,290,260);    //设置窗口的几何属性
    auto * main_layout= new QVBoxLayout(this);    //创建main_layout布局
    auto * group=new QGroupBox(this);    //创建一个gourpBox
    auto * group_layout=new QFormLayout(group);    //创建group内的表单布局

    //创建控件
    auto * user_label=new QLabel("用户名(&u)",group);   //设置快捷键为alt+u
    auto * user_edit=new QLineEdit(group);
    auto * age_label=new QLabel("年龄(&a)",group);    //设置快捷键为alt+a
    auto * age_edit=new QLineEdit(group);

    //添加行，可以用addRow或setWidget
    group_layout->addRow(user_label,user_edit);
    group_layout->setWidget(1,QFormLayout::LabelRole,age_label);
    group_layout->setWidget(1,QFormLayout::FieldRole,age_edit);

    //设置伙伴关系
    user_label->setBuddy(user_edit);
    age_label->setBuddy(age_edit);

    main_layout->addWidget(group);    //将group加入main_layout布局
}
```

在Widget构造函数中调用show3()

![[Pasted image 20260919160833.png | 表单布局]]

## QSplitter分割器

可视的分割器，可以滑动

```Cpp
void Widget::show4(){

    this->setGeometry(100,200,295,265);    //设置窗口的几何属性
    auto * main_layout= new QVBoxLayout(this);    //创建main_layout布局
    auto * main_splitter=new QSplitter(this);    //创建主分割器
    main_splitter->setOrientation(Qt::Horizontal);    //设置分割器方向

    auto * left_group=new QGroupBox(main_splitter);
    auto * right_splitter=new QSplitter(Qt::Vertical,main_splitter);    //创建右部分的分割器，直接设置分割器方向

    //右部分的控件
    auto * edit=new QTextEdit(right_splitter);
    auto * right_group=new QGroupBox(right_splitter);

    // //加入右部分的分割器
    // right_splitter->addWidget(edit);
    // right_splitter->addWidget(right_group);

    // //加入主分割器
    // main_splitter->addWidget(left_group);
    // main_splitter->addWidget(right_splitter);

    //不需要加入分割器

    main_layout->addWidget(main_splitter);    //main_splitter加入main_layout
}
```

![[Pasted image 20260919164927.png | 分割器]]

# QtRandomGenerator

随机数从熵池中取

- `void QRandomGenerator::seed(quint32 seed = 1)`：设置随机数种子，也可以在构造时设置
- `quint32 QRandomGenerator::generate()`：产生随机数
- `quint32 QRandomGenerator::bounded(quint32 lowest, quint32 highest)`：产生范围内的随机数，左闭右开

可以用`QDateTime::currentSecsSinceEpoch()`静态方法产生的当前时刻距离1970年的秒数作为随机数种子

# 元对象系统

元对象使用特性：
1. 类中第一行声明`Q_OBJECT`宏
2. 继承QObject
3. 不能放到cpp文件内

类中额外增加元对象的空间结构信息

反射思想：QtCore框架判断类是否有某个属性，运行时动态调整类的属性

```Cpp title:"Monster.h"
class Monster: public QObject {  
    Q_OBJECT      //声明Q_OBJECT宏
    //属性公开  
    Q_PROPERTY(int health MEMBER m_health)    //对外是health，对内是m_health  
    Q_PROPERTY(int magic MEMBER m_magic)  
public:  
    explicit Monster(QObject* parent=nullptr);  
    ~Monster()override=default;  
    void show_info()const;  
private:  
    int m_health;  
    int m_magic;  
};
```

```Cpp title:"Monster.cpp"
Monster::Monster(QObject* parent):QObject(parent),m_health(10),m_magic(5) {}  
  
void Monster::show_info()const {  
    qDebug()<<"health="<<this->m_health;  
    qDebug()<<"magic="<<this->m_magic;  
}
```

```Cpp main.cpp
void my_show(QObject* obj) {  
    auto meta =obj->metaObject();  
    //展示所有obj支持的属性成员展示  
    qDebug()<<"count:"<<meta->propertyCount();  
    for (int i=0;i<meta->propertyCount();i++) {  
        QMetaProperty property =meta->property(i);  
        qDebug()<<property.name()<<" "<<property.typeName();  
    }  
}  
  
void my_lost(QObject* obj,const char* propertyName) {  
    auto meta=obj->metaObject();  
    int index=meta->indexOfProperty(propertyName);    //查找元对象中propertyName属性的下标  
    QMetaProperty property=meta->property(index);  
    int cur=property.read(obj).toInt();  
    property.write(obj,--cur);    //修改属性  
}  
  
void test06() {  
    Monster mons1;    //实例化一个元对象
    my_show(&mons1);  
    my_lost(&mons1,"health");  
    mons1.show_info();  
    my_lost(&mons1,"magic");  
    mons1.show_info();  
}
```

# 信号和槽

## 自定义信号和槽

Qt对象之间要支持元对象系统才能实现信号和槽

设计信号：
1. 支持元对象系统
2. 访问权限signals
3. 信号本质是一个成员函数，只写声明不写定义，由MOC生成具体实现
4. 信号的返回值必须是void

设计槽：
1. 支持元对象系统
2. 访问权限public/private/protected+slots，slots只是一个标识
3. 槽函数本质是一个成员函数，必须要有实现
4. 槽函数的参数原则上要和信号函数的参数对应，若槽函数的参数个数比信号函数的参数个数多，编译会报错

利用静态方法`QObject::connect()`建立信号和槽之间的连接

调用信号函数发送信号，调用前面加emit宏，本质上只是一个标识

```Cpp title:"info.h"
class A:public QObject {  
  
    Q_OBJECT  
public:  
    explicit A(QObject* parent=nullptr);  
    ~A()override=default;  
    signals:  
    void a_signal();    //信号  
    void a_signal(int);    //重载
};  
  
class B:public QObject {  
  
    Q_OBJECT  
public:  
    explicit B(QObject* parent=nullptr);  
    ~B()override=default;  
public slots:  
    void b_slot();    //槽
    void b_slot(int);    //重载
};
```

```Cpp title:"info.cpp"
A::A(QObject* parent):QObject(parent){}  
  
B::B(QObject* parent):QObject(parent){}  
  
void B::b_slot() {  
    qDebug()<<"start b_slot()";  
}

void B::b_slot(){
	qDebug()<<"start b_slot(int)";
}
```

```Cpp title:"main.cpp"
void test01() {  
    A a;  
    B b;  
    //字符串方式建立信号和槽的连接  
    //QObject::connect(&a,SIGNAL(a_signal()),&b,SLOT(b_slot()));  
    //QObject::connect(&a,SIGNAL(a_signal(int)),&b,SLOT(b_slot(int))); 
     
    //函数指针方式建立信号和槽的连接
    //QObject::connect(&a,&A::a_signal,&b,&B::b_slot);
    
    //Overload处理函数重载，C++14
    QObject::connect(&a,qOverload<>(A::a_signal),&b,qOverload<>(B::b_signal));
    QObject::connect(&a,qOverload<int>(A:a_signal),&b,qOverload<int>(B::b_signal));
    
    getchar();  
    emit a.a_signal();    //发送信号  
}
```

## connect函数的重载方式

- 字符串形式：`QMetaObject::Connection QObject::connect(const QObject *sender, const char *signal, const QObject *receiver, const char *method, Qt::ConnectionType type = Qt::AutoConnection)`，若函数不存在，编译期间不会报错，可以处理函数重载问题
- 函数指针形参：PointerToMemberFunction，编译期间会检查函数是否存在，无法处理函数重载问题
- 使用qOverload处理传函数指针形参时的函数重载问题，对于C++11，语法`QOverload<>::of()`

一个信号可以绑定多个槽，要注意信号和槽的重复绑定问题

## 多个槽函数的合并

可能会有多个对象的信号绑定了同一个槽，需要使用sender获取特定对象处理特定业务

- `QObject *QObject::sender() const`：返回发送signal的对象的指针，必须在被signal激活的槽函数中调用，否则sender返回空
- `template <typename T> T qobject_cast(const QObject *object)`：强制转换为某个类型，必须是QObject的子类且定义了Q_OBJECT，转换失败返回nullptr，成功返回转换后的类指针

## 实例

随机矩阵键盘

```Cpp title:"key_pad.h"
  
#ifndef KEYPAD_KEY_PAD_H  
#define KEYPAD_KEY_PAD_H  
  
#include <QWidget>  
#include <QGridLayout>  
#include <QPushButton>  
#include <QString>  
#include <QList>  
#include <QPushButton>  
#include <QDebug>  
#include <QRandomGenerator>  
#include <QDateTime>  
  
struct key_value {  
    QString text;  
    int value;  
};  
  
static QList<key_value> pads={  
    {"1",1},{"2",2},{"3",3},{"4",4},{"5",5},  
    {"6",6},{"7",7},{"8",8},{"9",9},{"删除",11},  
    {"0",0},{"确认",12}  
};  
  
inline QList<QPushButton*> bnts;  
  
QT_BEGIN_NAMESPACE  
  
namespace Ui {  
    class keyPad;  
}  
  
QT_END_NAMESPACE  
  
class keyPad : public QWidget {  
    Q_OBJECT  
  
public:  
    explicit keyPad(QWidget *parent = nullptr);  
  
    ~keyPad() override;  
private:  
    void fixed_keypad();    //固定布局  
    void random_keypad();    //随机布局  
public slots:  
    void lcd_show();  
  
private:  
    Ui::keyPad *ui;  
    QGridLayout* pad_layout;    //键盘布局  
};  
  
  
#endif //KEYPAD_KEY_PAD_H
```

```Cpp title:"key_pad.cpp"
#include "key_pad.h"  
#include "ui_key_pad.h"  
  
keyPad::keyPad(QWidget *parent) : QWidget(parent), ui(new Ui::keyPad) {  
    ui->setupUi(this);  
    pad_layout=new QGridLayout(ui->padWidget);  
    pad_layout->setContentsMargins(0,0,0,0);    //设置边距margin为0  
    pad_layout->setSpacing(0);    //设置填充space为0  
  
    QPushButton* bnt=nullptr;  
    for (int i=0;i<pads.size();i++) {  
        bnt=new QPushButton(pads[i].text,ui->padWidget);  
        bnt->setProperty("value",pads[i].value);  
        bnt->setMinimumSize(80,80);  
        bnt->setMaximumSize(80,80);  
        connect(bnt,&QPushButton::clicked,this,&keyPad::lcd_show);    //绑定信号和槽  
        bnts.append(bnt);  
    }  
    fixed_keypad();  
}  
  
keyPad::~keyPad() {  
    delete ui;  
}  
  
void keyPad::fixed_keypad() {  
  
    for (int i=0;i<4;i++) {  
        for (int j=0;j<3;j++) {  
            int index=i*3+j;  
            auto *bnt=bnts[index];  
            pad_layout->addWidget(bnt,i,j);  
        }  
    }  
}  
  
void keyPad::random_keypad() {  
  
    QRandomGenerator random(QDateTime::currentSecsSinceEpoch());  
  
    QList<int> indexes;  
    for (int i=0;i<pads.size();i++) {  
        if (pads[i].value<10) {  
            indexes.push_back(i);  
        }  
    }  
    std::shuffle(indexes.begin(),indexes.end(),random);  
  
    int indexed_posi=0;  
    for (int i=0;i<4;i++) {  
        for (int j=0;j<3;j++) {  
            int posi=i*3+j;  
            QPushButton* bnt=nullptr;  
            if (posi==9||posi==11) {    //“确认”或“删除”  
                bnt=bnts[posi];  
            }  
            else {    //数字  
                bnt=bnts[indexes[indexed_posi++]];  
            }  
            pad_layout->addWidget(bnt,i,j);  
        }  
    }  
}  
  
void keyPad::lcd_show() {  
  
    static int cnt=0;    //位数  
  
    auto * bnt=qobject_cast<QPushButton*>(sender());  
    int lcd_val=ui->lcdShow->intValue();  
    if (!bnt) {  
        return;  
    }  
    int key_val = bnt->property("value").toInt();  
  
    if (key_val==11) {    //删除  
        if (cnt<=0)return;  
        lcd_val/=10;  
        ui->lcdShow->display(lcd_val);  
        cnt--;  
    }  
    else if (key_val==12) {    //确认  
        cnt=0;  
        ui->lcdShow->display(0);  
        random_keypad();  
    }  
    else {  
        if (cnt>=6) {  
            ui->lcdShow->display(key_val);  
            cnt = 1;  
            return;  
        }  
        cnt++;  
        lcd_val*=10;  
        lcd_val+=key_val;  
        ui->lcdShow->display(lcd_val);  
    }  
}
```

```Cpp title:"main.cpp"
#include <QApplication>  
#include <key_pad.h>  
  
int main(int argc, char *argv[]) {  
    QApplication a(argc, argv);  
    keyPad win;  
    win.show();  
    return QApplication::exec();  
}
```

![[Pasted image 20260920155450.png | 随机矩阵键盘]]

# 事件系统

Qt的事件系统在OS的事件机制上将用户空间的事件数据结构进行封装

事件派生自QEvent基类，可以由QObject任意的子类对象接收和处理

`QApplication::exec()`进入事件循环监听，有事件时Qt创建一个事件对象

Qt事件分类：
- 自生事件：窗口系统产生的事件，自生事件进入系统队列
- 发布事件：`QCoreApplication::postEvent()`，Qt应用程序产生的事件，发布事件进入Qt事件队列
- 发送事件：`QCoreApplication::sendEvent()`，由对象的event函数直接处理

## 事件处理机制的路径

1. 事件通知（派发）：`bool QCoreApplication::notify(QObject *receiver, QEvent *event)`
2. 事件过滤：`bool QObject::eventFilter(QObject *watched, QEvent *event)`
3. 事件分发：`bool QObject::event(QEvent *e)`
4. 事件处理函数，protect的虚函数，如`void QWidget::closeEvent(QCloseEvent *event)`

![[Pasted image 20260920180248.png| 事件处理机制的路径]]

![[事件的流程.png]]

自定义控件：

```Cpp title:"Innerlabel.h"
  
#ifndef EVENTBASE_INNERLABEL_H  
#define EVENTBASE_INNERLABEL_H  
#include <QLabel>  
#include <QWidget>  
#include <QDebug>  
#include <QEvent>  
  
  
//在Widget类中创建一个Innerlabel，初始化父对象为Widget实例(this)
class InnerLabel :public QLabel{  
    Q_OBJECT  
public:  
    explicit InnerLabel(QWidget* parent=nullptr);  
    ~InnerLabel()override=default;  
protected:  
    bool event(QEvent *e)override;    //重写事件分发函数  
    void mousePressEvent(QMouseEvent *event) override;    //重写特定的事件处理函数  
};  
  
  
#endif //EVENTBASE_INNERLABEL_H
```

```Cpp title:"InnerLabel"
  
#include "InnerLabel.h"  
#include "InnerLabel.h"  
  
InnerLabel::InnerLabel(QWidget* parent):QLabel(parent) {  
  
    //设置Frame样式  
    setFrameStyle(QFrame::Panel|QFrame::Plain);  
    setLineWidth(3);  
    setMidLineWidth(1);  
}  
  
bool InnerLabel::event(QEvent *ev) {  
  
    if (ev->type()==QEvent::MouseButtonPress) {  
        qDebug()<<"----";  
        mousePressEvent((QMouseEvent*)ev);    //调用事件处理函数  
        return true;  
    }  
    return QLabel::event(ev);    //需要由父类分发事件  
}  
  
void InnerLabel::mousePressEvent(QMouseEvent *ev) {  
  
    qDebug()<<"InnerLabel::mousePressEvent";  
}
```

## 事件的传递

- `void QEvent::ignore()`：忽略事件，一般在事件处理函数中调用
- `void QEvent::accept()`：接收事件，默认

若处理事件的焦点对象忽略了该事件（ignore()），事件会传递给父对象的事件分发函数，若最后没有对象接收事件，事件会被实际忽略

![[Pasted image 20260920191206.png]]

## 事件过滤

- `void QObject::installEventFilter(QObject *filterObj)`：由子对象调用，安装在父对象上（参数传父对象），由父对象重写过滤行为eventFilter
- `bool QObject::eventFilter(QObject *watched, QEvent *event)`：针对对象watched屏蔽事件event

```Cpp title:"eventFilter"
bool widget::eventFilter(QObject *watched, QEvent *event) {  
  
    if (watched==inner_label) {  
        if (event->type()==QEvent::MouseButtonPress) {  
            qDebug()<<__PRETTY_FUNCTION__;  
            return true;    //过滤事件  
        }  
    }  
    return QWidget::eventFilter(watched, event);  
}
```

## 实例

### 鼠标事件

- 通过QMouseEvent获取哪个鼠标键按下，按下坐标等
- 通过QWheelEvent获取滚轮移动方向和距离等
- 常见鼠标事件：
	- `mousePressEvent(QMouseEvent* event)`
	- `mouseReleaseEvent(QMouseEvent* event)`
	- `mouseMoveEvent(QMouseEvent* event)`，需要配合`seMouseTracking`
	- `mouseDoubleClickEvent(QMouseEvent* event)`
	- `wheelEvent(QWheelEvent* event)`

```Cpp title:"main.cpp"
#include <QApplication>  
#include "MouseWidget.h"  
  
int main(int argc, char *argv[]) {  
    QApplication a(argc, argv);  
    MouseWidget win;  
    win.show();  
    return QApplication::exec();  
}
```

```Cpp title:"MouseWidget.h"
  
#ifndef MOUSE_MOUSEWIDGET_H  
#define MOUSE_MOUSEWIDGET_H  
  
#include <QWidget>  
#include <QPointF>  
#include <QTextEdit>  
#include <QWheelEvent>  
  
class MouseWidget:public QWidget {  
    Q_OBJECT  
public:  
    explicit MouseWidget(QWidget* parent=nullptr);  
    ~MouseWidget()override=default;  
protected:  
    void mousePressEvent(QMouseEvent *event) override;    //重写鼠标按下事件处理函数  
    void mouseReleaseEvent(QMouseEvent *event) override;    //重写鼠标松开事件处理函数  
    void mouseDoubleClickEvent(QMouseEvent *event) override;    //重写鼠标双击事件处理函数  
    void mouseMoveEvent(QMouseEvent *event) override;    //重写鼠标移动事件（按住了移动）处理函数  
    void wheelEvent(QWheelEvent *event) override;    //重写鼠标滚轮事件处理函数  
    void closeEvent(QCloseEvent *event) override;    //重写窗口关闭事件处理函数  
  
private:  
    QPointF mouse_offset;    //鼠标相对MouseWidget的位置  
    QTextEdit* edit;    //文本编辑  
};  
  
#endif //MOUSE_MOUSEWIDGET_H
```

```Cpp title:"MouseWidget.cpp"
  
#include "MouseWidget.h"  
  
#include <QApplication>  
#include <QCursor>  
#include <QMouseEvent>  
#include <QMessageBox>  
  
MouseWidget::MouseWidget(QWidget* parent):QWidget(parent) {  
  
    setGeometry(100,100,400,400);    //设置窗口几何属性  
    //设置鼠标样式  
    QCursor cursor;  
    cursor.setShape(Qt::OpenHandCursor);    //设置鼠标形状  
    setCursor(cursor);  
  
    //初始化edit  
    edit=new QTextEdit(this);  
    edit->resize(200,200);  
    edit->move(100,100);  
}  
  
void MouseWidget::mousePressEvent(QMouseEvent *event) {  
  
    if (event->button()==Qt::LeftButton) {    //左键按下  
  
        //调整鼠标样式  
        QCursor cursor;  
        cursor.setShape(Qt::ClosedHandCursor);    //设置鼠标形状  
        QApplication::setOverrideCursor(cursor);    //暂时改变  
  
        //获取鼠标相对位置  
        mouse_offset=event->globalPosition()-MouseWidget::pos();  
    }  
    else if (event->button()==Qt::RightButton) {    //右键按下  
  
        //调整鼠标样式  
        QPixmap pixmap("../myCursor.png");    //创建pixmap  
        qreal dpr=qApp->primaryScreen()->devicePixelRatio();    //获取设备dpr  
        QSize logicalSize(32,32);  
        QSize realSize=logicalSize*dpr;  
        pixmap=pixmap.scaled(realSize,Qt::KeepAspectRatio,Qt::SmoothTransformation);    //缩放  
        pixmap.setDevicePixelRatio(dpr);    //重新渲染  
  
        QCursor cursor(pixmap,logicalSize.width(),logicalSize.height());    //用pixmap设置鼠标  
        QApplication::setOverrideCursor(cursor);    //暂时改变  
    }  
    //QWidget::mousePressEvent(event);  
}  
  
void MouseWidget::mouseReleaseEvent(QMouseEvent *event) {  
  
    if (event->button()==Qt::LeftButton) {    //左键松开  
        QApplication::restoreOverrideCursor();    //恢复鼠标样式  
    }  
    //QWidget::mouseReleaseEvent(event);  
}  
  
  
void MouseWidget::mouseDoubleClickEvent(QMouseEvent *event) {  
  
    if (event->button()==Qt::LeftButton) {    //左键双击 
  
        if (windowState()!=Qt::WindowFullScreen) {  
            setWindowState(Qt::WindowFullScreen);    //设置窗口全屏  
        }  
        else {  
            setWindowState(Qt::WindowNoState);    //恢复窗口状态  
        }  
    }  
    //QWidget::mouseDoubleClickEvent(event);  
}  
  
void MouseWidget::mouseMoveEvent(QMouseEvent *event) {  
  
    if (event->buttons()&Qt::LeftButton) {     //左键按住移动  
        QPointF temp=event->globalPosition()-mouse_offset;    //鼠标的移动  
        move(temp.x(),temp.y());    //实现窗口移动  
    }  
    //QWidget::mouseMoveEvent(event);  
}  
  
void MouseWidget::wheelEvent(QWheelEvent *event) {  
  
    if (event->angleDelta().y()>0) {    //滚轮向上  
        edit->zoomIn();    //放大编辑器  
    }  
    else {  
        edit->zoomOut();    //缩小编辑器  
    }  
  
    //QWidget::wheelEvent(event);  
}  
  
void MouseWidget::closeEvent(QCloseEvent *event) {  
  
    QString title="鼠标事件框";  
    QString info="确定退出吗";  
    QMessageBox::StandardButton result=  
    QMessageBox::question(this,title,info,QMessageBox::Yes|QMessageBox::No|QMessageBox::Cancel);  
    if (result==QMessageBox::Yes) {  
        event->accept();  
    }  
    else {  
        event->ignore();  
    }  
  
    //QWidget::closeEvent(event);  
}
```

### 键盘事件

- QKeyEvent类描述一个键盘事件
- QKeyEvent的key()函数可以获得具体的按键
- 回车键是Qt::Key_Return，修饰键比如ctrl和shift，需要使用QKeyEvent的modifiers()函数获取

```Cpp title:"KeyEvent.h"
#ifndef KEYEVENT_KEYWIDGET_H  
#define KEYEVENT_KEYWIDGET_H  
  
#include <QWidget>  
#include <QPushButton>  
#include <QKeyEvent>  
  
class KeyWidget:public QWidget {  
    Q_OBJECT  
public:  
    explicit KeyWidget(QWidget* parent=nullptr);  
    ~KeyWidget()override=default;  
protected:  
    void keyPressEvent(QKeyEvent *event) override;    //重写按键按下事件处理函数  
private:  
    QPushButton* bnt_move;  
};  
  
#endif //KEYEVENT_KEYWIDGET_H
```

```Cpp title:"KeyEvent.cpp"
#include "KeyWidget.h"  
  
KeyWidget::KeyWidget(QWidget* parent):QWidget(parent) {  
  
    setGeometry(100,100,400,400);  
    setFocusPolicy(Qt::StrongFocus);    //设置焦点策略  
    setFocus();    //将KeyWidget设置为焦点，处理上下左右键没有效果  
  
    bnt_move=new QPushButton(this);  
    bnt_move->resize(80,80);  
    bnt_move->setText("Move Button");  
}  
  
void KeyWidget::keyPressEvent(QKeyEvent *event) {  
    QPoint point = bnt_move->pos();  
    if (event->key()==Qt::Key_A||event->key()==Qt::Key_Left) {    //左  
        bnt_move->move(point.x()-20,point.y());    //左移  
    }  
    else if (event->key()==Qt::Key_S||event->key()==Qt::Key_Down) {    //下  
        bnt_move->move(point.x(),point.y()+20);    //下移  
    }  
    else if (event->key()==Qt::Key_D||event->key()==Qt::Key_Right) {    //右  
        bnt_move->move(point.x()+20,point.y());    //右移  
    }  
    else if (event->key()==Qt::Key_W||event->key()==Qt::Key_Up) {    //下  
        bnt_move->move(point.x(),point.y()-10);    //上移  
    }  
    else if (event->modifiers()==Qt::ControlModifier&&event->key()==Qt::Key_Q) {    //组合键  
        close();    //调用槽函数关闭  
    }  
    event->accept();  
}
```

### 定时事件

定时事件是基于系统时钟的周期性事件触发机制

两种使用定时器的方法：
1. 基于底层的事件处理机制：对于一个QObject子类，利用timerEvent事件处理
2. 基于QTimer对象：更高层次的接口，可以使用信号和槽，可以设置只运行一次的定时器，信号函数timeout()

#### 事件处理机制

- `int QObject::startTimer(int interval, Qt::TimerType timerType = Qt::CoarseTimer)`：启动一个定时器，返回计时器的id，失败返回0，周期为interval毫秒，调用`killTimer(id)`删除定时器
- `void QObject::timerEvent(QTimerEvent *event)`：定时器到时事件的事件处理函数

```Cpp title:"timerEvent()"
void KeyWidget::timerEvent(QTimerEvent *event) {  
  
    if (event->timerId()==id1) {  
        static int id1_cnt=0;  
        id1_cnt++;  
        qDebug()<<"timer 1";  
        if (id1_cnt==5) {  
            killTimer(id1);  
        }  
    }  
    else if (event->timerId()==id2) {  
        qDebug()<<"timer 2";  
    }  
    else {  
        qDebug()<<"other timer";  
    }  
}
```

#### QTimer类

```Cpp title:"KeyWidget()"
timer=new QTimer(this);    //初始化一个QTimer  
timer->start(1000);    //启动QTimer，周期为1000毫秒  
  
QWidget::connect(timer,&QTimer::timeout,this,[&]() {  
    QTime time=QTime::currentTime();  
    QString text=time.toString("HH:mm:ss");  
    bnt_move->setText(text);  
});
```

# 线程机制

QThread类管理线程

通常主线程负责几乎所有GUI的操作，若其他线程访问这些控件，会导致程序崩溃，推荐使用信号和槽

使用线程方法：
1. 继承QThread类，重写run()函数
2. 继承QObject类，通过moveToThread(thread)交给线程执行

要注意临界资源的互斥问题

## QThread类

调用QThread::start()启动线程，需要绑定finished()信号实现线程回收deleteLater()，使用信号和槽实现更改控件

```Cpp title:"ErrorForm.h"
#ifndef THREADBASE_ERRORFORM_H  
#define THREADBASE_ERRORFORM_H  
  
#include <QWidget>  
#include <QLCDNumber>  
#include <QPushButton>  
#include "MyThread.h"  
  
class ErrorForm:public QWidget {  
    Q_OBJECT  
public:  
    explicit ErrorForm(QWidget* parent=nullptr);  
    ~ErrorForm()override=default;  
public slots:  
    void do_display(int num);  
    void do_finish();  
private:  
    QPushButton* bnt_start;  
    QLCDNumber* lcd_num;  
    MyThread* m_thread;  
    bool isRunning;  
};  
  
#endif //THREADBASE_ERRORFORM_H
```

```Cpp title:"ErrorForm.cpp"
  
#include "ErrorForm.h"  
#include <QVBoxLayout>  
  
ErrorForm::ErrorForm(QWidget *parent):QWidget(parent) ,isRunning(false){  
  
    auto* main_layout=new QVBoxLayout(this);  
  
    bnt_start=new QPushButton("Start",this);  
    lcd_num=new QLCDNumber(this);  
    lcd_num->setDigitCount(2);  
    lcd_num->setSegmentStyle(QLCDNumber::Flat);  
  
    QObject::connect(bnt_start,&QPushButton::clicked,this,[&]() {  
        if (isRunning) {  
            m_thread->requestInterruption();    //发出终止请求  
            bnt_start->setText("Start");  
            isRunning=false;  
        }  
        else {  
            m_thread=new MyThread(60);  
            QObject::connect(m_thread,&MyThread::sendNum,this,&ErrorForm::do_display);  
            QObject::connect(m_thread,&QThread::finished,this,&ErrorForm::do_finish);  
            isRunning=true;  
            bnt_start->setText("Stop");  
            m_thread->start();    //进入run函数主体，完后后发送finished信号  
        }  
    });  
  
    main_layout->addWidget(bnt_start);  
    main_layout->addWidget(lcd_num);  
  
    setLayout(main_layout);  
    resize(300,300);  
}  
  
void ErrorForm::do_display(int num) {  
  
    lcd_num->display(num);  
}  
  
void ErrorForm::do_finish() {  
  
    m_thread->wait();    //等待线程退出  
    m_thread->deleteLater();  
    isRunning=false;  
    bnt_start->setText("Start");  
}
```

```Cpp title:"MyThread.h"
#ifndef THREADBASE_MYTHREAD_H  
#define THREADBASE_MYTHREAD_H  
  
#include <QThread>  
  
class MyThread:public QThread {  
    Q_OBJECT  
public:  
    explicit MyThread(int num=60,QObject* parent=nullptr);  
    ~MyThread()override;  
    signals:  
    void sendNum(int num);  
protected:  
    void run() override;    //重写run函数  
private:  
    int m_num;  
};  
  
  
#endif //THREADBASE_MYTHREAD_H
```

```Cpp title:"MyThread.cpp"
#include "MyThread.h"  
#include <QDebug>  
  
MyThread::MyThread(int num, QObject *parent):m_num(num),QThread(parent) {  
  
}  
  
MyThread::~MyThread() {  
    qDebug()<<__PRETTY_FUNCTION__;  
}  
  
void MyThread::run() {  
  
    int i=0;  
    while (i++<60) {  
        emit sendNum(i++);  
        if (isInterruptionRequested()) {    //线程收到终止信号  
            qDebug()<<"be interrupted";  
            break;  
        }  
        QThread::msleep(100);  
    }  
    qDebug()<<"run over";  
}
```

## moveToThread()

QThread是线程的管理者，具体要做的事情可以由另一个类实现

调用run方法后，默认开启线程的事件循环

设计工作类时，主要考虑设计哪些槽方法，送到线程的事件循环，槽返回后，线程继续运行，等待下一个事件发生

调用connect()时用Qt::QueuedConnection的方式实现跨线程的槽通信，也可以默认自动

moveToThread()被移动的对象不能有父对象，以Qt::QueuedConnection的方式连接的槽函数以及该对象收到的事件会在工作线程执行

将工作对象移动到线程，发送信号后工作线程的槽函数会进入工作队列，工作类的槽函数完成退出后线程仍然运行

利用元对象系统QMetaObject::invokeMethod实现事件的发送，将要执行的工作发送到线程去执行；或使用信号连接工作的槽函数

```Cpp title:"MainWin.h"
  
#ifndef THREADMOVE_MAINWIN_H  
#define THREADMOVE_MAINWIN_H  
  
#include <QWidget>  
#include <QPushButton>  
#include <QLCDNumber>  
#include <QThread>  
#include "Worker.h"  
  
class MainWin:public QWidget {  
    Q_OBJECT;  
public:  
    explicit MainWin(QWidget* parent=nullptr);  
    ~MainWin()override;  
    public slots:  
    void do_lcdShow(int value);  
    void do_bnt();  
    void do_work_over();  
  
private:  
    QPushButton* m_bntStart;  
    QLCDNumber* m_lcdShow;  
    QThread* m_thread;  
    Worker* m_worker;  
    bool running;  
};  
  
  
#endif //THREADMOVE_MAINWIN_H
```

```Cpp title:"MainWin.cpp"
  
#include "MainWin.h"  
#include <QVBoxLayout>  
#include <QDebug>  
  
MainWin::MainWin(QWidget *parent):QWidget(parent) {  
  
    //窗口几何，控件，布局  
    setGeometry(100,100,300,300);  
    auto main_layout=new QVBoxLayout(this);  
    m_bntStart=new QPushButton("Start",this);  
    m_lcdShow=new QLCDNumber(this);  
    m_lcdShow->setSegmentStyle(QLCDNumber::Flat);  
    main_layout->addWidget(m_bntStart);  
    main_layout->addWidget(m_lcdShow);  
    setLayout(main_layout);  
  
    qDebug()<<"GUI thread id:"<<QThread::currentThreadId();  
  
    //线程  
    running=false;  
    m_thread=new QThread(this);    //工作线程  
    m_worker=new Worker(nullptr,30);    //工作类，不能有父对象  
    m_worker->moveToThread(m_thread);    //移动到线程  
    m_thread->start();    //启动线程  
    connect(m_worker,&Worker::valueReady,this,&MainWin::do_lcdShow);  
    connect(m_bntStart,&QPushButton::clicked,this,&MainWin::do_bnt);  
    connect(m_thread,&QThread::finished,m_worker,&QObject::deleteLater);    //线程退出时回收worker资源  
    connect(m_worker,&Worker::overReady,this,&MainWin::do_work_over);  
  
}  
  
MainWin::~MainWin() {  
  
    qDebug()<<__PRETTY_FUNCTION__;  
    m_thread->quit();    //退出线程  
    m_thread->wait();    //  
}  
  
void MainWin::do_lcdShow(int value) {  
    m_lcdShow->display(value);  
}  
  
void MainWin::do_bnt() {  
    if (!running) {  
        running=true;  
        m_bntStart->setText("Stop");  
        QMetaObject::invokeMethod(m_worker,"doWork",Qt::QueuedConnection);    //发送事件  
    }else {  
        m_worker->exitWork();     //在主线程调用
    }  
}  
  
void MainWin::do_work_over() {  
  
    running=false;  
    m_bntStart->setText("Start");  
}
```

```Cpp title:"Worker.h"
  
  
#ifndef THREADMOVE_WORKER_H  
#define THREADMOVE_WORKER_H  
  
#include <QObject>  
#include <atomic>  
  
class Worker:public QObject {  
    Q_OBJECT  
public:  
    explicit Worker(QObject* parent=nullptr,int max=30);  
    ~Worker()override;  
public slots:  
    void doWork();    //开始工作  
    void exitWork();    //停止工作  
    signals:  
    void valueReady(int);    //生产了数据  
    void overReady();    //结束生产  
private:  
    int m_max;  
    std::atomic<bool> running{false};    //用原子类型，避免竞态  
};  
  
  
#endif //THREADMOVE_WORKER_H
```

```Cpp title:"Worker.cpp"
  
  
#include "Worker.h"  
#include <QDebug>  
#include <QThread>  
  
Worker::Worker(QObject* parent,int max):m_max(max),QObject(parent) {}  
  
Worker::~Worker() {  
  
    qDebug()<<__PRETTY_FUNCTION__;  
}  
  
void Worker::doWork() {  
  
    qDebug()<<"worker thread id:"<<QThread::currentThreadId();  
    int value=0;  
    running.store(true);  
    while (running.load()&&value<=m_max) {  
        value++;  
        QThread::msleep(100);  
        emit valueReady(value);  
    }  
    if (running.load()) {    //主动停止  
        qDebug()<<"worker normal over";  
    }  
    else {    //被动停止  
        qDebug()<<"worker unnormal over";  
    }  
  
    emit overReady();  
}  
  
void Worker::exitWork() {  
    qDebug()<<"stop work,tid:"<<QThread::currentThreadId();  
    running.store(false);  
}
```

# 绘图系统

Painting System：
- QPainter：执行化纤，填充，变换等操作的执行者
- QPaintDevice：画布，绘图的二维空间，如QWidget，QPixmap，QImage，QPrinter
- QPaintEngine：画笔引擎，底层抽象类，将QPainter的指令翻译成不同设备的绘制指令

QPainter-->QPaintEngine-->QPaintDevice

QPainter只能在paintEvent()事件处理函数函数中调用

QPainter可以配置的工具：QPen，QBrush，QFont

重写paintEvent()事件处理函数事件绘图

## QPainter

```Cpp title:"QPainter"
void PainterBase::base01() {  
    QPainter painter(this); //设置画布为当前Widget  
    painter.setRenderHint(QPainter::Antialiasing);    //设置抗锯齿  
    painter.setRenderHint(QPainter::TextAntialiasing);    //设置文字抗锯齿  
    QPen pen(Qt::red,3,Qt::SolidLine,Qt::RoundCap,Qt::RoundJoin);  
#if 0  
    pen.setWidth(3);    //设置笔的宽度  
    pen.setColor(Qt::red);    //设置画笔颜色为红色  
    pen.setCapStyle(Qt::RoundCap);    //设置线条端点样式  
    pen.setJoinStyle(Qt::RoundJoin);    //设置线条连接样式  
    pen.setStyle(Qt::SolidLine);    //设置线条样式  
#endif  
    painter.setPen(pen);    //将画笔装备给painter  
#if 0  
    QBrush brush(Qt::blue,Qt::SolidPattern);    //设置画刷  
    painter.setBrush(brush);    //将画刷装备给painter  
#endif  
    int w=width();  
    int h=height();  
    //设置渐变粉刷的区域  
    QLinearGradient gradient(QPoint(w/4,h/4),QPoint(w/4+w/2,h/4+h/2));  
    //设置渐变位置和颜色，位置用比例表示  
    gradient.setColorAt(0,Qt::green);  
    gradient.setColorAt(0.5,Qt::red);  
    gradient.setColorAt(1,Qt::blue);  
    painter.setBrush(gradient);  
    painter.drawRect(w/4,h/4,w/2,h/2);    //在画布中心绘制举矩形  
}
```

## 基本图形接口

闭合曲线的基础都是矩形

QPainter的方法：
- 点，线：
	- drawPoint()，drawPoints：QPoint，QPointF
	- drawLine()，drawLines：起点(x1,y1)，终点(x2,y2)
	- drawPolyline()：QPointF点数组，不闭合
- 几何面：
	- drawRect()，drawRoundedRect()，drawEllipse()
	- 圆是按照外接矩形来绘制的
	- drawPolygon()：多边形，闭合，QPointF点数组
- 弧面：
	- drawArc()，drawPie()，drawChord()

```Cpp
void PainterBase::base02() {  
    QPainter painter(this); //设置画布为当前Widget  
    painter.setRenderHint(QPainter::Antialiasing);    //设置抗锯齿  
    painter.setRenderHint(QPainter::TextAntialiasing);    //设置文字抗锯齿  
    int w=width();  
    int h=height();  
  
    //闭合曲线的基础都是矩形  
    QRect rect(w/4,h/4,w/2,h/2);  
    painter.drawRect(rect);    //绘制矩形  
    painter.drawEllipse(rect);    //绘制椭圆  
    painter.drawRoundedRect(rect,20,20);    //绘制圆角矩形  
    int radius=qMin(rect.height(),rect.width())/2;  
    painter.drawRoundedRect(rect,radius,radius);    //绘制胶囊形圆角矩形  
    painter.drawArc(rect,0,30*16);    //绘制弧线  
    painter.drawPie(rect,0,30*16);    //绘制扇形  
    painter.drawChord(rect,30*16,120*16);    //绘制弦和弧  
}
```

## 重绘机制

paintEvent函数处理绘图逻辑，是系统自动调用的，只绘制一次，通过repaint()或update()函数使paintEvent()函数被动调用

update()函数不是立即更新，下一次事件处理时将所有update()合并渲染一次

定时器实现动态刷新

save()和restore()恢复状态

```Cpp title:"Ball.h"
  
#ifndef PAINTERBASE_BALL_H  
#define PAINTERBASE_BALL_H  
  
#include <QWidget>  
#include <QTimer>  
#include <QPainter>  
  
class Ball:public QWidget {  
    Q_OBJECT  
public:  
    explicit Ball(QWidget* parent=nullptr);  
    ~Ball()override=default;  
public slots:  
    void onTimeOutV1();  
    void onTimeOutV2();  
protected:  
    void paintEvent(QPaintEvent *event) override;  
private:  
    QTimer* m_timer;    //实现刷新的定时器  
    int m_radius;    //圆的半径  
    double m_posiX;    //圆心的x坐标  
    double m_speedX;    //圆心x方向移动速度  
    double m_posiY;    //圆心的y坐标  
    double m_speedY;    //圆心y方向的移动速度  
};  
  
#endif //PAINTERBASE_BALL_H
```

```Cpp title:"Ball.cpp"
  
#include "Ball.h"  
  
Ball::Ball(QWidget *parent):  
QWidget(parent),m_radius(30),m_posiX(30),m_speedX(3),m_posiY(0),m_speedY(0) {  
    m_timer=new QTimer(this);  
    connect(m_timer,&QTimer::timeout,this,&Ball::onTimeOutV1);  
    connect(m_timer,&QTimer::timeout,this,&Ball::onTimeOutV2);  
    m_timer->start(16);    //每秒60帧，相当于16毫秒刷新一次  
    setGeometry(200,200,600,400);  
}  
  
void Ball::onTimeOutV1() {  
    //更新数据  
    m_posiX+=m_speedX;  
    //碰撞检测  
    if (m_posiX+m_radius>width()||m_posiX-m_radius<=0) {  
        m_speedX=-m_speedX;  
    }  
    update();    //更新绘画  
}  
  
void Ball::onTimeOutV2() {  
    double g=0.6;    //重力加速度  
    double bounce=0.8;    //反弹系数  
    //更新数据  
    m_speedY+=g;  
    m_posiY+=m_speedY;  
    //碰撞检测  
    if (m_posiY+m_radius>=height()) {  
        m_posiY=height()-m_radius;    //修正位置，防止陷入地面  
        m_speedY=-m_speedY*bounce;  
    }  
    update();  
}  
  
void Ball::paintEvent(QPaintEvent *event) {  
    QPainter painter(this);  
    painter.setRenderHint(QPainter::Antialiasing);  
    painter.setRenderHint(QPainter::TextAntialiasing);  
    //绘制背景  
    painter.setBrush(Qt::black);  
    painter.drawRect(rect());  
    //绘制小球  
    painter.setBrush(Qt::yellow);  
    painter.setPen(Qt::NoPen);  
    painter.drawEllipse(m_posiX-m_radius,m_posiY-m_radius,m_radius*2,m_radius*2);  
}
```

## 复杂图形绘制

### QPainterPath

QPainterPath是一系列绘画行为

- 支持布尔运算，几何运算，处理图形填充规则
- 交集（intersected），并集（united），补集（subtracted）

```Cpp
//实现布尔运算，交并补  
void SeniorPainter::base01() {  
    QPainter painter(this);  
    painter.setRenderHints(QPainter::Antialiasing|QPainter::TextAntialiasing);  
  
    //定义绘画路径  
    QPainterPath path1;  
    path1.addEllipse(0,0,100,100);  
    QPainterPath path2;  
    path2.addRect(50,50,100,100);  
  
    //QPainterPath result=path1.united(path2);    //求并集  
    //QPainterPath result=path1.subtracted(path2);    //求差集  
    QPainterPath result=path1.intersected(path2);    //求差集  
  
    // painter.drawPath(path1);  
    // painter.drawPath(path2);    painter.drawPath(result);  
}  
  
//绘制一个月亮  
void SeniorPainter::base02() {  
    QPainter painter(this);  
    painter.setRenderHints(QPainter::Antialiasing|QPainter::TextAntialiasing);  
    QPainterPath path1;  
    path1.addEllipse(0,0,100,100);    //画出一个大圆  
    QPainterPath path2;  
    path2.addEllipse(30,0,100,100);    //右移一点坐标  
    QPainterPath moon=path1.subtracted(path2);  
  
    //painter.drawPath(moon);  
    painter.fillPath(moon,Qt::yellow);    //有填充  
}
```

### 坐标变换

不动图形，动画布

