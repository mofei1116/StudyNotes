# TFTP传输模型

> TFTP（trivial file transfer protocol）：简单文件传输协议

**基于UDP**的TFTP文件传输模型：用于在网络上进行文件传输，设计简单，易于实现，通常在传输小文件或在不支持复杂协议的环境中使用

## TFTP协议

- 使用UDP作为传输层协议，默认端口号为69
- 设计简单，仅支持五种类型的报文：
	1.  RRQ（read requst）：客户端请求读取文件
	2.  WRQ（write requst）：客户端请求写入文件
	3.  DATA：数据传输报文
	4.  ACK：确认报文
	5.  ERROR：错误报文

## 通信流程

TFTP的通信流程分为请求阶段和传输阶段

### 请求阶段

1. 客户端发送RRQ或WRQ报文，请求读取或写入文件；RRQ报文包括文件名和传输模式（通常是**netascii**或**octet**），WRQ报文类似
2. 服务器响应：服务器接收到RRQ或WRQ报文后，会分配一个新的UDP端口用于数据传输，并发送ACK（对于WRQ）或直接发送DATA（对于RRQ）作为响应

### 传输阶段

- 每个DATA报文包含一个块编号和数据块
	- 块编号：每个DATA报文和ACK报文都包含一个16位（2字节）的块编号，编号从1开始递增，块编号用于确保数据的有序传输和确认

- 对于RRQ请求，服务器开始发送DATA报文，客户端收到DATA报文后发送ACK报文确认收到的块编号
- 对于WRQ请求，客户端发送DATA报文，服务器发送ACK确认
- 结束传输：DATA报文的数据块部分小于512字节，即传输的数据大小小于512字节，表示传输结束

## 报文格式

![[TFTP报文格式.jpg]]

错误码：
- `0`：未定义，差错错误信息
- `1`：File Not Found
- `2`：违反规定
- `3`：磁盘满或分配超出
- `4`：非法操作
- `5`：未知的传输id
- `7`：没有该用户

封装和解析报文需要注意**网络字节序**的转换

# CS传输模型

![[TFTP传输模型.jpg]]

## 客户端

### 主程序

![[客户端主程序流程.jpg]]

### 上传文件

![[客户端上传文件.jpg]]

### 下载文件

![[客户端下载.jpg]]

### 实现

```Cpp title:"Client.h"
#pragma once

#include <myHead.h>
#include <string>

using namespace std;

class Client {
private:
    static const short SERVER_PORT = 69;    //服务器端口号
    static const int BUFFER_SIZE = 516;    //协议包大小，2+2+512
    sockaddr_in server_addr;    //服务器地址信息结构体

    int cfd;    //客户端套接字

    void ShowMenu();    //展示菜单
    int do_download();    //下载文件
    int do_upload();    //上传文件
    void ClearScreen();    //手动清空屏幕
    void WaitForInput();    //等待输入，用于清除垃圾字符
public:
    Client(const string& serverIP);    //构造函数
    ~Client();    //析构函数
    void run();    //执行客户端

};
```

```Cpp title:"Client.cpp"
#include "Client.h"

//打印错误信息
//输出当前代码的行号，当前所在的函数名，当前源文件的文件名
#define ERR_LOG(msg) do{\
    perror(msg);\
    cout << __LINE__ << " " << __func__ << " " << __FILE__ << endl;\
}while (0)

Client::Client(const string& serverIP) {

    //创建套接字
    cfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (cfd == -1) {
        ERR_LOG("sock error");
        return;
    }

    //设置服务器地址信息
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    server_addr.sin_addr.s_addr = inet_addr(serverIP.c_str());
}

Client::~Client() {

    //关闭客户端套接字
    if (cfd != -1) {
        close(cfd);
        cfd = -1;
    }
}

void Client::run() {
    while (true) {

        //展示菜单
        ShowMenu();

        //输入选项
        char choice;    //要输入的选项
        cin >> choice;
        WaitForInput();    //吸收回车，防止影响下一次读入

        switch (choice) {
        case '1':
            do_upload();
            break;
        case '2':
            do_download();
            break;
        case '3':    //退出
            return;
        default:
            cout << "输入有误，重新输入" << endl;
            break;
        }

        //手动清屏
        ClearScreen();
    }
}

void Client::ShowMenu() {
    system("clear");
    cout << "*******************[基于UDP的TFTP文件传输客户端]****************" << endl;
    cout << "[                           1.上传                             ]" << endl;
    cout << "[                           2.下载                             ]" << endl;
    cout << "[                           3.退出                             ]" << endl;
    cout << "***************************************************************" << endl;

}

int Client::do_download() {

    string filename;    //文件名

    //输入文件名
    cout << "输入要下载的文件名:";
    getline(cin, filename);

    //封装RRQ请求报文
    char buf[BUFFER_SIZE] = "";
    int size = sprintf(buf, "%c%c%s%c%s%c", 0, 1, filename.c_str(), 0, "octet", 0);

    //向服务器发送请求
    if (sendto(cfd, buf, size, 0, (const sockaddr*)(&server_addr), sizeof(server_addr)) == -1) {
        ERR_LOG("sendto error");
        return -1;
    }

    sockaddr_in sin;    //用于接收服务器地址信息
    socklen_t socklen = sizeof(sin);    //地址信息结构体长度
    size_t recv_len = 0;    //接收到的报文大小
    int fd = -1;    //接收下载的文件的文件描述符
    bool open_flag = false;    //文件是否打开
    unsigned short num = 0;    //已接收到的DATA报文个数

    //循环接收DATA报文
    while (true) {
        memset(buf, 0, BUFFER_SIZE);    //清空buf
        recv_len = recvfrom(cfd, buf, BUFFER_SIZE, 0, (sockaddr*)(&sin), &socklen);
        if (recv_len == -1) {    //接收DATA报文
            ERR_LOG("recvfrom error");
            return -1;
        }

        //解析收到的包
        if (buf[1] == 3) {    //是DATA包

            //判断fd是否打开
            if (!open_flag) {    //没有打开，需要打开fd
                fd = open(filename.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
                if (fd == -1) {
                    ERR_LOG("open error");
                    return -1;
                }
                open_flag = true;
            }

            //判断块编号是否正确
            if (htons(num + 1) == *((unsigned short*)(buf + 2))) {    //块编号正确，写入fd
                num++;
                if (write(fd, buf + 4, recv_len - 4) == -1) {
                    ERR_LOG("write error");
                    if (open_flag)close(fd);
                    return -1;
                }
            }

            //组装并发送ACK包
            buf[1] = 4;
            *(unsigned short*)(buf + 2) = htons(num);
            if (sendto(cfd, buf, 4, 0, (const sockaddr*)(&sin), socklen) == -1) {
                ERR_LOG("sendto error");
                if (open_flag)close(fd);
                return -1;
            }

            //判断是否是最后一个包
            if (recv_len - 4 < BUFFER_SIZE) {
                cout << "文件下载完成" << endl;
                break;
            }
        }
        else if (buf[1] == 5) {    //是ERROR包
            short errcode = *((short*)(buf + 2));    //错误码
            string err_msg = (char*)(buf + 4);    //错误信息
            cout << "______errcode:" << errcode << "_____err_msg:" << err_msg << endl;
            break;
        }
    }

    if (open_flag)close(fd);
    return 0;
}

int Client::do_upload() {
    string filename;    //文件名

    //输入文件名
    cout << "输入要上传的文件名:";
    getline(cin, filename);

    //检测文件是否存在
    int fd = open(filename.c_str(), O_RDONLY);
    if (fd == -1) {
        if (errno == ENOENT) {    //文件不存在
            cout << "文件不存在" << endl;
            return -2;
        }
        else {
            ERR_LOG("open error");
            return -1;
        }
    }

    //封装WRQ请求报文
    char buf[BUFFER_SIZE];
    int size = sprintf(buf, "%c%c%s%c%s%c", 0, 2, filename.c_str(), 0, "octet", 0);

    //向服务器发送请求
    if (sendto(cfd, buf, size, 0, (const sockaddr*)(&server_addr), sizeof(server_addr)) == -1) {
        ERR_LOG("sendto error");
        return -1;
    }

    sockaddr_in sin;    //用于接收服务器地址信息
    socklen_t socklen = sizeof(sin);    //地址信息结构体长度
    size_t recv_len;    //接收到的报文大小

    unsigned short num = 0;    //已发送的DATA报文个数

    //循环接收ACK报文
    while (true) {
        memset(buf, 0, sizeof(buf));
        recv_len = recvfrom(cfd, buf, BUFFER_SIZE, 0, (sockaddr*)(&sin), &socklen);    //接收报文
        if (recv_len == -1) {
            perror("recvfrom error");
            return -1;
        }

        if (buf[1] == 4) {    //是ACK报文

            int res = 0;
            //检查块编号
            if (htons(num) == *(unsigned short*)(buf + 2)) {    //块编号正确，发送下一个数据包
                num++;
                res = read(fd, buf + 4, BUFFER_SIZE - 4);
                if (res == -1) {
                    ERR_LOG("read error");
                    return -1;
                }
                if (res == 0) {    //文件已经发送完了
                    cout << "文件上传成功" << endl;
                    break;
                }
            }

            //发送DATA包
            buf[1] = 3;
            *(unsigned short*)(buf + 2) = htons(num);    //修改块编号
            if (sendto(cfd, buf, res + 4, 0, (const sockaddr*)(&sin), socklen) == -1) {
                ERR_LOG("sendto error");
                return -1;
            }
        }
        else if (buf[1] == 5) {    //是ERROR报文
            cout << "文件上传失败，请检查网络" << endl;
            break;
        }
    }

    close(fd);
    return 0;
}

void Client::ClearScreen() {
    cout << "输入任意字符清屏" << endl;
    while (getchar() != '\n');    //吸收任意字符
}

void Client::WaitForInput() {
    while (getchar() != '\n');
}
```

```Cpp title:"main.cpp"
#include "Client.h"

int main(int argc, char* argv[]) {

    string server_ip;    //服务器IP地址

    if (argc < 2) {
        cout << "请输入服务器IP地址:";
        cin >> server_ip;
    }
    else {
        server_ip = argv[1];
    }

    try {
        Client client(server_ip);    //实例化对象
        client.run();    //执行客户端
    }
    catch (const std::exception& e) {
        cerr << e.what() << endl;
    }

    return 0;
}
```

## 服务器端

### 主程序

![[服务器主程序.jpg]]

### 处理下载请求

![[服务器处理下载请求.jpg]]

### 处理上传请求

![[服务器端处理上传文件.jpg]]

### 实现

```Cpp title:"Server.h"
#pragma once

#include <myHead.h>
#include <string.h>

using namespace std;

class Server {
private:
    static const short PORT = 69;    //服务器端口号，需要有root权限
    static const int BUFFER_SIZE = 512;    //协议包大小

    int sfd;    //服务器套接字

    sockaddr_in server_addr;    //服务器地址信息
    string root_dir;    //文件服务根目录

    int handle_ReadRequst(const char* filename, const sockaddr_in& client_addr, socklen_t addr_len);    //处理下载请求
    int handle_WriteRequst(char* filename, const sockaddr_in& client_addr, socklen_t addr_len);    //处理上传请求
    int SendError(const char* msg, const sockaddr_in& client_addr);    //发送错误信息
public:
    Server(const string root_dir = "./");
    ~Server();
    int run();
};
```

```Cpp title:"Server.cpp"
#include "../head/Server.h"

//打印错误信息
//输出当前代码的行号，当前所在的函数名，当前源文件的文件名
#define ERR_LOG(msg) do{\
    perror(msg);\
    cout << __LINE__ << " " << __func__ << " " << __FILE__ << endl;\
}while (0)

Server::Server(const string root_dir) :root_dir(root_dir) {

    //创建用于通信的UDP套接字
    sfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sfd == -1) {
        ERR_LOG("socket error");
        return;
    }

    //构造服务器地址信息
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);

    //绑定地址信息
    if (bind(sfd, (const sockaddr*)(&server_addr), sizeof(server_addr)) == -1) {
        ERR_LOG("bind error");
        return;
    }

}

Server::~Server() {
    if (sfd != -1) {
        close(sfd);
        sfd = -1;
    }
}

int Server::run() {
    printf("server started on %d\nserver file is %s\n", PORT, root_dir.c_str());

    char buf[BUFFER_SIZE] = "";
    sockaddr_in client_addr;    //存放客户端地址信息
    socklen_t addr_len = sizeof(client_addr);    //地址信息结构体大小
    size_t recv_len;

    while (true) {
        recv_len = recvfrom(sfd, buf, BUFFER_SIZE, 0, (sockaddr*)(&client_addr), &addr_len);
        if (recv_len == -1) {
            ERR_LOG("recvfrom error");
            return -1;
        }

        //解析
        if (buf[0] != 0)continue;    //协议包错误
        char* filename = buf + 2;    //文件名
        const char* mode = filename + strlen(filename) + 1;    //协议模式
        if (strcasecmp(mode, "octet") != 0) {    //检查模式
            SendError("Only Binary Mode Supported\n", client_addr);    //发送错误信息
        }

        switch (buf[1]) {
        case 1:    //读请求
            printf("read requst for file : %s\n", filename);
            handle_ReadRequst(filename, client_addr, addr_len);
            break;
        case 2:    //写请求
            printf("write requst for file : %s\n", filename);
            handle_WriteRequst(filename, client_addr, addr_len);
            break;
        default:
            SendError("Unknow requst\n", client_addr);
        }
    }

    return 0;
}

int Server::handle_ReadRequst(const char* filename, const sockaddr_in& client_addr, socklen_t addr_len) {

    string full_path = root_dir + '/' + filename;    //完整路径

    //打开文件
    int fd = open(full_path.c_str(), O_RDONLY);
    if (fd == -1) {
        if (errno == ENOENT) {    //文件不存在
            SendError("File Not Found", client_addr);
            return -2;
        }
        else {
            ERR_LOG("open error");
            return -1;
        }
    }

    char buf[BUFFER_SIZE] = "";    //数据包
    unsigned short num = 0;    //数据块编号
    size_t recv_len = 0;    //接收到的字节数

    //循环发送数据包
    while (true) {

        //封装数据包
        buf[1] = 3;
        num++;
        *(unsigned short*)(buf + 2) = htons(num);
        int res = read(fd, buf + 4, BUFFER_SIZE - 4);
        if (res == -1) {
            SendError("read error", client_addr);
            ERR_LOG("read error");
            if (fd != -1) {
                close(fd);
                fd = -1;
            }
            return -1;
        }

        //发送DATA包
        if (sendto(sfd, buf, 4 + res, 0, (const sockaddr*)(&client_addr), addr_len) == -1) {
            ERR_LOG("sendto error");
            if (fd != -1) {
                close(fd);
                fd = -1;
            }
            return -1;
        }

        //接收ACK包
        do {
            recv_len = recvfrom(sfd, buf, BUFFER_SIZE, 0, (sockaddr*)(&client_addr), &addr_len);
            if (recv_len == -1) {
                ERR_LOG("recvfrom error");
                if (fd != -1) {
                    close(fd);
                    fd = -1;
                }
                return -1;
            }
        } while (buf[1] != 4 || htons(num) != *(unsigned short*)(buf + 2));

        if (res < BUFFER_SIZE - 4) {    //文件下载完成
            cout << "客户端文件下载完成" << endl;
            break;
        }
    }

    if (fd != -1) {
        close(fd);
        fd = -1;
    }
    return 0;
}

int Server::handle_WriteRequst(char* filename, const sockaddr_in& client_addr, socklen_t addr_len) {

    string full_path = root_dir + '/' + filename;    //完整路径

    //打开文件
    int fd = open(full_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        SendError("Create File Error", client_addr);
        ERR_LOG("open error");
        return -1;
    }

    char buf[BUFFER_SIZE] = "";
    size_t recv_len = 0;
    unsigned short num = 0;    //接收到的数据包个数

    //发送第一个ACK包
    buf[1] = 4;
    *(unsigned short*)(buf + 2) = htons(num);
    if (sendto(sfd, buf, 4, 0, (const sockaddr*)(&client_addr), addr_len) == -1) {
        ERR_LOG("sendto error");
        if (fd != -1) {
            close(fd);
            fd = -1;
        }
        return -1;
    }

    while (true) {

        //接收DATA包
        recv_len = recvfrom(sfd, buf, BUFFER_SIZE, 0, (sockaddr*)(&client_addr), &addr_len);
        if (recv_len == -1) {
            ERR_LOG("recvfrom error");
            if (fd != -1) {
                close(fd);
                fd = -1;
            }
            return -1;
        }
        if (buf[1] == 3 || htons(num + 1) == *(unsigned short*)(buf + 2)) {    //块编号正确
            num++;
            if (write(fd, buf + 4, recv_len - 4) == -1) {    //写入文件
                ERR_LOG("write error");
                if (fd != -1) {
                    close(fd);
                    fd = -1;
                }
                return -1;
            }
        }

        //发送ACK包
        buf[1] = 4;
        *(unsigned short*)(buf + 2) = htons(num);
        if (sendto(sfd, buf, 4, 0, (const sockaddr*)(&client_addr), addr_len) == -1) {
            ERR_LOG("sendto error");
            if (fd != -1) {
                close(fd);
                fd = -1;
            }
            return -1;
        }

        if (recv_len < BUFFER_SIZE) {
            cout << "客户端上传文件完成" << endl;
            break;
        }

    }

    if (fd != -1) {
        close(fd);
        fd = -1;
    }
    return 0;
}

int Server::SendError(const char* msg, const sockaddr_in& client_addr) {

    //构造ERROR报文
    char buf[BUFFER_SIZE] = "";
    buf[1] = 5;
    buf[3] = 1;
    strcpy(buf + 4, msg);

    //发送ERROR报文，长度为5 + strlen(msg)，包含'\0'
    if (sendto(sfd, buf, 5 + strlen(msg), 0, (const sockaddr*)(&client_addr), sizeof(client_addr)) == -1) {
        ERR_LOG("sendto error");
        return -1;
    }

    return 0;
}
```

```Cpp title:"main.cpp"
#include "../head/Server.h"

int main(int argc, char* argv[]) {

    string root_dir = "./";    //文件服务根目录

    try {
        if (argc > 1)root_dir = argv[1];
        Server server(root_dir);
        server.run();
    }
    catch (const std::exception& e) {
        cout << e.what() << endl;
        return -1;
    }

    return 0;
}
```