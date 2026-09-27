# 解压缩类

## zlib

主要提供DEFLATE算法压缩和解压，通常调用C接口

头文件`zlib.h`

编译时链接库`-lz`

### 简单解压缩

- `uLong compressBound(uLong sourceLen);`：返回要压缩的数据所需的最大缓冲区大小
- `int compress(Bytef* dest,uLongf* destLen,const Bytef* source,uLong sourceLen);`：压缩，成功返回`Z_OK`
- `int uncompress(Bytef* dest,uLongf* destLen,const Bytef* source,uLong sourceLen);`：解压缩，成功返回`Z_OK`
- `int compress2(Bytef* dest,uLongf* destLen,const Bytef* source,uLong sourceLen,int level);`：指定压缩级别（0-9），可以用`Z_DEFAULT_COMPRESSION`，，成功返回`Z_OK`

### 流式解压缩

对大数据分块处理

