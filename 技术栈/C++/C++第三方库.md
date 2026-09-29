# 解压缩

## zlib

主要提供DEFLATE算法压缩和解压，通常调用C接口

头文件`zlib.h`

编译时链接库`-lz`

### 简单解压缩

- `uLong compressBound(uLong sourceLen);`：返回要压缩的数据所需的最大缓冲区大小
- `int compress(Bytef* dest,uLongf* destLen,const Bytef* source,uLong sourceLen);`：压缩，成功返回`Z_OK`
- `int uncompress(Bytef* dest,uLongf* destLen,const Bytef* source,uLong sourceLen);`：解压缩，成功返回`Z_OK`
- `int compress2(Bytef* dest,uLongf* destLen,const Bytef* source,uLong sourceLen,int level);`：指定压缩级别（0-9），可以用`Z_DEFAULT_COMPRESSION`，成功返回`Z_OK`

### 流式解压缩

对大数据分块处理

- `z_stream strm{};`：定义一个空的流结构体，成员：
	- `next_in`：当前输入数据的地址
	- `avail_in`：当前可读的输入字节数
	- `next_out`：输出缓冲区的地址
	- `avail_out`：输出缓冲区可用空间

常见错误码：
- `Z_OK`：操作成功
- `Z_STREAM_END`：流已完成
- `Z_BUF_ERROR`：输出空间不足，或当前无法继续处理
- `Z_DATA_ERROR`：输入数据无效或损坏
- `Z_MEM_ERROR`：内存不足

压缩：
- `int deflateInit(z_streamp strm, int level);`：初始化压缩流，压缩级别可以使用`Z_DEFAULT_COMPRESSION`
- `int deflateInit2(z_streamp strm,int level,int method,int windowBits,int memLevel,int strategy);`：
	- 参数：
		- 流指针
		- 压缩级别
		- 压缩算法，`Z_DEFLATED`使用默认压缩算法
		- 历史窗口大小及输出格式，负值表示输出裸DEFLATE，不带zlib或gzip封装
		- 内存级别：通常1-9
		- 压缩策略：`Z_DEFAULT_STRATEGY`默认压缩策略
- `int deflate(z_streamp strm,int flush)`：执行一轮压缩
	- 参数：
		- `flush`：
			- `Z_NO_FLUSH`：继续处理数据
			- `Z_FINISH`：输入结束
			- `Z_SYNC_FLUSH`：刷新当前数据
	- 返回值：压缩完成返回 `Z_STREAM_END`，仍需继续处理返回 `Z_OK`
- `int deflateEnd(z_streamp strm);`：释放压缩流资源

解压：
- `int inflateInit(z_streamp strm);`：初始化压缩流
- `int inflateInit2(z_streamp strm, int windowBits);`：
	- 参数：
		- 流指针
		- 指定解码窗口及期待的数据封装格式
- `int inflate(z_streamp strm,int flush)`：执行一轮解压
	- 参数：
		- `flush`：
			- `Z_NO_FLUSH`：继续处理数据
			- `Z_FINISH`：输入结束
	- 返回值：解压完成返回 `Z_STREAM_END`，仍需继续处理返回 `Z_OK`
- `int deflateEnd(z_streamp strm);`：释放解压流资源

# JSON

## nlohmann/json

头文件`nlohmann/json.hpp`

`using json = nlohmann::json;`

### 构造json

json对象可以嵌套

```Cpp
json packet={
	{"type","login"},
	{"seq",1001},
	{"success",true}
	{"user",{
		{"userId",66},
		{"name","mofei"}
		}
	}
	{"type",{"beta","phone"}}
}
```

也可以使用`operator[]`

### json对象转字符串

- `dump()`返回json对象对应的JSON格式的字符串
	- `dump(2)`：表示缩进2格

### 字符串转json对象

`json::prase(字符串)`：返回JSON格式的字符串对应的json对象

### 访问

访问字段或子json对象

- `contains(字段名)`：返回字段是否存在
- `at(字段名)`：返回字段值，字段必须存在
- `get<T>()`：返回T类型的字段值
	- `myJson.at("username").get<std::string>()`：获取username的字段值
- `operator[]`：访问字段，字段不存在就添加
- `value(字段名,值)`：字段存在就返回字段值，字段不存在就返回指定值

### json和C++结构体转换

```Cpp
struct LoginRequest {
    std::int64_t user_id;
    std::string token;
};

void to_json(json& j, const LoginRequest& r) {
    j = json{
        {"user_id", r.user_id},
        {"token", r.token}
    };
}

void from_json(const json& j, LoginRequest& r) {
    j.at("user_id").get_to(r.user_id);
    j.at("token").get_to(r.token);
}
```