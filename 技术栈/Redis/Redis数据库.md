# NoSQL数据库

## 引入

### 技术分类

1. 解决功能性的问题
2. 解决扩展性的问题；项目的拓展要求不修改源代码，可以在框架的基础上开发，遵循框架的约束
3. 解决性能的问题

### web发展

1. web1.0

![[redis课程 Image[1].jpg | web1.0]]

2. web2.0

![[redis课程 Image[1] 1.jpg | web2.0]]

3. Web服务器CPU及内存压力

![[redis课程 Image[2] 2.jpg|CPU及内存压力]]

解决：缓存数据库

![[redis课程 Image[2] 3.jpg|缓存数据库]]

4. 数据库IO压力

解决：将频繁查询的数据放在缓存

![[redis课程 Image[2] 4.jpg|IO压力]]

## 概述

NoSQL：Not Only SQL，泛指非关系型数据库，不依赖于业务逻辑，以简单的key-value模式存储

特性：
1. 不遵循SQL标准
2. 不遵循ACID（事务的特性）
3. 性能远超SQL

适用场景：
1. 高并发读写
2. 大量数据读写
3. 数据高可拓展性

常见NoSQL数据库：
- Memcache：不支持持久化
- Redis：支持持久化，支持多种数据结构
- MongoDB：文档型数据库

# Redis概述

- 开源的key-value存储系统
- 支持的value类型比Memcache较多，数据操作都是原子性的
- 支持不同方式的排序
- 数据缓存在内存中
- 周期性的把数据写入磁盘中
- master-slave同步

| 场景 | 解决方案 |
|------|----------|
| 获取最新数据 | 通过List实现按自然时间排序的数据 |
| 排行榜 | 利用Zset有序集合 |
| 时效性的数据，比如手机验证码 | Expire过期 |
| 计数器、秒杀 | 原子性自增方法INCR DECR |
| 去除大量数据中的重复数据 | 利用Set集合 |
| 构建队列 | List集合 |
| 发布订阅消息系统 | pub/sub模式 |

- redis默认16个数据库实例，默认使用0号库
- redis：单线程，IO多路复用
	- memcached：串行，多线程

# Linux下的Redis

## 安装Redis

1. 将包`redis-6.2.1.tar.gz`上传到`/opt`目录下
2. 解包`tar -zxvf redis-6.2.1.tar.gz`
3. 进入`cd redis-6.2.1/`安装目录
4. `make`编译，前提：gcc环境

在`/opt/redis-6.2.1/src`下的可执行文件：
- `redis-benchmark`：性能测试工具
- `redis-check-aof`：修复有问题的AOF文件，持久化相关
- `redis-check-dump`：修复有问题的dump.rdb文件，持久化相关
- `redis-sentinel`：Redis集群使用
- `redis-server`：Redis服务器启动命令
- `redis-cli`：客户端，操作入口

可以将可执行文件和配置文件移动到`/usr/local/bin`

## Redis启动

### 前台启动

执行`./redis-server`

### 后台启动

1. 将`/opt/redis-6.2.1/redis.conf`移动到`/usr/local/bin`下
2. 将`redis.conf`中`daemonize`的值改为`yes`

- 启动Redis：`./redis-server redis.conf`，需要指定配置文件
	- `ps -aux | grep "redis"`检查是否运行
- 客户端连接Redis：`./redis-cli`
	- `ping`：查看是否ping通
	- `exit`：退出客户端
- 关闭Redis服务：`./redis-cli shutdown`
	- 若redis是多实例，可以指定端口号关闭：`redis-cli -p 6379 shutdown`

# 常用数据类型操作

## 基于key的操作

- `keys *`：查看当前数据库中的所有key值
- `set k1 mofei`：设置键k1的值，是string类型
- `type k2`：查看键k2的数据类型
- `exists k1`：判断键是否存在，存在为1，不存在为0
- `del k1`：删除键
- `expire k1 seconds`：设置键的过期时间
- `ttl k1`：查看键的存活时间，已过期就为负数
- `select index`：切换到指定数据库
- `dbsize`：查看数据库中键的个数
- `flushdb`：删除数据库中的所有键
- `flushall`：删除所有数据库中的所有键

## string

string是redis最基本的数据类型，最大512M

- `set k1 mofei`：给键值设置string类型的值，新值会覆盖旧值
- `get k1`：获取键的值
- `append k1 1214`：给键的值追加值，返回追加后的字符串长度
- `strlen k1`：获取字符串长度
- `setnx k2 fufu`：设置键的值，键不存在才会成功
- `incr num1`：使键值自增，对象必须是数字，原子操作
	- `incrby num1 5`：增加指定大小
- `decr num1 [count]`：使键值自减，对象必须是数字，原子操作
	- `decrby num1 5`：减少指定大小
- `mset k1 v1 [k2 v2 k3 v3...]`：批量设置键值
- `mget k1 [k2 k3...]`：批量获取键值
- `msetnx k1 v1 [k2 v2 k3 v3...]`：批量设置键值，要设置的所有键都不存在才会成功
- `getrange k1 start end`：根据起始下标和结束下标获取范围值
- `setrange k1 start fufu`：从起始下标开始覆盖范围值
- `setex k1 seconds v1`：设置键值的同时设置过期时间
- `getset k1 v1`：设置新值，返回旧值

## list

list是单键多值的列表，简单的字符串列表，底层是双向链表

数据结构：
元素较少时使用ziplist压缩列表，是一块连续的内存
元素较多时使用quicklist，将多个ziplist按链表方式组合

- `lpush k1 e1 [e2 e3...]`：从左边依次插入元素
- `rpush k1 e1 [e2 e3...]`：从右边依次插入元素
- `lrange k1 start end`：查询列表中指定范围的元素
	- `lrange k1 0 -1`：查询列表中所有元素
- `lpop k1 [count]`：从左边弹出一个元素并返回
- `rpop k1 [count]`：从右边弹出一个元素并返回
- `rpoplpush k1 k2`：弹出k1最右边的元素插入到k2最左边
- `lindex k1 index`：获取指定下标的元素值，从左边0开始
- `llen k1`：获取列表长度
- `linsert k1 before/after e1 e2`：在元素e1前/后插入e2
- `lrem k1 个数 e1`：从左边删除指定个数的元素e1
- `lset k1 index e1`：替换指定下标上的元素

## set

string类型的**无序**集合，**自动去重**，

数据结构：
底层是一个hash表，增删查时间复杂度是$O(1)$

- `sadd s1 e1 [e2 e3...]`：向s1中添加元素
- `smembers s1`：查询s1中的所有元素
- `sismember s1 e1`：判断e1是否是s1中的元素，返回1为真，0为假
- `scard s1`：获取s1中元素个数
- `srem s1 e1 [e2 e3...]`：删除指定元素
- `spop s1 [count]`：随机弹出一个元素
- `srandmember s1 [count]`：随机获取一个元素
- `smove s1 s2 e1`：将s1中的元素e1移动到s2
- `sinter s1 s2`：取s1和s2的交集
- `sunion s1 s2`：取s1和s2的并集
- `sdiff s1 s2`：取s1的补集

## hash

hash是一个string类型的field和value映射表，适合存储对象

数据结构：
field-value长度较短且数量较少，使用ziplist，否则使用hashtable

![[redis课程 Image[16].jpg | hash]]

- `hset h1 field1 value1 [field2 value2...]`：向hash添加field-value
- `hget h1 field1`：获取hash中指定标签的值
- `hmset h1 field1 value1 [field2 value2...]`：向hash批量添加field-value
- `hmget h1 field1 [field2...]`：批量获取hash中指定标签的值
- `hexists h1 field1`：判断h1中是否存在field1
- `hkeys h1`：获取所有field
- `hvals h1`：获取所有value
- `hdel h1 field1`：删除指定field-value
- `hincrby h1 field1 5`：指定field的value增加指定值
- `hincrby h1 field1 -5`：指定field的value减少指定值
- `hsetnx h1 field value`：向hash添加field-value，field不存在才添加成功

## zset

zset是没有重复元素的string集合，每个成员都关联了一个score，按照score排序，score可以重复

数据结构：
通过hash关联zset中的元素和score
通过跳表将元素排序

- `zadd z1 score1 e1 [score2 e2...]`：向zset添加元素
- `zrange z1 0 -1 [WITHSCORES]`：按score升序显示所有元素的值
	- `WITHSCORES`会同时显示score
- `zrangebyscore z1 min max [WITHSCORES]`：显示指定score区间的元素的值
- `zrevrangebyscore z1 max min [WITHSCORES]`：按降序显示指定socre区间的元素的值
- `zincrby z1 5 e1`：使e1增加/减少指定分数
- `zrem z1 e1`：删除指定元素
- `zcount z1 min max`：统计指定score区间的元素个数
- `zrank z1 e1`：查询指定元素的排名，最低为0

# 配置文件

## NETWORK网络

- `bind 127.0.0.1 -::1`：只有本主机才能访问，未设置bind不限制任何ip访问
- `protected-mode`：本主机的保护模式，关闭后其他主机可以远程连接redis
- `port`：默认端口号
- `tcp-backlog`：连接队列，未完成tcp三次握手和已完成三次握手，高并发环境下可以适当加大该值
- `timeout`：一个空闲的客户端维持多少秒会关闭，0表示永不关闭
- `tcp-keepalive`：检查客户端连接的间隔秒数

## GENERAL通用

- `daemonize`：`yes`表示前台运行，`no`表示后台运行
- `pidfile`：存放redis运行的pid
- `loglevel`：日志级别，默认为`notice`
- `logfile`：日志文件路径
- `databases`：默认的数据库个数，默认值为16

## SECURITY安全

- `requirepass foobared`：不使用密码

在redis内设置密码访问：
- `config get requirepass`：默认密码为空
- `config set requirepass password`：设置密码
- `auth password`：验证密码

## LIMITS限制

- `maxclients`：同时连接的最大客户端数量
- `maxmemory`：内存使用最大字节数
- `maxmemory-policy`：内存使用达到限制时使用的移除键值的策略

# 发布和订阅

发布订阅通信模式：发送者（生产者）发送消息，订阅者（消费者）接收消息

通过频道（channel）通信

1. 订阅者订阅频道（channel）：`subscribe channel1`
2. 发送者向频道发送消息，消息就会发送给订阅者：`publish channel1 message`

# 新数据类型

## bitmap

适合处理大批量数据

- `setbit bit1 offset 0/1`：向指定位置（偏移量）存0或1
- `getbit bit1 offset`：获取指定位置的值
- `bitcount bit1`：统计位图中1的个数
- `bitfield bit1 get/set/incrby`：操作指定位置的值
	- `bitfield bit1 get u2 0`：从0位置开始获取2个bit位的十进制值
- `bittop and/or/xor/not destkey k1 [k2,k3...]`：对多个位图作逻辑运算，结果保存在destkey，处理不同长度的位图时，短位图缺少的部分看作0
- `bitposi 0/1`：统计第一次出现0或1的位置

## HyperLogLog

解决基数问题：求集合中不重复元素个数的问题

不存储元素本身，以极小的内存代价计算大量数据的基数

- `pfadd p1 e1 [e2 e3...]`：向p1添加元素
- `pfcount p1`：统计p1的基数个数
- `pfmerge dest p1 [p2 p3...]`：将多个HyperLogLog合并到dest

## Geospatial

存储地理信息，两极无法直接添加

- `geoadd g1 longitude latitude e1 [longitude latitude e2...]`：添加位置信息
	- `geoadd china:city 121.47 31.23 shanghai`
- `geopos g1 e1`：获取指定元素的经纬度信息
- `geodist g1 e1 e2`：获取两个元素的直线距离
- `georadius g1 longitude latitude radius m|km|ft|mi`：显示指定区域（圆）内的元素

# 事务操作

特性：
- 事务中所有命令会按顺序执行，不会被其他命令打断
- 不保证原子性，若有一条命令出错，其他命令依然可能执行

## 基本操作

- `multi`：此后输入的命令进入命令队列，但不执行
- `exec`：按顺序执行命令队列中的命令
- `discard`：放弃事务，清空命令队列

错误处理：
- 组队时错误：某个命令入队时出错，整个事务都会取消
- 运行时错误：除了出错的命令，其他命令正常执行

## 事务冲突

多个客户端对数据库中的同一个临界资源读写时会造成事务冲突

![[redis课程 Image[31].jpg | 事务冲突]]

解决：
- 悲观锁（Pessimistic Lock）：悲观地认为每次访问数据都有其他客户端同时访问；在每次访问数据前给数据上锁，访问完后解锁；传统的关系型数据库使用的方式
	![[redis课程 Image[31] 3.jpg | 悲观锁]]
- 乐观锁（Optimistic Lock）：乐观地认为每次访问数据时没有其他客户端访问；给数据设置版本号，每次修改赋值时，检查修改后的版本号是否和修改前的版本号一致，若一致，修改成功，若不一致，修改失败；适用于多读的数据，提高吞吐量，redis使用的方式
	![[redis课程 Image[31] 6.jpg | 乐观锁]]

使用锁：
- `watch k1 [k2...]`：执行`multi`前监视一个或多个键值，若监视的键值在事务执行`exec`前被更改，事务会被打断

# 持久化操作

## RDB持久化

### 流程

redis单独fork一个子进程执行rdb持久化操作，先将数据写入到一个临时文件，持久化结束后再用临时文件替换上次的持久化文件，最后一次rdb持久化的数据可能丢失

![[redis课程 Image[34].jpg | rdb]]

优势：
- 适合大规模的数据恢复
- 节省磁盘空间
- 恢复速度快

劣势：
- 可能丢失最后一次持久化的数据
- fork创建子进程时消耗资源和性能

### 手动触发

- `SAVE`命令：阻塞当前redis服务器直到持久化完成
- `BGSAVE`命令：fork一个子进程来完成持久化

### 自动触发

`redis.conf`文件中：
- `save 60 10000`：自动触发条件，表示60秒内至少有10000个键值改变时触发
- `dbfilename`：rdb文件名，默认值为`dump.rdb`
- `dir`：rdb文件保存路径，默认值为`./`
- `stop-writes-on-bgsave-error`：当Redis无法写入磁盘，直接关掉Redis的写操作，推荐yes

## AOF持久化

Append Only File

以日志的形式记录每个写操作，只向aof文件追加，根据日志内容完成数据恢复

rdb和aof同时开启，系统默认读取aof的数据

`redis.conf`文件中：
- `appendonly`：是否开启aof持久化，默认关闭
- `appendfilename`：aof文件名，默认为`appendonly.aof`
- `appendfsync always`：每次写操作立即计入日志
- `appendfsync everysec`：每秒计入日志一次
- `appendfsync no`：不主动同步，同步时机交给系统

### Rewrite重写机制

aof文件追加导致文件越来越大，通过重写只保留恢复数据的最小指令集

fork得到子进程处理重写

`redis.conf`文件中：
- `no-appendfsync-on-rewrite`：
	- `yes`：不写入aof文件只写入缓存，用户请求不阻塞，提高性能
	- `no`：写入aof文件，可能阻塞，安全性高
- `auto-aof-rewrite-percentage`：重写的追加大小百分占比基准，默认为100，表示追加的大小为原来文件大小的100%时触发
- `auto-aof-rewrite-min-size`：触发的文件大小基准，默认64mb，表示文件达到64mb时触发

### 流程

![[redis课程 Image[37].jpg | aof]]

优势：
- 备份机制稳定
- 可读的日志文本，可以处理误操作

劣势：
- 占用磁盘空间大
- 备份速度慢

# 主从复制

主机（master）将数据同步到从机（slave）

- 主机负责处理写操作
- 从机负责处理读操作
- 主机只有一台，从机可以有多台

![[redis课程 Image[39].jpg | 主从复制]]

好处：
- 读写分离，性能扩展
- 容灾快速恢复

## 搭建主从复制

搭建前将`appendonly`关掉

1. 创建一个目录，用于存放redis配置文件 
	1. `mkdir /myRedis`
	2. `cp /usr/local/bin/redis.conf /myRedis/redis.conf`
2. 分别在`/myRedis`新建`redis6379.conf`，`redis6380.conf`，`redis6381.conf`配置文件，在`redis6379.conf`中：
	```
	include /myRedis/redis.conf
	pidfile /var/run/redis_6379.pid
	port 6379
	dbfilename dump6379.rdb
	```
	其他配置文件同理
3. 配置从机：在从机配置文件中添加：`slaveof 主机ip 主机端口号`，即`slaveof 127.0.0.1 6379`
4. 分别启动三个服务器
5. `redis-cli -p 6379`：指定端口号打开客户端
6. `info replication`查看服务器运行情况

## 原理

- 从机重启后依然是主机的从机，数据自动恢复
- 主机挂了以后从机依然是主机的从机

原理：
- slave连接master后发送sync命令，master接收命令后启动后台存盘进程，执行完成后将数据文件发送给slave
- 全量复制：slave接收数据后存盘并加载到内存
- 增量复制：master将新的修改命令发送给slave，完成同步
- slave连接master后，自动执行一次全量复制

### 薪火相传

master的一个slave可以是另一个slave的master，去中心化，减轻master的数据同步压力，但一台slave挂了以后其下的次级slave无法同步数据

### 反客为主

1. 关闭master
2. 将master的其中一个slave设置为主机：`slaveof no one`
3. 将其他的slave设置为新master的salve：`slaveof 主机ip 主机端口号`

## 哨兵模式

自动执行反客为主，若master挂了，根据投票机制自动将slave节点切换为master节点

1. 在`/myRedis`目录下创建文件`sentinel.conf`
2. 在`sentinel.conf`中定义`sentinel monitor 监控对象名 主机ip 主机端口号 哨兵个数`，即`sentinel monitor myMonitor 127.0.0.1 6379 1`，1表示至少需要一个哨兵同意迁移
3. 启动哨兵：`redis-sentinel /myRedis/sentinel.conf`，可以查看迁移日志

原来的master重启后会成为新master的slave

选举策略：
1. 选择优先级靠前的：`redis.conf`中`replica-priority`表示优先级，值越小优先级越高，默认为100
2. 选择偏移量大的，即同步主机数据最全的
3. 选择runid最小的：每个redis实例启动后都会随机生成一个40位的runid

# 集群

问题：
- 容量不够，需要扩容
- 分摊并发压力

解决方案：
- 代理主机：代理主机管理多个主机，客户端通过代理主机访问特定主机，每个主机（包括代理主机）至少需要一个从机
- 无中心化集群配置

## 分布式缓存解决方案

若有数亿个数据需要存储在缓存，需要搭建集群，有三种解决方案

### 哈希取余分区

hash(key)再对服务器个数取余决定数据存放再哪个节点上

![[docker容器技术 Image[58].jpg | 哈希取余分区]]

- 优点：简单，直接有效
- 缺点：扩缩容时，节点个数发生变化，映射关系需要重新计算

### 一致性哈希算法分区

1. 构造一致性哈希环：根据hash函数的值域构建一个线性的hash空间，比如$[0,2^{32}]$，计算出的hash对$2^{32}$取余
	![[docker容器技术 Image[59].jpg | 一致性哈希环]]
2. 服务器节点映射：将服务器IP映射到哈希环上
	![[docker容器技术 Image[59] 1.jpg | 映射服务器]]
3. 键值对映射：将要存储的键值对映射到哈希环上，然后从映射到的点开始顺时针移动到最近的服务器映射点，即为要键值对存储的服务器
	![[docker容器技术 Image[60].jpg | 映射键值对]]

- 优点：
	- 容错性：一个服务器节点挂了，键值对映射的点可以移动到下一个服务器映射的点
	- 扩展性：增加或减少服务器不会重新计算hash
- 缺点：服务器节点数量太少容易导致数据倾斜（大量数据存储在少量服务器上）

### 哈希槽分区

数据和节点之间加了一层哈希槽（hash slot）管理数据和节点的映射关系，通过CRC16算法再对哈希槽数量取余计算映射的节点

![[docker容器技术 Image[62] 4.jpg | 哈希槽]]

## 搭建Redis集群

搭建前在`redis.conf`关闭`protected-mode`，注释掉`bind`

1. 创建目录`/redis-cluster`，将`redis.conf`拷贝到该目录下
2. 搭建三主三从，创建6个配置文件，redis6379.conf文件中写入：
	```
	include /redis-cluster/redis.conf
	pidfile /var/run/redis_6379.pid
	port 6379
	dbfilename dump6379.rdb
	cluster-enabled yes
	cluster-config-file nodes-6379.conf
	cluster-node-timeout 15000
	```
	- `cluster-enabled yes`：打开集群模式
	- `cluster-config-file nodes-6379.conf`：设定节点配置文件名
	- `cluster-node-timeout 15000`：设定节点失联时间，超过该时间（毫秒），集群自动进行主从切换
	其他配置文件同理
3. 启动六个redis服务器，确保生成了`nodes-*`文件，进程状态有`[cluster]`
4. 将六个节点合并为一个集群
	1. 进入redis安装目录`/opt/redis-6.2.1/src`，确保`redis-cli`和`redis-trib.rb`文件存在
	2. 执行`redis-cli --cluster create --cluster-replicas 1 ip1:port1 ip2:port2 ip3:port3 ip4:port4 ip5:port5 ip6:port6`，ip地址用真实地址而不是`127.0.0.1`，`--replicas 1`表示采用最简单的方式配置集群：一主一从
5. 连接集群：`redis-cli -c -p 6379`
	- `-c`：使用集群方式连接redis
	- `-p`：指定端口号，可以使用集群内的任意主机的端口号
6. 查看集群：
	- `cluster nodes`：查看集群节点信息
	- `cluster info`：查看集群信息
	- `redis-cli --cluster check ip:port`：在redis外查看集群信息

## 集群操作原理

- 集群至少要有三个主节点；投票容错策略：至少有半数及以上的主节点都认为某个主节点挂了，这个节点才看作挂了
- `--cluster-replicas 1`表示希望为集群中的每个主节点创建一个从节点
- 分配原则：每个主机ip不同，主机和从机ip不同

### slot插槽

一个redis集群包含16384个插槽（hash slot），数据库中的每个key都属于这 16384 个插槽的其中一个，集群使用CRC16(key)%16384计算key属于哪个槽，插槽大致平均分配给每个主节点

### 集群中存取数据

- `set`，`get`正常使用
- 由于不同键hash得到的槽位不同，`mset`，`mget`需要加组名：
	- `mset k3{group0} aa k4{group0} bb`
	- `get k3{group0}`
- `cluster keyslot k1`：计算key的插槽值

### 故障恢复

集群中某个主节点挂了后集群会选举这个主节点下的一个分节点作为新的主节点，若原来的主节点恢复，会成为新的主节点的从节点

若集群中某个主节点及其所有从节点都挂了，根据`cluster-require-full-coverage`的值：
- `yes`：整个集群都挂掉
- `no`：集群不挂掉，但挂掉的节点的插槽都不能使用


# 应用问题

## 缓存穿透

大量访问redis缓存中不存在的数据的请求，服务器先访问redis缓存，redis缓存没有，就访问数据库，会给数据库极大压力

![[redis课程 Image[71].jpg | 缓存穿透]]

解决：
- 对空值缓存：若一个查询结果为空，则仍然将空值缓存到redis，过期时间很短
- 设置访问白名单：用bitmap存储白名单，偏移量表示id
- 布隆过滤器（Bloom Filter）：bitmap和随机映射函数，有一定的误识率
- 实时监控：发现redis命中率急剧降低，需要设置黑名单

## 缓存击穿

redis缓存中有数据但过期，此时有大量访问该数据的请求，会给数据库极大压力

![[redis课程 Image[72] 2.jpg | 缓存击穿]]

解决：
- 预设热门数据：将热门数据提前存入redis，延长过期时间
- 实时调整：实时监控热门数据，调整过期时间
- 使用锁：
	![[redis课程 Image[73] 2.jpg  | 锁]]

## 缓存雪崩

与缓存击穿类似，大量数据在redis缓存中同时过期，此时有大量并发访问请求，给数据库极大压力

解决：
- 构建多级缓存架构
- 加锁，避免高并发
- 给过期时间加上一个随机值，避免大量数据同时失效
- 记录缓存是否过期，过期就后台更新缓存

# 分布式锁

由于分布式系统的多个进程分布在不同主机上，传统的锁无效，需要分布式锁

方案：
- 基于数据库实现
- 基于缓存实现（redis）
- 基于Zookeeper

redis实现分布式锁：
- 上锁：`setnx mutex 10`，key不存在才能成功设置
- 解锁：`del mutex`，删除key
- 自动解锁：`expire mutex 5`，设置key的过期时间
- 原子性的上锁并设置自动解锁：`set mutex 10 nx ex 20`