# 基本概念

## 万维网

- 万维网（wide world web）：是一个大规模的，**联机**式的信息储藏所，简称web，能实现以**链接**的方式方便地从一个站点访问到另一个站点，主动地按需获取信息
	![[万维网.jpg]]
- 超文本：包含了指向其他文档的**链接**的文本文档，能被浏览器识别，一个超文本由多个信息源组成，这些信息源可以分布在世界各地且数量不受限制；超文本是万维网的基础
- 万维网使用BS模型（浏览器服务器模型），浏览器向服务器发送请求，服务器响应浏览器并向浏览器发送客户端所需要的超文本
- URL（uniform resource locator）：统一资源定位符，超文本在万维网中的唯一标识，表明了超文本的信息；网络访问中，依据URL进行请求和响应
	- URL由四部分组成：`协议://主机名:端口号/路径`，如`http://www.baidu.com.cn`
		- 协议：指出用哪种协议获取万维网的文档，常用的协议是HTTP（超文本传输协议）
		- 主机名：是万维网文档所在的主机域名（本质上是一个IP），通常以`www`开头，可以直接使用主机IP地址代替
		- 端口号：协议对应的端口号，HTTP协议默认端口号是80
		- 路径：一个较长的字符串，超文本文档所在的路径

## HTTP

- HTTP定义了浏览器是怎样向万维网服务器请求超文本，以及服务器如何把文档传递给浏览器的
- HTTP协议是面向**事务**的**应用层**协议，能实现**可靠**的文件交换
	- 事务：指一系列信息交换（建立连接，发送请求，响应请求，展示信息并断开请求），这一系列信息交换是一个不可分割的整体
	- 可靠：传输层是基于TCP协议的可靠传输
- HTTP永远是浏览器端向服务器端发送请求，服务器端对浏览器端响应；无法实现浏览器端没有发送请求时，服务器端主动向浏览器端发送信息
- HTTP协议是**无状态**的协议，同一个客户端的本次连接服务器和下一次的连接服务器没有任何联系，服务器没有记忆功能
- HTTP协议本身是**无连接**的，每个连接只能处理一个请求，服务器处理完客户端的请求并收到客户端的应答后就会立即断开连接
- 工作流程：
	![[HTTP工作流程.jpg]]

## HTML

- HTML（HyperText Markup Language）：用来编写超文本文档，浏览器能识别
- 该语言中定义了需要使用的排版命令，即**标签**
- 使用HTML编写的文档为超文本，后缀`.html`或`.htm`
- 浏览器主要解析超文本，能将相关标签解析成界面

### 标签

- 格式：`<关键字>`
- 分类：
	- 单标签（空标签）：`<标签名/>`，如`<br/>`
	- 双标签：`<标签名>内容</标签名>`，如`<body>内容</body>`

### HTML文档

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>一级标题</h1>
    <a href="google.com">google 一下</a>
    <br>
    账号：<input type="text">
    <br>
    密码：<input type="text">
</body>
</html>
```

# HTTP版本

## HTTP 1.0

上世纪90年代开始，浏览器诞生后的第一个标准，**短链接**版本

该版本的很大的一个问题：每发起一个请求都要建立一次TCP的连接，而且是串行请求，做了很多无用的TCP连接和断开，增加了开销；并且一般请求时使用的是明文模式，容易被攻击，安全性能比较低

## HTTP 1.1

> 常用版本

- 增加了持续连接功能，服务器在响应后的一段时间内仍然保持连接，使客户端和服务器在这条连接上继续后续的请求和响应工作，直到某一端主动断开或长时间不响应
- 支持两种工作模式：
	- 非流水线方式：客户端在收到前一个响应之后才能发出下一个请求
	- 流水线方式：客户端在收到前一个响应之前就能直接发送下一个请求
- 特点：简单（只有报文头部和报文内容），灵活易于扩展（请求方法和状态码不固定）
- 不足：依然是无状态，明文传输，不安全

### 优化

- **长连接方式**，解决了1.0版本的短链接的性能问题，只要没有一端主动提出断开连接，会一直保持TCP连接状态
- 使用**管道**网络传输：允许在同一个TCP连接中建立多个管道，客户端可以发送多个请求，无需等待上一个请求的响应，提高了整体的响应时间，解决了请求的队头阻塞，但是服务器会按照请求的顺序发送这些请求的响应，若第一个请求处理了很长时间，后面的请求也会阻塞等待，即响应队头阻塞；1.1的管道化技术不是默认开启，且很多浏览器不支持

### 缺陷

- 头部巨大：HTTP头部含有很多固定的子段，加起来由几百上千字节，未压缩直接发送，大量的请求和响应报文中会有很多重复子段
	- HTTP是无状态的，要记录上次操作，需要在首部加一个cookie
	- 1.1版本传输请求和响应的过程使用的是ASCII编码而不是二进制编码
- 并发连接数有限，如谷歌是6个，且每个连接都要经过TCP的三次握手和慢启动过程
- 响应对头阻塞问题没有解决
- 不支持服务器推送功能，只能客户端请求，服务器响应

## HTTP 2.0

- 2015年推出，改善了HTTP的性能，兼容了1.1版本
- 只在应用层做出改变，传输层仍然是TCP协议

### 优化

- 2.0把HTTP分为**语义**和**语法**两部分，语义层基本不做改动，语法层有很多改动，基本改变了1.1的报文传输格式
- 2.0使用**HPACK算法**完成了头部**压缩**，发送的是压缩后的内容，解决了1.1版本头部巨大的问题；HPACK算法将传输过程中的同一个TCP传输内容进行合并，**去重**，提高了传输效率
- 能实现**并发传输**：引入**stream**概念，可以实现并发发送stream，只需要建立一个TCP连接，节约了多个TCP连接的时间开销
- 实现了**数据推送功能**，服务器端和客户端双方都会建立一个stream，使用stream ID区分，客户端建立的是奇数号，服务器是偶数号；服务器推送数据时，会先发送PUSH_PROMISE帧，告诉客户端哪个stream发送资源

### 缺陷

- TCP服务的缺陷：从根本上解决问题，需要改变传输层协议
	- 也存在响应队头阻塞
	- TCP的握手延时问题没有解决
	- 网络迁移时需要重新连接；服务器和客户端建立连接要素：源IP地址，源端口号，目标IP地址，目标端口号

## HTTP 3.0

- 最新推出的版本

### 优化

- 传输层将TCP协议换为UDP协议，使用基于UDP的**QUIC**协议
	- UDP：面向无连接，不关心是否丢包问题，解决了响应队头阻塞问题
	- QUIC：基于UDP实现的面向无连接，不需要进行三次握手和四次挥手，在协议中实现了类似于TCP的连接管理，拥塞控制，流量控制等相关操作，可靠的传输协议
- QUIC中也有**stream**概念，保证数据可靠性，每个stream数据包都有一个ID，一个数据包丢失后会重传，不影响其他数据包的传输
- 能实现更快的连接建立，QUIC也需要握手连接，基于一个**stream ID**进行连接，而不是四元组（IP地址，源端口号，目标IP地址，目标端口号）
- 基于stream ID的连接，可以实现在不同网络下的**迁移**

## HTTPS

- 1.1版本开始支持
- 为了传输的安全性，引入HTTPS，加密的超文本传输协议
- 在HTTP层和TCP层之间加入TLS协议，该协议提供了信息加密，校验机制，身份证数字证书
- TLS需要四次握手机制：
	1. 客户端向服务器发送随机数c，TLS协议版本号，密钥套件系列表
	2. 服务器向客户端发送一个ACK
	3. 服务器向客户端发送随机数s，确认TLS协议版本号，使用的密钥套件
	4. 客户端向服务器发送一个ACK
	注意：TLS的四次握手是发生在TCP的三次握手建立连接之后执行的安全性检查。是一个耗时操作，但是确保了信息的安全性

![[HTTP版本.jpg]]

# 保存HTTP状态

使用会话跟踪技术（cookie和session）保存HTTP状态

## cookie

cookie保存在客户端，通过请求报文中的`Set-Cookie`字段发送cookie，一个客户端绑定一个cookie的通行证

若不设置cookie的保存时间，cookie只保存到浏览器会话结束

## session

session保存在服务器端，通过唯一的sessionID查找对应的session，可以用map实现，客户端可以通过cookie发送sessionID

# HTTP报文格式

- HTTP报文分为两类：
	- 请求报文：客户端发送到服务器端
	- 响应报文：服务器端发送到客户端
- 报文由三部分组成：
	- 开始行：用于区分请求报文还是响应报文
		- 请求报文的开始行也是请求行
		- 响应报文的开始行也是状态行
	- 首部行：用来说明浏览器，服务器，报文主体的一些信息
		- 可以多行或没有
		- 在每一个首部行都有一个首部的**字段名**和它的**值**，中间使用冒号隔开，每一行的首部行中间使用回车换行隔开
		- 整个首部行结束后，还有一个空行将首部行和后面的实体主体进行分割
	- 实体主体：在请求报文中一般不用，有时响应报文可以没有

## 请求报文

![[请求报文.jpg]]

- 请求方法：对所请求的对象进行操作，实际上是一些操作指令；报文类型由请求方法决定
	- `GET`：请求URL的资源，并返回响应的实体主体
	- `POST`：向指定的URL提交数据（如表单或文件）并进行处理；数据被包含在实体主体部分
	- `HEAD`：类似于`GET`请求，但返回的是响应中的首部，没有内容主体
	- `PUT`：向服务器发送指定的文档
	- `DELETE`：请求服务器删除某些页面
	- `OPTION`：请求一些选项的信息
	- `TRACE`：用来进行环回测试
	- `CONNECT`：1.1版本中预留给能够将连接改为管道方式的代理服务
- URL：要申请的资源路径
- 版本：HTTP版本，常用的是1.1版本
- 字段：
	- `Connection`：`keep-alive`为长连接，`close`为短连接
	- `Content-length`：实体主体长度
	- `Host`：主机ip
	- `Set-Cookie`：后面的指为cookie

![[请求报文实例.jpg]]

## 响应报文

![[响应报文.jpg]]

- 版本：HTTP版本，常用的是1.1版本
- 状态码：由三位数字组成，第一位数字定义了响应的类别，分为5类
	- `1xx`：指示信息，表示请求已接收，继续处理
	- `2xx`：成功，表示请求已被成功接收，理解，处理，如`200`
	- `3xx`：重定向，表示要完成请求必须要进行更进一步的操作，如`304`
	- `4xx`：客户端错误，请求的语法错误或者请求无法实现
		- `432`：HTTP错误
		- `400`：客户端请求有语法错误，不能被服务器所解析
		- `401`：认证失败，请求未被接受
		- `403`：服务器收到请求，但是拒绝提供服务
		- `404`：请求的资源不存在
		- `405`：请求方法不被允许
	- `5xx`：服务器错误，表示服务器未能实现合法的请求
		- `500`：服务器发生了不可预测的错误
		- `503`：服务器不能处理当前客户端的请求，一段时间后可能恢复正常
- 短语：解释状态码
- 实体主体：若服务器需要向客户端发送数据，需要将数据放在该处

![[响应报文实例.jpg]]

# HTTP服务器

## 模型

![[HTTP服务器模型.jpg]]

## 实现

### 后端

```Cpp title:"Server.h"
#pragma once
#include <myHead.h>
#include <pthread.h>

#define BUF_SIZE 4096
#define HTML_SIZE (64*1024)

class Server {
public:
    Server();

    //设置端口号，无需设置返回false
    int setPort(int argc, char* argv[]);

    //初始化服务器：绑定地址信息，开启监听
    int init();

    //循环接收客户端连接请求，多线程实现并发服务器
    int solve();

    //处理客户端消息
    int msg_handler(int msg_socket);

    //响应错误信息
    void echo_error(int sock, int errcode);

    //响应404
    int show_404(int sock);

    //响应www
    int show_www(int sock, const char* path);

    //响应有request的请求
    int requst_handle(int sock, const char* method, const char* addi_query);

    //解析并处理请求的实体主体
    int parse_and_process(int sock, const char* addi_query, char* content);
private:
    int port;    //端口号
    int lis_socket;    //监听用的套接字

};

//要传给线程体函数的参数
struct argData {
    int msg_socket;    //通信用的套接字
    Server* p;    //成员所在的对象
};

//线程体函数
static void* msg_request(void* arg);

//从套接字获取一行数据
static int get_line(int sock, char* buf);

//清除头部
static int clear_header(int sock);

//处理求和请求
static int handle_add(int sock, const char* content);

//处理登录请求
static int handle_login(int sock, char* content);#pragma once
#include <myHead.h>
#include <pthread.h>

#define BUF_SIZE 4096
#define HTML_SIZE (64*1024)

class Server {
public:
    Server();

    //设置端口号，无需设置返回false
    int setPort(int argc, char* argv[]);

    //初始化服务器：绑定地址信息，开启监听
    int init();

    //循环接收客户端连接请求，多线程实现并发服务器
    int solve();

    //处理客户端消息
    int msg_handler(int msg_socket);

    //响应错误信息
    void echo_error(int sock, int errcode);

    //响应404
    int show_404(int sock);

    //响应www
    int show_www(int sock, const char* path);

    //响应有request的请求
    int requst_handle(int sock, const char* method, const char* addi_query);

    //解析并处理请求的实体主体
    int parse_and_process(int sock, const char* addi_query, char* content);
private:
    int port;    //端口号
    int lis_socket;    //监听用的套接字

};

//要传给线程体函数的参数
struct argData {
    int msg_socket;    //通信用的套接字
    Server* p;    //成员所在的对象
};

//线程体函数
static void* msg_request(void* arg);

//从套接字获取一行数据
static int get_line(int sock, char* buf);

//清除头部
static int clear_header(int sock);

//处理求和请求
static int handle_add(int sock, const char* content);

//处理登录请求
static int handle_login(int sock, char* content);
```

```Cpp title:"Server.cpp"
#include "Server.h"

Server::Server() {
    port = 80;    //端口号默认为80
}

int Server::setPort(int argc, char* argv[]) {
    if (argc == 1)return -1;
    port = atoi(argv[1]);
    return 0;
}

int Server::init() {
    //创建用于监听的套接字
    if ((lis_socket = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("socket error");
        return -1;
    }

#if 1 //设置地址快速复用
    int reuse = 1;
    if (setsockopt(lis_socket, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
        perror("setsockopt error");
        return -1;
    }
#endif

    //绑定地址信息
    sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = INADDR_ANY;    //将套接字绑定到所有可用接口上
    if (bind(lis_socket, (const sockaddr*)(&sin), sizeof(sin)) == -1) {
        perror("bind server addr error");
        return -1;
    }

    //启动监听
    if (listen(lis_socket, 128) == -1) {
        perror("listen error");
        return -1;
    }

    return 0;
}

int Server::solve() {
    while (true) {

        //客户端地址信息
        sockaddr_in peer;
        socklen_t socklen;

        //接收客户端连接请求
        printf("wait for client...\n");
        int newfd = accept(lis_socket, (sockaddr*)(&peer), &socklen);
        if (newfd == -1) {
            perror("accept error");
            return -1;
        }
        printf("new client connected : [%s:%d]\n",
            inet_ntoa(peer.sin_addr), ntohs(peer.sin_port));

        //创建线程处理客户端数据收发
        pthread_t tid;
        argData a = { newfd,this };
        if (pthread_create(&tid, nullptr, msg_request, &a) != 0) {
            printf("pthread_create error\n");
            return -1;
        }
        pthread_detach(tid);

    }
}

//线程体函数
static void* msg_request(void* arg) {
    int msg_socket = ((argData*)arg)->msg_socket;
    ((argData*)arg)->p->msg_handler(msg_socket);
}

int Server::msg_handler(int msg_socket) {

    //接收HTTP请求
    char buf[BUF_SIZE] = "";
    int res = recv(msg_socket, buf, BUF_SIZE, MSG_PEEK);

#if 0    //预览请求报文
    printf("----------报文------------\n");
    printf("%s\n", buf);
    printf("-------------------------\n");
#endif

    /*----解析请求行----*/

    memset(buf, 0, sizeof(buf));

    //获取请求行
    int count = get_line(msg_socket, buf);
    if (count == -1) {
        perror("msg_handler get_line error");
        return -1;
    }

    //解析请求方法
    char method[32] = "";
    int i = 0;
    int k = 0;
    for (;i < count;i++) {
        if (buf[i] == ' ') {
            buf[i++] = 0;
            break;
        }
        method[k++] = buf[i];
    }
    method[k] = 0;
    while (i < BUF_SIZE && buf[i] == ' ')i++;    //跳过空格

    //解析URL
    char url[BUF_SIZE] = "";
    char* addi_query = nullptr;    //附带数据，在'?'后面
    k = 0;
    for (;i < count;i++) {
        if (buf[i] == ' ') {
            buf[i++] = 0;
            break;
        }
        if (buf[i] == '?') {
            addi_query = &buf[i];
            addi_query++;
            url[k++] = 0;
        }
        else {
            url[k++] = buf[i];
        }
    }
    url[k] = 0;
#if 0
    printf("method = %s ; url = %s ; addi_query - %s\n", method, url, addi_query);
#endif

    /*----处理方式----*/

    //是否需要手动处理
    bool need_handle = false;

    if (strcasecmp(method, "GET") != 0 && strcasecmp(method, "POST") != 0) {     //不合法的请求方法
        printf("method error");
        echo_error(msg_socket, 405);
        return -1;
    }

    /*----需要手动处理的情况----*/

    //POST请求，需要手动处理
    if (strcasecmp(method, "POST") == 0) {
        need_handle = true;
    }
    //GET请求，且有附加数据，需要手动处理
    //如：http://192.168.200.200:8080/index.html?tt=234，需要进行额外的处理
    if (strcasecmp(method, "GET") == 0 && addi_query != nullptr) {
        need_handle = true;
    }

    /*----固定资源路径----*/
    char path[BUF_SIZE] = "";
    sprintf(path, "../wwwroot%s", url);
    //若请求的地址没有携带任何资源
    if (path[strlen(path) - 1] == '/') {
        strcat(path, "index.html");    //默认返回index.html
    }
    //若文件不存在
    if (access(path, F_OK) == -1) {
        printf("can not find file : %s\n", path);
        echo_error(msg_socket, 404);
        return -1;
    }

#if 0
    printf("need_handle=%d ; path = %s\n", need_handle, path);
#endif
    /*----响应HTTP请求----*/
    if (need_handle) {
        requst_handle(msg_socket, method, addi_query);
    }
    else {
        show_www(msg_socket, path);
    }

    close(msg_socket);
}

static int get_line(int sock, char* buf) {
    char ch = 0;    //用于从套接字中读取一个字符
    int i = 0;     //下标
    while (i < BUF_SIZE && ch != '\n') {
        int res = recv(sock, &ch, 1, 0);
        if (res == -1) {
            perror("get_line recv error");
            return -1;
        }
        //读到一个'\r'
        if (res > 0 && ch == '\r') {
            res = recv(sock, &ch, 1, MSG_PEEK);
            if (res == -1) {
                perror("get_line recv error");
                return -1;
            }
            //'\r'的下一个是'\n'
            if (res > 0 && ch == '\n') {
                res = recv(sock, &ch, 1, 0);
                if (res == -1) {
                    perror("recv error");
                    return -1;
                }
            }
            else ch = '\n';
        }
        buf[i++] = ch;
    }
    buf[i] = 0;
    return i;
}

void Server::echo_error(int sock, int errcode) {
    switch (errcode) {
    case 404:
        show_404(sock);
        break;
    case 405:

        break;
    case 500:

        break;
    default:
        break;
    }
}

int Server::show_404(int sock) {
    clear_header(sock);
    /*----发送状态行----*/

    //状态行
    const char* msg = "HTTP/1.1 404 Not Found\r\n\r\n";
    if (send(sock, msg, strlen(msg), 0) == -1) {
        printf("show_404 send error\n");
        return -1;
    }

    /*----发送响应实体----*/

    const char* path = "../wwwroot/404.html";
    struct stat st;
    if (stat(path, &st) == -1) {    //若文件不存在
        printf("can not find file : %s\n", path);
        return -1;
    }
    int fd = open(path, O_RDONLY);
    if (fd == -1) {
        perror("open 404.html error\n");
        return -1;
    }
    int res = sendfile(sock, fd, nullptr, st.st_size);
    if (res == -1) {
        perror("show_404 sendfile error");
        return -1;
    }
    close(fd);
    return 0;
}

static int clear_header(int sock) {
    char buf[BUF_SIZE] = "";
    int res = -1;
    do {
        res = get_line(sock, buf);
        if (res == -1) {
            printf("clear_head get_line error");
            return -1;
        }
    } while (res > 1 && strcmp(buf, "\n") != 0);

    return 0;
}

int Server::show_www(int sock, const char* path) {
    clear_header(sock);

    /*----状态行----*/

    const char* msg = "HTTP/1.1 200 OK\r\n\r\n";
    if (send(sock, msg, strlen(msg), 0) == -1) {
        perror("echo_www send error");
        return -1;
    }
    /*----响应实体----*/

    int fd = open(path, O_RDONLY);
    if (fd == -1) {
        perror("echo_www open error");
        return -1;
    }
    struct stat st;
    stat(path, &st);
    if (sendfile(sock, fd, nullptr, st.st_size) == -1) {
        perror("echo_www sendfile error");
        echo_error(sock, 500);
        return -1;
    }

    close(fd);
    return 0;
}

int Server::requst_handle(int sock, const char* method, const char* addi_query) {

    char line[BUF_SIZE] = "";    //用于读取一行数据
    char content[BUF_SIZE] = "";
    int res;    //用于接收读取返回值
    int content_len = -1;    //实体主体长度

    /*--------判断是GET请求还是POST请求--------*/

    if (strcasecmp(method, "GET") == 0) {    //GET请求
        clear_header(sock);    //没有实体主体，直接清空头部
    }
    else {    //POST请求

        //获取POST请求的参数大小content-length
        do {
            res = get_line(sock, line);
            //如字段：Content-Length: 16，16前面有一个空格和一个:
            if (strncasecmp(line, "content-length", strlen("content-length")) == 0) {
                content_len = atoi(line + strlen("content-length") + 2);
            }  //此处不能break，因为要将请求首部读完，才能读到实体主体
        } while (res != 1 && strcmp(line, "\n") != 0);

        //解析实体主体
        res = recv(sock, content, content_len, 0);
        if (res == -1) {
            perror("request_handle recv content error");
            return -1;
        }
    }

#if 1    //打印相关信息
    printf("method=%s ; addi_query=%s ; content_len=%d ; content=%s \n", method, addi_query, content_len, content);
#endif

    /*--------响应--------*/

    //发送状态行
    const char* msg = "HTTP/1.1 200 OK\r\n\r\n";
    if (send(sock, msg, strlen(msg), 0) == -1) {
        perror("send error");
        return -1;
    }

    //解析并处理实体主体
    parse_and_process(sock, addi_query, content);
}

static int handle_add(int sock, const char* content) {
    int num1, num2;

    //在content中解析出num1和num2
    sscanf(content, "\"data1=%ddata2=%d\"", &num1, &num2);
    printf("num1=%d num2=%d\n", num1, num2);

    //发送响应的实体主体
    char reply[HTML_SIZE] = "";
    sprintf(reply, "%d", num1 + num2);
    printf("reply=%s\n", reply);
    if (send(sock, reply, strlen(reply), 0) == -1) {
        perror("send reply error");
        return -1;
    }
    return 0;
}

static int handle_login(int sock, char* content) {

    //解析用户名
    char* uname = strstr(content, "username=");
    uname += strlen("username=");
    char* ptr = strstr(content, "password=");
    *(ptr - 1) = 0;
    char* pwd = ptr + strlen("password=");
    printf("uname=%s  pwd=%s\n", uname, pwd);

    //校对用户名和密码
    if (strcmp(uname, pwd) == 0) {    //用户名和密码一样
        //发送响应的实体主体
        char reply[HTML_SIZE] = "";
        sprintf(reply, "<script>localStorage.setItem('usr_user_name', '%s');</script>", uname);
        strcat(reply, "<script>window.location.href='/index.html';</script>");
        if (send(sock, reply, strlen(reply), 0) == -1) {
            perror("send error");
            return -1;
        }
    }

    return 0;
}

int Server::parse_and_process(int sock, const char* addi_query, char* content) {
    if (strstr(content, "data1=") && strstr(content, "data2=")) {    //求和请求
        return handle_add(sock, content);
    }
    else if (strstr(content, "username=") && strstr(content, "password=")) {    //登录请求
        return handle_login(sock, content);
    }
    return 0;
}
```

```Cpp title:"main.cpp"
#include <myHead.h>
#include "Server.h"

int main(int argc, char* argv[]) {
    //创建Server实例
    Server server;

    //设置端口号
    server.setPort(argc, argv);

    //初始化服务器
    server.init();

    //循环接收客户端连接请求
    server.solve();
    return 0;
}
```

### 前端

```html title:"404.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 Not Found</title>
</head>
<body>
    <h1>404 Not Found</h1>
</body>
</html>
```

```html title:"index.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>欢迎来到mofei的温馨小屋~</h1>
</body>
</html>
```

```html title:"login.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>login</title>

</head>
<body>
    <div>
        <h1>表单完成POST请求</h1>

        <div class="login-form">
            <form method="post">
                
                <input type="text" name="username" id="usr" value="" placeholder="input account">
                <input type="password" name="password" id="pwd" value="" placeholder="input password">
                <input type="submit" class="button" value="login">

            </form>
        </div>

    </div>
</body>
</html>
```

```html title:"post.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>POST请求测试</title>

    <script>
        function sendPOSTRequest()
        {
            var xhr = new XMLHttpRequest();    //创建一个XMLHttpRequest对象
            var url = "";     //请求的url，这个目前可以不写

            //获取当前ui界面上的数据
            data = "data1=" + document.getElementById("data1").value + "data2=" + document.getElementById("data2").value;

            console.log("req = " + data);      //在网页终端上显示
            //配置POST请求
            xhr.open("POST", url, true);     //配置请求：POST方法，URL，异步请求

            xhr.onreadystatechange = function()
            {
                if(xhr.readyState===4 && xhr.status===200)
                {
                    var response = xhr.responseText;       //获取响应的数据
                    console.log("req = " + response);
                    document.getElementById("sum").value = response;
                }
            };

            //将当前界面的信息发送给服务器
            xhr.send(JSON.stringify(data));    //发送请求数据并将其转换为JSON格式
        }

    </script>

</head>
<body>
    
    data1: <input type="text" id="data1" value="1"> <br>
    data2: <input type="text" id="data2" value="2"> <br>
    求和： <input type="text" id="sum" placeholder="在此处显示和"><br><br>
    <button onclick="sendPOSTRequest()">求和</button>

</body>
</html>
```