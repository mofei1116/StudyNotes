# SQLite3

一般Linux支持sqlite3数据库

- 安装sqlite3库：`yum -y install sqlite-devel`，头文件是`/usr/include/sqlite3.h`

## 基本操作

- 创建/打开一个数据库：`sqlite3 数据库名`
- sqlite3命令：`.命令`，不以`;`结束，常用：
	- `.table`：显示当前数据库中的数据表
	- `.quit`：退出数据库
	- `.schema`：查看表结构
	- `.head`：设置输出时是否显示表头
	- `.mode 模式`：设置输出模式，比如设置列左对齐`.mode column`
- SQL语句：DDL,DML,DQL,DCL

## 接口

> 头文件`<sqlite3.h>`，编译时链接库`-lsqlite3`

错误处理函数：

- `int sqlite3_errcode(sqlite3 *db);`：返回数据库句柄操作中错误码的值
- `const char *sqlite3_errmsg(sqlite3*);`：返回数据库句柄操作中的错误信息

操作函数：

- `int sqlite3_open(const char *filename,sqlite3 **ppDb)`：创建并打开一个数据库
	- 参数：
		- 要打开的数据库名称
		- 用于接受数据库句柄，若没有分配sqlite3对象，`ppDb`的值为`nullptr`
	- 返回值：成功返回`SQLITE_OK`，失败返回错误码（库文件中定义）
- `int sqlite3_close(sqlite3*);`：关闭数据库
	- 参数：数据库句柄指针
	- 返回值：成功返回`SQLITE_OK`，失败返回错误码（库文件中定义）
- `int sqlite3_exec(sqlite3*,const char *sql,int (*callback)(void*,int,char**,char**),void *,char **errmsg);`：在指定数据库中执行SQL语句
	- 参数：
		- 数据库句柄指针
		- 要执行的SQL语句
		- 回调函数，对SQL语句结果的每条记录都会执行回调函数，主要用于查询语句，可以为`nullptr`
		- 回调函数的第一个参数
		- 用于接受错误信息，错误信息存放在堆区，需要用`sqlite3_free()`手动释放
	- 返回值：成功返回`SQLITE_OK`，失败返回错误码（库文件中定义）
- `int sqlite3_prepare_v2(sqlite3 *db,const char *zSql,int nByte,sqlite3_stmt **ppStmt,const char **pzTail);`：预编译SQL语句
	- 参数：
		- 数据库句柄指针
		- 要预编译的SQL语句
		- SQL语句的最大字节数，传-1表示是一个字符串
		- 用于接收预编译结果，编译结果生成在堆区，需要用`sqlite3_finalize()`手动释放
		- 用于接收剩下没有预处理的SQL语句，一般填`nullptr`
	- 返回值：成功返回`SQLITE_OK`，失败返回错误码（库文件中定义）
- `int sqlite3_step(sqlite3_stmt*);`:执行预处理的SQL语句，可以重复调用直到返回的状态码为`SQLITE_DONE`
	- 参数：预处理SQL语句的结果
	- 返回值：
		- `SQLITE_ROW`：有一行输出可用，可以用`sqlite3_column_*`获取
		- `SQLITE_DONE`：语句成功执行
		- `SQLITE_CONSTRAINT`：出现约束错误，如主键列冲突
- `int sqlite3_column_int(sqlite3_stmt*, int iCol);`：返回一行查询结果的一列信息，前提是上一次`sqlite3_step`的结果还有效
	- 参数：
		- 预处理SQL语句的结果
		- 要返回第几列的数据，从0开始
	- 返回值：以32位整数形式返回结果
- `int sqlite3_bind_int(sqlite3_stmt*, int, int);`：给预编译好的内容绑定`int`类型参数，对应sql语句中的通配符如`?`
	- 参数：
		- 预处理SQL语句的结果
		- 对应第几个通配符，从1开始
		- 要绑定的参数

## 实例

```Cpp title:"小型学生管理系统"
#include <myHead.h>
#include <sqlite3.h>

using namespace std;

void do_add(sqlite3* pdb);
void do_delete(sqlite3* pdb);
void do_update(sqlite3* pdb);
void do_query(sqlite3* pdb);
int callback(void*, int, char**, char**);

int main(int argc, char* argv[]) {

    //数据库操作句柄指针
    sqlite3* pdb;

    //打开数据库
    if (sqlite3_open("./student.db", &pdb) != SQLITE_OK) {
        cout << "数据库打开失败:" << sqlite3_errmsg(pdb) << endl;
        return -1;
    }
    cout << "数据库创建成功" << endl;

    //创建数据表
    const char* sql = "CREATE TABLE IF NOT EXISTS Student(id INT,name TEXT,score DOUBLE);";    //SQL语句
    char* errmsg = nullptr;    //用于接收错误信息
    if (sqlite3_exec(pdb, sql, nullptr, nullptr, &errmsg) != SQLITE_OK) {
        cout << "数据库创建失败:" << sqlite3_errmsg(pdb) << endl;
        if (errmsg) {
            sqlite3_free(errmsg);
        }
        return -1;
    }
    cout << "数据表创建成功" << endl;

    //菜单
    int option = -1;
    while (true) {
        //system("clear");
        cout << "-------学生管理系统------" << endl;
        cout << "----1.添加学生信息----" << endl;
        cout << "----2.删除学生信息----" << endl;
        cout << "----3.修改学生信息----" << endl;
        cout << "----4.查询学生信息----" << endl;
        cout << "----0.退出-----------" << endl;
        cout << "输入选项:" << endl;
        cin >> option;
        getchar();    //吸收换行符
        switch (option) {
        case 0:exit(EXIT_SUCCESS);
        case 1:
            do_add(pdb);
            break;
        case 2:
            do_delete(pdb);
            break;
        case 3:
            do_update(pdb);
            break;
        case 4:
            do_query(pdb);
            break;
        default:
            cout << "输入有误" << endl;
            break;
        }
        cout << "输入任意字符继续:" << endl;
        while (getchar() != '\n');
    }
    return 0;
}

void do_add(sqlite3* pdb) {

    int add_id = 0;    //学生id
    char add_name[32] = "";    //学生姓名
    double add_score = 0;    //学生分数

    //输入学生信息
    printf("输入学生id:");
    scanf("%d", &add_id);
    printf("输入学生姓名:");
    scanf("%s", add_name);
    printf("输入学生分数:");
    scanf("%lf", &add_score);

    char sql[128] = "";    //SQL语句
    char* errmsg = nullptr;
    sprintf(sql, "INSERT INTO Student VALUES(%d,\"%s\",%.2f);", add_id, add_name, add_score);

    //执行SQL语句
    if (sqlite3_exec(pdb, sql, nullptr, nullptr, &errmsg) != SQLITE_OK) {
        cout << "添加信息失败" << endl;
        if (errmsg) {
            sqlite3_free(errmsg);
        }
        return;
    }
    printf("添加信息成功\n");
}

void do_delete(sqlite3* pdb) {

    int add_id = 0;    //学生id
    printf("输入要删除的学生id:");
    scanf("%d", &add_id);

    char sql[128] = "";    //SQL语句
    char* errmsg = nullptr;
    sprintf(sql, "DELETE FROM Student WHERE id=%d;", add_id);

    //执行SQL语句
    if (sqlite3_exec(pdb, sql, nullptr, nullptr, &errmsg) != SQLITE_OK) {
        cout << "删除信息失败" << endl;
        if (errmsg) {
            sqlite3_free(errmsg);
        }
        return;
    }
    printf("删除信息成功\n");
}

void do_update(sqlite3* pdb) {

    int update_id = 0;    //学生id
    char update_name[32] = "";    //学生姓名
    double update_score = 0;    //学生分数
    char sql[128] = "";
    char* errmsg = nullptr;

    printf("输入学生id:");
    scanf("%d", &update_id);
    printf("输入学生姓名:");
    scanf("%s", update_name);
    printf("输入学生分数:");
    scanf("%lf", &update_score);

    sprintf(sql, "UPDATE Student SET name=\"%s\",score=%.2f WHERE id=%d;", update_name, update_score, update_id);
    if (sqlite3_exec(pdb, sql, nullptr, nullptr, &errmsg) != SQLITE_OK) {
        cout << "修改信息失败" << endl;
        if (errmsg) {
            sqlite3_free(errmsg);
            errmsg = nullptr;
        }
        return;
    }
    cout << "修改信息成功" << endl;
}

void do_query(sqlite3* pdb) {

    const char* sql = "SELECT * FROM Student;";
    char* errmsg = nullptr;

    int flag = 0;    //标识是否输出了表头

    if (sqlite3_exec(pdb, sql, callback, &flag, &errmsg) != SQLITE_OK) {
        cout << "查找失败" << endl;
        if (errmsg) {
            sqlite3_free(errmsg);
        }
        return;
    }
}

int callback(void* pflag, int cols, char** msgText, char** headText) {

    if (*(int*)pflag == 0) {
        //输出表头
        for (int i = 0;i < cols;i++) {
            printf("%s\t", *(headText + i));
        }
        printf("\n");
        *(int*)pflag = 1;
    }

    //输出正文
    for (int i = 0;i < cols;i++) {
        printf("%s\t", *(msgText + i));
    }
    printf("\n");
    return 0;
}
```

# 基于TCP的网络电子词典

## 服务器端

![[网络词典客户端.png]]

```Cpp title:"main.cpp"
#include "../head/DatabaseManager.h"
#include "../head/Server.h"

int main(int argc, char* argv[]) {

    try {
        //在堆区构造数据库管理对象
        shared_ptr<DatabaseManager> db_manager = make_shared<DatabaseManager>("usr.db", "dict.db");
        //初始化
        if (!db_manager->initDatabase()) {
            cerr << "数据库初始化失败" << endl;
            return -1;
        }
        Server server(db_manager, "192.168.200.200", 8888);
        server.run();
    }
    catch (const exception& e) {
        cout << e.what() << endl;
        return -1;
    }

    return 0;
}
```

### 数据库模块

- 用户数据库：
	- 存储用户名和密码
	- 存储用户查询历史记录表
- 单词数据库：
	- 存储单词词汇表

```Cpp title:"DatabaseManager.h"
#pragma once

#include <iostream>
#include <sqlite3.h>
#include <string>
#include <mutex>
#include <memory>
#include <fstream>
#include <ctime>
#include <stdexcept>

using namespace std;

#define DICT_PATH "../src/dict.txt"    //单词文本文件路径

class DatabaseManager {
public:

    DatabaseManager(const string& usr_db_path, const string& dict_db_path);    //构造函数:传入用户库和单词库的路径
    ~DatabaseManager();    //析构函数

    bool initDatabase();    //初始化数据库
    //用户账号相关操作
    bool registUser(const string& name, const string& password);    //用户注册
    bool loginUser(const string& name, const string& password, bool& is_online);    //用户登录
    bool logoutUser(const string& name);    //用户退出

    //单词查询相关操作
    bool queryWord(const string& word, string& meaning);    //查询单词
    bool recordHistory(const string& name, const string& word, const string& meaning, const string& time);   //记录历史查询
    bool queryHistory(const string& name, string& histroy);    //查询历史

private:
    sqlite3* usr_pdb;    //用户数据库
    sqlite3* dict_pdb;    //词典数据库
    mutex usr_mutex;    //用户库互斥锁
    mutex dict_mutex;    //词典库互斥锁

    bool initUserDB();    //初始化用户数据库
    bool initDictDB();    //初始化词典数据库
    bool importDict();    //导入词典
};
```

```Cpp title:"DatabaseManager.cpp"
#include "../head/DatabaseManager.h"

DatabaseManager::DatabaseManager(const string& usr_db_path, const string& dict_db_path) {

    //打开或创建用户数据库
    if (sqlite3_open(usr_db_path.c_str(), &usr_pdb) != SQLITE_OK) {
        throw runtime_error("用户数据库打开失败:" + string(sqlite3_errmsg(usr_pdb)));
    }

    //打开或创建单词数据库
    if (sqlite3_open(dict_db_path.c_str(), &dict_pdb) != SQLITE_OK) {
        throw runtime_error("单词数据库打开失败:" + string(sqlite3_errmsg(dict_pdb)));
    }
}

DatabaseManager::~DatabaseManager() {

    //关闭用户数据库
    if (sqlite3_close(usr_pdb) != SQLITE_OK) {
        throw runtime_error("用户数据库关闭失败:" + string(sqlite3_errmsg(usr_pdb)));
    }

    //关闭单词数据库
    if (sqlite3_close(dict_pdb) != SQLITE_OK) {
        throw runtime_error("单词数据库关闭失败:" + string(sqlite3_errmsg(usr_pdb)));
    }
}

bool DatabaseManager::initDatabase() {

    //初始化用户数据库和单词数据库
    return initUserDB() && initDictDB();
}

bool DatabaseManager::initUserDB() {

    lock_guard<mutex> lock(usr_mutex);    //上锁，锁定数据库操作，保护数据库

    char* errmsg = nullptr;    //接受错误信息

    //创建表的SQL语句
    const char* sql =
        "CREATE TABLE IF NOT EXISTS Usr("    //创建账号表
        "name TEXT PRIMARY KEY,"    //用户名
        "password INT,"    //密码
        "status INT DEFAULT 0);"    //在线状态，1在线，0不在线
        "CREATE TABLE IF NOT EXISTS History("    //创建历史记录表
        "name TEXT,"    //用户名
        "word TEXT,"    //单词
        "meaning TEXT,"    //单词含义
        "time TEXT);";    //查询时间

    //执行创建表的SQL语句
    if (sqlite3_exec(usr_pdb, sql, nullptr, nullptr, &errmsg) != SQLITE_OK) {
        cerr << "创建用户表失败:" << string(errmsg) << endl;
        sqlite3_free(errmsg);
        return false;
    }

    return true;
}

bool DatabaseManager::initDictDB() {

    lock_guard<mutex> lock(dict_mutex);    //上锁，锁定数据库操作，保护数据库

    char* errmsg = nullptr;    //接受错误信息

    //创建单词表的SQL语句
    const char* sql =
        "CREATE TABLE IF NOT EXISTS Dict("
        "word TEXT,"
        "meaning TEXT);";

    //执行创建单词表的SQL语句
    if (sqlite3_exec(dict_pdb, sql, nullptr, nullptr, &errmsg) != SQLITE_OK) {
        if (errmsg) {
            cerr << "创建单词表失败:" + string(errmsg) << endl;
            sqlite3_free(errmsg);
        }
        else cerr << "创建单词表失败:" + string(sqlite3_errmsg(usr_pdb)) << endl;
        return false;
    }

    sql = "SELECT COUNT(*) FROM Dict;";    //查询表中记录条数的SQL语句
    sqlite3_stmt* stmt;    //接收预编译的SQL语句的结果

    //预编译SQL语句
    if (sqlite3_prepare_v2(dict_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "SQL语句准备失败:" << sqlite3_errmsg(dict_pdb) << endl;
        return false;
    }

    bool need_import = false;    //是否需要导入词典
    if (sqlite3_step(stmt) == SQLITE_ROW) {    //成功执行，有一行输出可用
        if (sqlite3_column_int(stmt, 0) == 0) {    //表中记录条数为0
            need_import = true;    //需要导入词典
        }
    }
    sqlite3_finalize(stmt);    //释放stmt空间

    return need_import ? importDict() : true;    //导入单词表
}

bool DatabaseManager::importDict() {

    //打开dict.txt文件，创建文件流，打开以读
    ifstream ifs;
    ifs.open(DICT_PATH);
    if (!ifs.is_open()) {
        cerr << "无法打开文件dict.txt" << endl;
        return false;
    }

    string line;    //用于读取文件中一行数据
    while (getline(ifs, line)) {

        //跳过空行
        if (line.empty())continue;

        //解析word和meaning
        size_t posi = line.find(' ');
        if (posi == string::npos) {
            cerr << "无效的单词条目" << endl;
            continue;
        }
        string word = line.substr(0, posi);
        posi = line.rfind(' ');
        string meaning = line.substr(posi + 1);

        //准备sql语句
        const char* sql = "INSERT INTO Dict VALUES(?,?);";    //统配符?
        //预编译sql语句
        sqlite3_stmt* stmt = nullptr;
        if (sqlite3_prepare_v2(dict_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
            cerr << "预编译失败:" << sqlite3_errmsg(dict_pdb) << endl;
            ifs.close();
            return false;
        }
        //给编译好的sql语句内容绑定参数
        sqlite3_bind_text(stmt, 1, word.c_str(), -1, SQLITE_STATIC);
        sqlite3_bind_text(stmt, 2, meaning.c_str(), -1, SQLITE_STATIC);
        //执行预编译的语句
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            cerr << "数据插入失败:" << sqlite3_errmsg(dict_pdb) << endl;
            sqlite3_finalize(stmt);
            ifs.close();
            return false;
        }
        //释放stmt
        sqlite3_finalize(stmt);
    }

    ifs.close();
    cout << "单词库导入成功" << endl;
}

bool DatabaseManager::registUser(const string& name, const string& password) {

    lock_guard<mutex> lock(usr_mutex);    //上锁

    const char* sql = "INSERT INTO Usr VALUES(?,?,0);";
    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(usr_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "预编译SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
        return false;
    }
    sqlite3_bind_text(stmt, 1, name.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 2, password.c_str(), -1, SQLITE_STATIC);
    int res = sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    if (res == SQLITE_CONSTRAINT) {    //约束类错误
        cerr << "用户名已存在：" << name << endl;
        return false;
    }
    return res == SQLITE_DONE;
}

bool DatabaseManager::loginUser(const string& name, const string& password, bool& is_online) {

    unique_lock<mutex> lock(usr_mutex);    //上锁

    char* sql = "SELECT status FROM Usr WHERE name=? AND password=?;";
    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(usr_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "预编译查询SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
        return false;
    }
    sqlite3_bind_text(stmt, 1, name.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 2, password.c_str(), -1, SQLITE_STATIC);
    int res = sqlite3_step(stmt);

    if (res == SQLITE_ROW) {    //有一行可用的信息
        if (sqlite3_column_int(stmt, 0) == 1) {    //用户已在线
            is_online = true;
            cerr << "用户已在线" << endl;
        }
        else {    //设置用户状态为在线
            is_online = false;
            sqlite3_finalize(stmt);
            stmt = nullptr;
            sql = "UPDATE Usr SET status=1 WHERE name=?;";
            if (sqlite3_prepare_v2(usr_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
                cerr << "预编译更新SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
                return false;
            }
            sqlite3_bind_text(stmt, 1, name.c_str(), -1, SQLITE_STATIC);
            res = sqlite3_step(stmt);
        }
        return true;
    }
    else {    //用户密码不匹配
        cerr << "用户密码不匹配" << endl;
        return false;
    }
}

bool DatabaseManager::logoutUser(const string& name) {

    unique_lock<mutex> lock(usr_mutex);    //上锁

    const char* sql = "UPDATE Usr SET status=0 WHERE name=?;";

    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(usr_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "预编译更新SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
        return false;
    }
    sqlite3_bind_text(stmt, 1, name.c_str(), -1, SQLITE_STATIC);
    int res = sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    return res == SQLITE_DONE;
}

bool DatabaseManager::queryWord(const string& word, string& meaning) {

    unique_lock<mutex> lock(dict_mutex);    //上锁

    const char* sql = "SELECT meaning FROM Dict WHERE word=?;";
    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(dict_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "预编译插入SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
        return false;
    }
    sqlite3_bind_text(stmt, 1, word.c_str(), -1, SQLITE_STATIC);

    int res = sqlite3_step(stmt);

    if (res == SQLITE_ROW) {    //查询成功
        meaning = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0));
        sqlite3_finalize(stmt);
        return true;
    }
    cerr << "单词库无单词" << endl;
    return false;
}

bool DatabaseManager::recordHistory(const string& name, const string& word, const string& meaning, const string& time) {

    unique_lock<mutex> lock(usr_mutex);

    const char* sql = "INSERT INTO History VALUES(?,?,?,?);";
    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare_v2(usr_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "预编译插入SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
        return false;
    }
    sqlite3_bind_text(stmt, 1, name.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 2, word.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 3, meaning.c_str(), -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 4, time.c_str(), -1, SQLITE_STATIC);

    if (sqlite3_step(stmt) != SQLITE_DONE) {
        cerr << "SQL执行失败" << endl;
        return false;
    }
    sqlite3_finalize(stmt);
    return true;
}

bool DatabaseManager::queryHistory(const string& name, string& history) {

    unique_lock<mutex> lock(usr_mutex);

    const char* sql = "SELECT word,meaning,time FROM History WHERE name=?;";
    sqlite3_stmt* stmt = nullptr;
    if (sqlite3_prepare(usr_pdb, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "预编译查询SQL语句失败:" << sqlite3_errmsg(usr_pdb) << endl;
        return false;
    }
    sqlite3_bind_text(stmt, 1, name.c_str(), -1, SQLITE_STATIC);

    history.clear();
    //循环执行预编译好的SQL语句直到没有可用的行
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        history += string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))) + "\t";
        history += string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))) + "\t";
        history += string(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))) + "\n";
    }

    sqlite3_finalize(stmt);
    return true;
}
```

### 服务器模块

- 启动服务器：创建套接字，绑定地址信息，启动监听，接受连接请求
- 多线程处理客户端连接

```Cpp title:"Server.h"
#pragma once

#include <myHead.h>
#include <memory>
#include <ctime>
#include <thread>
#include "../head/DatabaseManager.h"
#include "../head/Message.hpp"

class Server {
public:
    Server(shared_ptr<DatabaseManager> db_manager, const string ip, const int port);
    ~Server();
    bool run();    //运行服务器
    bool stop();    //停止服务器

private:
    string ip;     //主机ip
    int port;    //端口号
    int listen_sock;    //监听用的套接字
    bool is_running;    //是否正在运行
    shared_ptr<DatabaseManager> db_manager;    //数据库管理

    void handle_client(int cfd, sockaddr_in client_addr);    //处理客户端连接
    static string getCurrentTime();
};
```

```Cpp title:"Server.cpp"
#include "../head/Server.h"

Server::Server(shared_ptr<DatabaseManager> db_manager, const string ip, const int port)
    :db_manager(db_manager), ip(ip), port(port), is_running(false) {

    //创建监听用的套接字
    listen_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (listen_sock == -1) {
        throw runtime_error("socket error");
    }

    //设置端口号快速复用
    int reuse = 1;
    if (setsockopt(listen_sock, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
        close(listen_sock);
        throw runtime_error("setsockopt error");
    }

    //断定地址信息
    sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = inet_addr(ip.c_str());
    if (bind(listen_sock, (const sockaddr*)(&sin), sizeof(sin)) == -1) {
        close(listen_sock);
        throw runtime_error("bind error");
    }
}

Server::~Server() {

    stop();
}

bool Server::run() {

    //启动监听
    if (listen(listen_sock, 128) == -1) {
        close(listen_sock);
        perror("listen error");
        return false;
    }

    //设置运行状态
    is_running = true;
    cout << "server started on " << ip << ":" << port << endl;

    //循环接收客户端连接请求
    sockaddr_in cin;
    socklen_t socklen = sizeof(cin);
    while (is_running) {
        int cfd = accept(listen_sock, (sockaddr*)(&cin), &socklen);
        if (cfd == -1) {
            if (is_running) {
                perror("accept error");
            }
            continue;
        }
        thread th([this, cfd, cin]() {
            printf("client [%s:%d] connected\n", inet_ntoa(cin.sin_addr), ntohs(cin.sin_port));
            handle_client(cfd, cin);
            });
        th.detach();
    }
}

bool Server::stop() {

    if (is_running) {
        is_running = false;
        close(listen_sock);
        cout << "server stopped" << endl;
        return  true;
    }
    return false;
}

void Server::handle_client(int cfd, sockaddr_in cin) {

    Message msg;
    Message response;    //用于回复的消息容器
    while (true) {
        bool can_continue = false;

        memset(&msg, 0, sizeof(msg));
        int res = recv(cfd, &msg, sizeof(msg), 0);
        if (res == 0) {    //当前客户端已下线
            printf("client [%s:%d] disconnect\n", inet_ntoa(cin.sin_addr), ntohs(cin.sin_port));
            break;
        }
        else if (res == -1) {
            perror("recv error");
            break;
        }

        msg.HostByteOrder();    //转换为主机字节序
        memset(&response, 0, sizeof(response));
        strncpy(response.name, msg.name, sizeof(response.name));
        response.type = msg.type;

        //根据消息类型处理消息
        switch (msg.type) {
        case REGIST:
        {
            bool res = db_manager->registUser(msg.name, msg.content);
            strncpy(response.content, res ? "regist success" : "regist fail", sizeof(response.content));
            break;
        }
        case LOGIN:
        {
            bool online = false;
            if (db_manager->loginUser(msg.name, msg.content, online)) {
                strncpy(response.content, online ? "already online" : "login success", sizeof(response.content));
            }
            else strncpy(response.content, "login fail", sizeof(response.content));
            break;
        }
        case QUIT:
        {
            db_manager->logoutUser(msg.name);
            can_continue = true;
            break;
        }
        case WORD:
        {
            string meaning;
            bool res = db_manager->queryWord(string(msg.content), meaning);
            if (res) {
                snprintf(response.content, sizeof(response.content), "%s %s", msg.content, meaning.c_str());
            }
            else strncpy(response.content, "query fail", sizeof(response.content));

            //记录查单词时间信息
            db_manager->recordHistory(msg.name, msg.content, meaning, getCurrentTime());
            break;
        }
        case HISTORY:
        {
            string history;
            if (db_manager->queryHistory(msg.name, history)) {
                strncpy(response.content, history.c_str(), sizeof(response.content));
            }
            else strncpy(response.content, "query fail", sizeof(response.content));
            break;
        }
        case OFFLINE:
        {
            close(cfd);
            printf("client [%s:%d] disconnect\n", inet_ntoa(cin.sin_addr), ntohs(cin.sin_port));
            return;
        }

        default:
            strncpy(response.content, "invalid request", sizeof(response.content));
        }

        if (can_continue)continue;

        //发送响应
        response.NetwordByteOrder();    //转换为网络字节序
        if (send(cfd, &response, sizeof(response), 0) == -1) {
            perror("send error");
            break;
        }
    }
    close(cfd);    //关闭通信用的套接字
}

string Server::getCurrentTime() {

    time_t now = time(nullptr);
    tm* local = localtime(&now);
    char time_str[32] = "";
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", local);
    return string(time_str);
}
```

### 数据模块

- 传输数据类型：用户注册类型，用户登录类型，用户退出类型，查询单词类型，查询历史记录类型
- 数据类型：传输数据类型，用户名，传输内容

```Cpp title:"Message.hpp"
#pragma once

#include <myHead.h>

#define REGIST 1    //用户注册
#define LOGIN 2    //用户登录
#define QUIT 3    //用户登出
#define WORD 4    //单词查询
#define HISTORY 5    //历史查询
#define OFFLINE 6    //用户下线

struct Message {
    int type;    //消息类型
    char name[32] = "";    //用户名
    char content[456] = "";    //消息内容

    void NetwordByteOrder() {
        type = htonl(type);
    }

    void HostByteOrder() {
        type = ntohl(type);
    }
};
```

## 客户端

![[电子词典客户端.png]]

```Cpp title:"Client.h"
#pragma once

#include <myHead.h>
#include "../head/Message.hpp"

using namespace std;

class Client {
public:
    Client(const string& ip, const int port, const string& ser_ip, const int ser_port);    //连接服务器
    ~Client();
    void run();

private:
    int cli_sock;    //通信用的套接字
    string usrname;    //用户名
    bool is_login;    //是否已经登录

    void showLogMenu();    //展示注册登录界面
    void showUsrMenu();    //展示功能界面

    /*功能*/
    bool do_regist();    //注册
    bool do_login();    //登录
    bool do_word();    //查单词
    bool do_history();    //查历史记录
    bool do_quit();    //登出
    bool do_offline();     //客户端下线
};
```

```Cpp title:"Client.cpp"
#include "../head/Client.h"

Client::Client(const string& ip, const int port, const string& ser_ip, const int ser_port) :is_login(false), cli_sock(-1) {
    cli_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (cli_sock == -1) {
        perror("socket error");
        throw runtime_error("socket error");
    }

    int reuse = 1;
    if (setsockopt(cli_sock, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) == -1) {
        perror("setsockopt error");
        throw runtime_error("setsockopt error");
    }

    sockaddr_in cin;
    cin.sin_family = AF_INET;
    cin.sin_port = htons(port);
    cin.sin_addr.s_addr = inet_addr(ip.c_str());
    if (bind(cli_sock, (const sockaddr*)&cin, sizeof(cin)) == -1) {
        perror("bind error");
        throw runtime_error("bind error");
    }

    sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(ser_port);
    sin.sin_addr.s_addr = inet_addr(ser_ip.c_str());
    if (connect(cli_sock, (const sockaddr*)&sin, sizeof(sin)) == -1) {
        perror("connect error");
        throw runtime_error("connect error");
    }
}

Client::~Client() {
    if (cli_sock > 0) {
        do_quit();
        close(cli_sock);
    }
}

void Client::run() {
    while (true) {
        showLogMenu();
        int flag;
        cin >> flag;
        while (getchar() != '\n');
        switch (flag) {
        case 1:
            do_regist();
            break;
        case 2:
            if (do_login()) {
                showUsrMenu();
            }
            break;
        case 3:
            do_offline();
            return;
        default:
            cout << "无效的选择" << endl;
        }

        cout << "输入任意键继续..." << endl;
        while (getchar() != '\n');
    }
}

void Client::showLogMenu() {

    system("clear");    //清屏
    cout << "*************************" << endl;
    cout << "*********1.注册***********" << endl;
    cout << "*********2.登录***********" << endl;
    cout << "*********3.退出***********" << endl;
    cout << "*************************" << endl;
    cout << "请输入:" << endl;
}

void Client::showUsrMenu() {

    while (is_login) {
        system("clear");    //清屏
        cout << "*****用户:" << usrname << "******************" << endl;
        cout << "*********1.查单词**************" << endl;
        cout << "*********2.查历史记录***********" << endl;
        cout << "*********3.登出***********" << endl;
        cout << "******************************" << endl;
        cout << "请输入:" << endl;
        int flag;
        cin >> flag;
        while (getchar() != '\n');
        switch (flag) {
        case 1:
            do_word();
            break;
        case 2:
            do_history();
            break;
        case 3:
            do_quit();
            break;
        default:
            cout << "无效的选择" << endl;
        }

        cout << "输入任意键继续..." << endl;
        while (getchar() != '\n');
    }
}

bool Client::do_regist() {

    Message msg;
    msg.type = REGIST;
    cout << "输入用户名(不含空格):" << endl;
    cin >> msg.name;
    cout << "输入密码(不含空格):" << endl;
    cin >> msg.content;

    msg.NetwordByteOrder();
    if (send(cli_sock, &msg, sizeof(msg), 0) == -1) {
        perror("send error");
        return false;
    }

    memset(&msg, 0, sizeof(msg));

    if (recv(cli_sock, &msg, sizeof(msg), 0) <= 0) {
        perror("recv error");
        return false;
    }
    msg.HostByteOrder();

    if (strcmp(msg.content, "regist success") == 0) {
        cout << "注册成功" << endl;
        return true;
    }
    cout << "注册失败" << endl;
    return false;

}

bool Client::do_login() {

    Message msg;
    msg.type = LOGIN;
    cout << "输入用户名:" << endl;
    cin >> msg.name;
    cout << "输入密码:" << endl;
    cin >> msg.content;
    while (getchar() != '\n');

    msg.NetwordByteOrder();
    if (send(cli_sock, &msg, sizeof(msg), 0) == -1) {
        perror("send error");
        return false;
    }

    memset(&msg, 0, sizeof(msg));

    if (recv(cli_sock, &msg, sizeof(msg), 0) <= 0) {
        perror("recv error");
        return false;
    }

    msg.HostByteOrder();

    if (strcmp(msg.content, "already online") == 0) {
        cout << "用户已在线" << endl;
        usrname = msg.name;
        is_login = true;
        return true;
    }
    else if (strcmp(msg.content, "login success") == 0) {
        cout << "登录成功" << endl;
        usrname = msg.name;
        is_login = true;
        return true;
    }
    else if (strcmp(msg.content, "login fail") == 0) {
        cout << "登录失败" << endl;
        return false;
    }
    cout << "未知错误" << endl;
    return false;
}

bool Client::do_word() {

    Message msg;
    msg.type = WORD;
    strncpy(msg.name, usrname.c_str(), sizeof(msg.name));
    while (true) {
        cout << "输入要查的单词(输入#结束查询):" << endl;
        cin >> msg.content;
        cin.ignore();
        if (strcmp(msg.content, "#") == 0)break;

        msg.NetwordByteOrder();
        if (send(cli_sock, &msg, sizeof(msg), 0) == -1) {
            perror("send error");
            return false;
        }

        memset(&msg, 0, sizeof(msg));

        if (recv(cli_sock, &msg, sizeof(msg), 0) <= 0) {
            perror("recv error");
            return false;
        }
        msg.HostByteOrder();

        if (strcmp(msg.content, "query fail") == 0) {
            cout << "查询失败" << endl;
            continue;
        }
        cout << msg.content << endl;
    }
    return true;
}

bool Client::do_history() {

    Message msg;
    msg.type = HISTORY;
    strncpy(msg.name, usrname.c_str(), sizeof(msg.name));

    msg.NetwordByteOrder();
    if (send(cli_sock, &msg, sizeof(msg), 0) == -1) {
        perror("send error");
        return false;
    }

    memset(&msg, 0, sizeof(msg));

    if (recv(cli_sock, &msg, sizeof(msg), 0) <= 0) {
        perror("recv error");
        return false;
    }
    msg.HostByteOrder();

    if (strcmp(msg.content, "query fail") == 0) {
        cout << "查询失败" << endl;
        return false;
    }
    cout << msg.content << endl;
    return true;
}

bool Client::do_quit() {

    if (!is_login)return false;

    Message msg;
    msg.type = QUIT;
    strncpy(msg.name, usrname.c_str(), sizeof(msg.name));

    msg.NetwordByteOrder();
    if (send(cli_sock, &msg, sizeof(msg), 0) == -1) {
        perror("send error");
        return false;
    }

    is_login = false;
    usrname.clear();
    cout << "用户已退出" << endl;
    return true;
}

bool Client::do_offline() {

    Message msg;
    msg.type = OFFLINE;
    strncpy(msg.name, usrname.c_str(), sizeof(msg.name));

    msg.NetwordByteOrder();
    if (send(cli_sock, &msg, sizeof(msg), 0) == -1) {
        perror("send error");
        return false;
    }

    cout << "谢谢使用" << endl;
    return true;
}
```

```Cpp title:"main.cpp"
#include "../head/Client.h"

int main(int argc, char* argv[]) {

    try {
        Client client("192.168.200.200", 9999, "192.168.200.200", 8888);
        client.run();
    }
    catch (const exception& e) {
        cout << e.what() << endl;
    }
    return 0;
}
```