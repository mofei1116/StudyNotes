# 线程池

## 基本概念

- 线程池是一种预先创建线程的机制，线程在应用程序启动时就创建好了，等待执行
- 当有新的任务需要执行，会从线程池中分配一个空闲的线程执行该任务

### 优点

- 提高性能：创建和销毁线程开销较大，通过重用现有线程，减少了开销
- 控制并发量：线程池允许限制并发线程的数量，防止系统因创建过多的线程而出现资源耗尽的情况，如CPU过载，内存不足
- 简化线程管理：使用线程池可以避免手动管理线程池的生命周期，减少代码复杂性；线程池提供了任务排队和任务调度功能，简化了多线程编程

### 使用场景

- 服务器应用：对于套接字通信或Web服务器
- 高性能的计算
- 异步任务处理：并行处理多个没有依赖关系的任务

## 封装线程池

```Cpp
#pragma once

#include <myHead.h>
#include <vector>
#include <thread>
#include <queue>
#include <condition_variable>
#include <mutex>
#include <functional>

using namespace std;

class ThreadPool {
private:
    vector<thread> workers;     //存储工作的线程容器
    queue<function<void()>> tasks;    //存储任务队列
    mutex task_mutex;    //互斥锁
    condition_variable task_cond;    //条件变量
    bool stop;    //线程池停止的标志

    void start_ThreadPool(size_t poolSize);    //启动线程池

public:
    ThreadPool(size_t pollSize);
    ~ThreadPool();

    void AddTask(function<void()> task);    //添加任务到线程
};
```

```Cpp
#include "ThreadPool.h"

ThreadPool::ThreadPool(size_t poolSize) :stop(false) {

    start_ThreadPool(poolSize);    //启动线程池
}

ThreadPool::~ThreadPool() {
    {
        unique_lock<mutex> lock(task_mutex);    //获取锁资源，保护stop变量，lock生命周期结束后自动unlock
        stop = true;
    }

    task_cond.notify_all();    //唤醒所有线程

    for (auto& worker : workers) {    //回收所有线程资源
        worker.join();
    }
}

void ThreadPool::AddTask(function<void()> task) {
    {
        unique_lock<mutex> lock(task_mutex);    //获取锁资源，保护条件变量
        tasks.push(task);
    }

    task_cond.notify_one();    //唤醒一个线程
}

void ThreadPool::start_ThreadPool(size_t poolSize) {

    //循环创建poolSize个线程
    for (int i = 0;i < poolSize;i++) {
        workers.emplace_back(thread([this] {    //线程体
            while (true) {

                function<void()> task;    //一次循环要执行的任务

                {
                    unique_lock<mutex> lock(task_mutex);    //上锁
                    task_cond.wait(lock, [this] {    //放入休眠队列
                        return stop || !tasks.empty();    //唤醒的附加条件
                        });
                    if (stop && tasks.empty())return;    //退出线程
                    task = tasks.front();
                    tasks.pop();
                }

                task();    //执行任务
            }
            }));
    }
}
```

# 基于TCP的网络聊天室

## 模型

![[聊天室服务器模型.jpg]]

## 实现

### 服务器端

```Cpp title="Server.h"
#pragma once

#include <myHead.h>
#include <vector>
#include <thread>
#include <queue>
#include <condition_variable>
#include <mutex>
#include <functional>
#include <algorithm>

using namespace std;

#define CONTENT_SIZE 128    //消息缓冲区大小
#define LOGIN 1    //登录消息类型
#define CHAT 2    //聊天消息类型
#define QUIT 3    //退出消息类型

class Server {
public:

    //消息结构体
    struct MSG {
        int type;    //消息类型
        char name[32];    //客户端名称
        char content[CONTENT_SIZE];    //文本内容

        //序列化函数，将结构体转为二进制
        string serialize()const {
            string data;
            data.append(reinterpret_cast<const char*>(&type), sizeof(type));    //将type强转为const char*类型存储
            data.append(name, sizeof(name));
            data.append(content, sizeof(content));

            return data;
        }

        //反序列化函数，将二进制转为结构体
        void deserialize(const string& data) {

            size_t offset = 0;    //字符偏移量

            memcpy(&type, data.c_str() + offset, sizeof(type));    //解析type
            offset += sizeof(type);
            memcpy(name, data.c_str() + offset, sizeof(name));    //解析name
            offset += sizeof(name);
            memcpy(content, data.c_str() + offset, sizeof(content));    //解析content
        }
    };

    //客户端结构体
    struct Client {
        int cfd;    //用于和客户端通信的套接字
        sockaddr_in cin;    //客户端地址信息
    };

private:

    int sfd;    //服务器套接字
    vector<Client> clients;    //在线客户端列表，是临界资源
    mutex client_mutex;    //用于保护客户端列表

    //线程池相关
    size_t pool_size;
    vector<thread> workers;     //存储工作的线程容器
    queue<function<void()>> tasks;    //存储任务队列
    mutex task_mutex;    //互斥锁
    condition_variable task_cond;    //条件变量
    bool stop;    //线程池停止的标志
    void start_ThreadPool();    //启动线程池
    void AddTask(function<void()> task);    //添加任务到线程

    // void ErrorLog(const char* msg);     //打印错误信息日志

public:

    Server(const char* ip, int port, size_t poolSize = 4);
    ~Server();
    void run();    //运行服务器
    void handle_client(Client& cli);    //处理客户端连接
    void BroadCast(const MSG& msg, int exclude_fd = -1);    //广播消息函数
};#pragma once

```

```Cpp title:"Server.cpp"
#include "../head/Server.h"

#define ERR_LOG(msg) do{\
    perror(msg);\
    cout << __LINE__ << " " << __func__ << " " << __FILE__ << endl;\
}while (0)

Server::Server(const char* ip, int port, size_t poolSize) :pool_size(poolSize), stop(false) {

    //创建服务器套接字
    sfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sfd == -1) {
        ERR_LOG("socket error");
        return;
    }

    //开启端口号快速复用
    int reuse = 1;
    if (setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
        ERR_LOG("setsockopt error");
        return;
    }

    //绑定地址信息
    sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = inet_addr(ip);
    if (bind(sfd, (const sockaddr*)(&sin), sizeof(sin)) == -1) {
        ERR_LOG("bind error");
        return;
    }

    //启动监听
    if (listen(sfd, 128) == -1) {
        ERR_LOG("listen error");
        return;
    }

    //启动线程池
    start_ThreadPool();

}

void Server::start_ThreadPool() {

    for (int i = 0;i < pool_size;i++) {
        workers.emplace_back(thread([this] {
            while (true) {
                function<void()> task;
                {
                    unique_lock<mutex> lock(task_mutex);    //上锁
                    task_cond.wait(lock, [this] {
                        return stop || !tasks.empty();
                        });
                    if (stop && tasks.empty())return;

                    task = tasks.front();
                    tasks.pop();
                }
                task();
            }
            }));
    }
}

Server::~Server() {
    {
        unique_lock<mutex> lock(task_mutex);
        stop = true;
        task_cond.notify_all();
    }

    //回收所有线程资源
    for (auto& worker : workers) {
        worker.join();
    }

    close(sfd);    //关闭服务器监听套接字
}

void Server::AddTask(function<void()> task) {
    unique_lock<mutex> lock(task_mutex);
    tasks.push(task);
    task_cond.notify_one();
}

void Server::run() {
    sockaddr_in cin;
    socklen_t addr_len;
    while (true) {
        int newfd = accept(sfd, (sockaddr*)(&cin), &addr_len);
        if (newfd == -1) {
            ERR_LOG("accept error");
            continue;
        }

        AddTask([this, newfd, cin] {
            Client cli{ newfd,cin };
            handle_client(cli);
            });
    }
}

void Server::handle_client(Client& cli) {
    MSG msg;    //存放反序列化后的消息
    char buf[sizeof(MSG)];    //用于接收消息
    int recv_len;    //接收到的消息大小

    while (true) {
        memset(buf, 0, sizeof(buf));
        recv_len = recv(cli.cfd, buf, sizeof(buf), 0);
        if (recv_len == 0) {    //客户端下线，等效于quit消息
            unique_lock<mutex> lock(client_mutex);    //上锁
            //移除下线的客户端
            for (auto it = clients.begin(); it != clients.end();it++) {
                if (it->cfd == cli.cfd) {
                    clients.erase(it);
                    break;
                }
            }
            close(cli.cfd);
            sprintf(msg.content, "--------%s quit------\n", msg.name);    //组装广播消息
            BroadCast(msg, cli.cfd);
            break;
        }
        else if (recv_len < 0) {
            ERR_LOG("recv error");
            continue;
        }
        msg.deserialize(string(buf, recv_len));    //反序列化

        switch (ntohl(msg.type)) {    //判断消息类型
        case LOGIN:     //登录消息
        {
            unique_lock<mutex> lock(client_mutex);    //上锁
            clients.push_back(cli);    //放入在线客户端列表
            sprintf(msg.content, "--------%s loged in------\n", msg.name);//封装广播消息
            BroadCast(msg);    //发送广播
            break;
        }
        case CHAT:    //聊天消息
        {
            unique_lock<mutex> lock(client_mutex);    //上锁
            BroadCast(msg, cli.cfd);
            break;
        }
        case QUIT:    //退出消息
        {
            unique_lock<mutex> lock(client_mutex);    //上锁
            //移除下线的客户端
            for (auto it = clients.begin(); it != clients.end();it++) {
                if (it->cfd == cli.cfd) {
                    clients.erase(it);
                    break;
                }
            }
            close(cli.cfd);
            sprintf(msg.content, "--------%s quit------\n", msg.name);    //组装广播消息
            BroadCast(msg, cli.cfd);
            return;
        }
        default:
            cout << "message type error" << endl;
            break;
        }
    }
}

void Server::BroadCast(const MSG& msg, int exclude_fd) {

    string data = msg.serialize();     //序列化
    for (auto client : clients) {
        if (client.cfd == exclude_fd)continue;
        if (send(client.cfd, data.c_str(), data.size(), 0) == -1) {
            ERR_LOG("send error");
            continue;
        }
    }
}#include "../head/Server.h"

#define ERR_LOG(msg) do{\
    perror(msg);\
    cout << __LINE__ << " " << __func__ << " " << __FILE__ << endl;\
}while (0)

Server::Server(const char* ip, int port, size_t poolSize) :pool_size(poolSize), stop(false) {

    //创建服务器套接字
    sfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sfd == -1) {
        ERR_LOG("socket error");
        return;
    }

    //开启端口号快速复用
    int reuse = 1;
    if (setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
        ERR_LOG("setsockopt error");
        return;
    }

    //绑定地址信息
    sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = inet_addr(ip);
    if (bind(sfd, (const sockaddr*)(&sin), sizeof(sin)) == -1) {
        ERR_LOG("bind error");
        return;
    }

    //启动监听
    if (listen(sfd, 128) == -1) {
        ERR_LOG("listen error");
        return;
    }

    //启动线程池
    start_ThreadPool();

}

void Server::start_ThreadPool() {

    for (int i = 0;i < pool_size;i++) {
        workers.emplace_back(thread([this] {
            while (true) {
                function<void()> task;
                {
                    unique_lock<mutex> lock(task_mutex);    //上锁
                    task_cond.wait(lock, [this] {
                        return stop || !tasks.empty();
                        });
                    if (stop && tasks.empty())return;

                    task = tasks.front();
                    tasks.pop();
                }
                task();
            }
            }));
    }
}

Server::~Server() {
    {
        unique_lock<mutex> lock(task_mutex);
        stop = true;
        task_cond.notify_all();
    }

    //回收所有线程资源
    for (auto& worker : workers) {
        worker.join();
    }

    close(sfd);    //关闭服务器监听套接字
}

void Server::AddTask(function<void()> task) {
    unique_lock<mutex> lock(task_mutex);
    tasks.push(task);
    task_cond.notify_one();
}

void Server::run() {
    sockaddr_in cin;
    socklen_t addr_len;
    while (true) {
        int newfd = accept(sfd, (sockaddr*)(&cin), &addr_len);
        if (newfd == -1) {
            ERR_LOG("accept error");
            continue;
        }

        AddTask([this, newfd, cin] {
            Client cli{ newfd,cin };
            handle_client(cli);
            });
    }
}

void Server::handle_client(Client& cli) {
    MSG msg;    //存放反序列化后的消息
    char buf[sizeof(MSG)];    //用于接收消息
    int recv_len;    //接收到的消息大小

    while (true) {
        memset(buf, 0, sizeof(buf));
        recv_len = recv(cli.cfd, buf, sizeof(buf), 0);
        if (recv_len == 0) {    //客户端下线，等效于quit消息
            unique_lock<mutex> lock(client_mutex);    //上锁
            //移除下线的客户端
            for (auto it = clients.begin(); it != clients.end();it++) {
                if (it->cfd == cli.cfd) {
                    clients.erase(it);
                    break;
                }
            }
            close(cli.cfd);
            sprintf(msg.content, "--------%s quit------\n", msg.name);    //组装广播消息
            BroadCast(msg, cli.cfd);
            break;
        }
        else if (recv_len < 0) {
            ERR_LOG("recv error");
            continue;
        }
        msg.deserialize(string(buf, recv_len));    //反序列化

        switch (ntohl(msg.type)) {    //判断消息类型
        case LOGIN:     //登录消息
        {
            unique_lock<mutex> lock(client_mutex);    //上锁
            clients.push_back(cli);    //放入在线客户端列表
            sprintf(msg.content, "--------%s loged in------\n", msg.name);//封装广播消息
            BroadCast(msg);    //发送广播
            break;
        }
        case CHAT:    //聊天消息
        {
            unique_lock<mutex> lock(client_mutex);    //上锁
            BroadCast(msg, cli.cfd);
            break;
        }
        case QUIT:    //退出消息
        {
            unique_lock<mutex> lock(client_mutex);    //上锁
            //移除下线的客户端
            for (auto it = clients.begin(); it != clients.end();it++) {
                if (it->cfd == cli.cfd) {
                    clients.erase(it);
                    break;
                }
            }
            close(cli.cfd);
            sprintf(msg.content, "--------%s quit------\n", msg.name);    //组装广播消息
            BroadCast(msg, cli.cfd);
            return;
        }
        default:
            cout << "message type error" << endl;
            break;
        }
    }
}

void Server::BroadCast(const MSG& msg, int exclude_fd) {

    string data = msg.serialize();     //序列化
    for (auto client : clients) {
        if (client.cfd == exclude_fd)continue;
        if (send(client.cfd, data.c_str(), data.size(), 0) == -1) {
            ERR_LOG("send error");
            continue;
        }
    }
}
```

```Cpp title:"main.cpp"
#include "../head/Server.h"

int main(int argc, char* argv[]) {

    char ip[64] = "";
    int port;
    if (argc < 3) {
        cout << "输入IP地址:" << endl;
        cin >> ip;
        cout << "输入端口号:" << endl;
        cin >> port;
    }
    else {
        strcpy(ip, argv[1]);
        port = atoi(argv[2]);
    }

    try {
        Server server(ip, port);
        server.run();
    }
    catch (const exception& e) {
        cout << e.what() << endl;
    }

    return 0;
}
```

### 客户端

```Cpp title="Client.h"
#pragma once

#include <myHead.h>
#include <pthread.h>
#include <thread>

using namespace std;

#define CONTENT_SIZE 128    //消息缓冲区大小
#define LOGIN 1    //登录消息类型
#define CHAT 2    //聊天消息类型
#define QUIT 3    //退出消息类型

class Client {
public:
    //消息结构体
    struct MSG {
        int type;    //消息类型
        char name[32];    //客户端名称
        char content[CONTENT_SIZE];    //文本内容

        //序列化函数，将结构体转为二进制
        string serialize()const {
            string data;
            data.append(reinterpret_cast<const char*>(&type), sizeof(type));    //将type强转为const char*类型存储
            data.append(name, sizeof(name));
            data.append(content, sizeof(content));

            return data;
        }

        //反序列化函数，将二进制转为结构体
        void deserialize(const string& data) {

            size_t offset = 0;    //字符偏移量

            memcpy(&type, data.c_str() + offset, sizeof(type));    //解析type
            offset += sizeof(type);
            memcpy(name, data.c_str() + offset, sizeof(name));    //解析name
            offset += sizeof(name);
            memcpy(content, data.c_str() + offset, sizeof(content));    //解析content
        }
    };

private:
    int cfd;    //用于通信用的套接字
    string name;    //客户端名称
    bool running;    //客户端是否在运行

    void SendMessage(int type, const string& content = "");    //发送消息
    void ReceiveMessage();    //接收消息

public:
    Client(const char* ip, int port, const string& name);
    ~Client();

    void run();
};#pragma once

#include <myHead.h>
#include <pthread.h>
#include <thread>

using namespace std;

#define CONTENT_SIZE 128    //消息缓冲区大小
#define LOGIN 1    //登录消息类型
#define CHAT 2    //聊天消息类型
#define QUIT 3    //退出消息类型

class Client {
public:
    //消息结构体
    struct MSG {
        int type;    //消息类型
        char name[32];    //客户端名称
        char content[CONTENT_SIZE];    //文本内容

        //序列化函数，将结构体转为二进制
        string serialize()const {
            string data;
            data.append(reinterpret_cast<const char*>(&type), sizeof(type));    //将type强转为const char*类型存储
            data.append(name, sizeof(name));
            data.append(content, sizeof(content));

            return data;
        }

        //反序列化函数，将二进制转为结构体
        void deserialize(const string& data) {

            size_t offset = 0;    //字符偏移量

            memcpy(&type, data.c_str() + offset, sizeof(type));    //解析type
            offset += sizeof(type);
            memcpy(name, data.c_str() + offset, sizeof(name));    //解析name
            offset += sizeof(name);
            memcpy(content, data.c_str() + offset, sizeof(content));    //解析content
        }
    };

private:
    int cfd;    //用于通信用的套接字
    string name;    //客户端名称
    bool running;    //客户端是否在运行

    void SendMessage(int type, const string& content = "");    //发送消息
    void ReceiveMessage();    //接收消息

public:
    Client(const char* ip, int port, const string& name);
    ~Client();

    void run();
};v
```

```Cpp title:"Client.cpp"
#include "../head/Client.h"

#define ERR_LOG(msg) do{\
    perror(msg);\
    cout << __LINE__ << " " << __func__ << " " << __FILE__ << endl;\
}while (0)

Client::Client(const char* ip, int port, const string& name) :name(name), running(true) {

    //创建用于通信的套接字
    cfd = socket(AF_INET, SOCK_STREAM, 0);
    if (cfd == -1) {
        ERR_LOG("socket error");
        return;
    }

    //连接服务器
    sockaddr_in sin;    //服务器地址信息
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = inet_addr(ip);
    if (connect(cfd, (const sockaddr*)(&sin), sizeof(sin)) == -1) {
        ERR_LOG("connect error");
        return;
    }

    //向服务器发送登录消息
    SendMessage(LOGIN);
}

Client::~Client() {

    SendMessage(QUIT);      //向服务器发送退出消息
    close(cfd);
}

void Client::run() {

    //创建分支线程用于接受信息
    thread recvThread(&Client::ReceiveMessage, this);

    //发送消息
    string content;
    while (running) {
        getline(cin, content);
        if (content == "quit") {
            running = false;
            break;
        }
        SendMessage(CHAT, content);
    }

    recvThread.join();    //回收线程资源
}

void Client::SendMessage(int type, const string& content) {

    //封装要发送的消息
    MSG msg;
    msg.type = htonl(type);
    strncpy(msg.name, name.c_str(), sizeof(msg.name));
    strncpy(msg.content, content.c_str(), sizeof(msg.content));
    string data = msg.serialize();    //序列化

    //发送消息
    if (send(cfd, data.c_str(), data.size(), 0) == -1) {
        ERR_LOG("send error");
        return;
    }

    // if (content == "quit") {
    //     running = false;
    //     exit(EXIT_SUCCESS);
    //     return;
    // }
    cout << "send success" << endl;
}

void Client::ReceiveMessage() {

    char buf[sizeof(MSG)] = "";

    while (true) {
        if (!running) {
            break;
        }
        memset(buf, 0, sizeof(buf));
        int recv_len = recv(cfd, buf, sizeof(buf), MSG_DONTWAIT);    //非阻塞方式接受消息
        if (recv_len <= 0) {
            if (errno == EAGAIN) {    //暂时没有接受到消息
                usleep(10000);
                continue;
            }
            else {
                ERR_LOG("recv error");
                running = false;
                break;
            }
        }
        MSG msg;
        msg.deserialize(string(buf, recv_len));
        cout << msg.name << ":  " << msg.content << endl;
    }
}#include "../head/Client.h"

#define ERR_LOG(msg) do{\
    perror(msg);\
    cout << __LINE__ << " " << __func__ << " " << __FILE__ << endl;\
}while (0)

Client::Client(const char* ip, int port, const string& name) :name(name), running(true) {

    //创建用于通信的套接字
    cfd = socket(AF_INET, SOCK_STREAM, 0);
    if (cfd == -1) {
        ERR_LOG("socket error");
        return;
    }

    //连接服务器
    sockaddr_in sin;    //服务器地址信息
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = inet_addr(ip);
    if (connect(cfd, (const sockaddr*)(&sin), sizeof(sin)) == -1) {
        ERR_LOG("connect error");
        return;
    }

    //向服务器发送登录消息
    SendMessage(LOGIN);
}

Client::~Client() {

    SendMessage(QUIT);      //向服务器发送退出消息
    close(cfd);
}

void Client::run() {

    //创建分支线程用于接受信息
    thread recvThread(&Client::ReceiveMessage, this);

    //发送消息
    string content;
    while (running) {
        getline(cin, content);
        if (content == "quit") {
            running = false;
            break;
        }
        SendMessage(CHAT, content);
    }

    recvThread.join();    //回收线程资源
}

void Client::SendMessage(int type, const string& content) {

    //封装要发送的消息
    MSG msg;
    msg.type = htonl(type);
    strncpy(msg.name, name.c_str(), sizeof(msg.name));
    strncpy(msg.content, content.c_str(), sizeof(msg.content));
    string data = msg.serialize();    //序列化

    //发送消息
    if (send(cfd, data.c_str(), data.size(), 0) == -1) {
        ERR_LOG("send error");
        return;
    }

    // if (content == "quit") {
    //     running = false;
    //     exit(EXIT_SUCCESS);
    //     return;
    // }
    cout << "send success" << endl;
}

void Client::ReceiveMessage() {

    char buf[sizeof(MSG)] = "";

    while (true) {
        if (!running) {
            break;
        }
        memset(buf, 0, sizeof(buf));
        int recv_len = recv(cfd, buf, sizeof(buf), MSG_DONTWAIT);    //非阻塞方式接受消息
        if (recv_len <= 0) {
            if (errno == EAGAIN) {    //暂时没有接受到消息
                usleep(10000);
                continue;
            }
            else {
                ERR_LOG("recv error");
                running = false;
                break;
            }
        }
        MSG msg;
        msg.deserialize(string(buf, recv_len));
        cout << msg.name << ":  " << msg.content << endl;
    }
}
```


```Cpp title:"main.cpp"
#include "../head/Client.h"

int main(int argc, char const* argv[]) {
    char ip[64];
    int port;
    string name;
    if (argc < 4) {
        cout << "输入服务器IP:";
        cin >> ip;
        cout << "输入服务器端口号:";
        cin >> port;
        cout << "输入客户端名称:" << endl;
        cin >> name;
    }
    else {
        strcpy(ip, argv[1]);
        port = atoi(argv[2]);
        name = argv[3];
    }
    try {
        Client client(ip, port, name);
        client.run();
    }
    catch (const exception& e) {
        cout << e.what() << endl;
    }
    return 0;
}
```