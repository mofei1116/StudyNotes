# Docker概述

问题：
开发环境，测试环境，生产环境的工具版本等问题，导致代码出错

解决：
系统平滑移植，容器虚拟化技术，软件带环境安装
将开发环境的代码，软件，配置文件等打包成一个镜像，在生产环境中通过docker引擎以容器的方式运行镜像

docker理念：一次镜像，处处运行

## 概念

docker是基于Go语言的云开源项目

虚拟机也是带环境安装的一种方案，在硬件层面虚拟化，捆绑操作系统，缺点：资源占用多，步骤多，启动慢

Linux容器（Linux Containers）对进程进行隔离，容器不需要捆绑一整套操作系统，只需要软件工作需要的资源和配置，在操作系统上虚拟化，复用主机的操作系统

docker比虚拟机有更少的抽象层，不需要实现硬件层面虚拟化

docker利用宿主机的内核，不需要加载操作系统内核

![[docker容器技术 Image[16] 1.jpg | 对比]]

| 操作系统 | 与宿主机共享OS | 宿主机OS上运行虚拟机OS |
|----------|---------------|----------------------|
| 存储大小 | 镜像小，便于存储与传输 | 镜像庞大（vmdk、vdi等） |
| 运行性能 | 几乎无额外性能损失 | 操作系统额外的CPU、内存消耗 |
| 移植性 | 轻便、灵活，适应于Linux | 笨重，与虚拟化技术耦合度高 |
| 硬件亲和性 | 面向软件开发者 | 面向硬件运维者 |
| 部署速度 | 快速，秒级 | 较慢，10s以上 |

优势：
- 快速的应用交付和部署
- 便携的升级和扩缩容
- 简单的系统运维
- 高效的计算资源利用

## Docker和Podman

podman是RedHat的无守护进程的容器引擎，用于在Linux系统上开发、管理和运行OCI容器

- 守护进程：docker使用守护进程，podman不使用守护进程
- 安全性：podman允许容器使用rootless特权，更安全
- 镜像构建：docker可以自己构建容器镜像，podman需要buildah工具辅助
- 模块化：docker独立，podman模块化

## Docker基本组成

- 镜像（Image）：只读的模板，镜像可以用来创建docker容器
- 容器（Container）：docker利用容器运行一个或多个程序，镜像和容器关系类似类和对象的关系
- 仓库（Repository）：集中存放镜像文件的场所

![[docker容器技术 Image[9].jpg | docker组成]]

# Linux下的Docker

## 安装Docker

1. 确保gcc环境：
	1. `yum -y install gcc`
	2. `yum -y install gcc-c++`
2. 安装软件包：`yum -y install yum-utils`
3. 设置镜像仓库：`yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo`，阿里云仓库
4. 更新yum软件包索引：`yum makecache`
5. 安装docker：`yum -y install docker-ce docker-ce-cli containerd.io`
6. 启动docker：`systemctl start docker`
7. 查看版本信息：`docker version`
8. 测试是否安装成功：`docker run hello-world`

![[docker容器技术 Image[16].jpg | docker run过程]]

## 添加镜像加速器

1. 创建目录`/etc/docker`
2. 创建文件`/etc/docker/daemon.json`
3. 写入：
	```json
	{
	  "registry-mirrors": [
	          "https://h4kz58fr.mirror.aliyuncs.com",
	          "https://docker.1ms.run"
	  ]
	}
	```

# 常用命令

## 帮助命令

- `docker --help`：查看`docker`命令帮助文档
- `docker 命令 --help`：查看指定命令的用法

## 镜像命令

- `docker images`：列出本主机上的镜像
	- `REPOSITORY`：表示镜像的仓库源
	- `TAG`：镜像的标签版本号，下载镜像时不指定版本号默认下载最新的版本
	- `-a`：显示所有
	- `-q`：只显示镜像id
- `docker search 镜像名`：指定搜索某个镜像
	- `--limit int`：指定显示搜索结果的条数
- `docker pull 镜像名[:版本]`：拉取指定镜像到本地，可以指定版本
- `docker load -i 镜像文件名.tar`：将tar镜像文件导入到本地
- `docker system df`：查看镜像，容器，数据卷占用磁盘空间
- `docker rmi 镜像名|镜像id`：通过镜像名或镜像id删除镜像，可以同时删除多个
	- `-f`：强制删除
	- `docker rmi -f $(docker images -qa)`：删除全部镜像

## 容器命令

### 运行容器

- `docker run [选项] 镜像名[:版本]`：启动容器
	- `--name=容器名`：指定容器名，不指定就随机
	- `-d`：后台运行并返回容器id
	- `-i`：交互模式运行，常与`-t`同时使用
	- `-t`：为容器分配一个伪输入终端
	- `-P`：随机端口映射
	- `-p`：指定端口映射，主机上的端口号映射到容器上的端口号，`主机端口:容器端口`，外界访问的是主机上的端口号
	- `docker run -it --name=u1 ubuntu /bin/bash`，`/bin/bash`交互式shell用来执行linux命令
- `docker ps`：列出正在运行的容器
	- `-a`：列出所有，包括历史
	- `-l`：列出最近的
	- `-n 个数`：指定列出的个数
	- `-q`：只显示容器id
- 退出`run`进入的容器：
	- `exit`：容器停止
	- 快捷键`ctl+p+q`：容器不停止
- `docker start 容器id|容器名`：启动已停止的容器
- `docker restart 容器id|容器名`：重启容器
- `docker stop 容器id|容器名`：停止容器
- `docker kill 容器id|容器名`：强制停止运行中的容器
- `docker rm 容器id|容器名`：删除已停止的容器
	- `-f`：强制删除运行中的
	- `docker rm -f $(docker ps -aq)`：强制删除多个容器

### 容器信息

- `docker logs 容器id`：查看容器日志
- `docker top 容器id`：查看容器的进程信息
- `docker inspect 容器id`：查看容器的详细信息
- `docker stats`：监控所有容器CPU，内存，网络流量等信息

### 进入容器

- `docker exec [参数] 容器id`：进入正在运行的容器，使用`exit`退出后容器仍然在运行
- `docker attach [参数] 容器id`：进入以前台方式运行的容器，使用`exit`退出后容器停止运行

### 容器备份

- `docker cp 容器id:容器内文件路径 目的主机路径`：拷贝容器内的文件到目的主机文件
- `docker export 容器id > 文件名.tar.gz`：导出容器
	- `cat 文件名.tar.gz | docker import - 镜像用户/镜像名[:版本]`：导入容器

# 镜像的底层原理

docker镜像是分层的文件系统，一个镜像可由多个镜像组成，每个分层的镜像有单独的功能，镜像可以通过分层来继承，基于基础镜像可以制作各种应用镜像

## 镜像加载原理

- bootfs（boot file system）：包含bootloader（引导加载程序），kernel（内核），bootloader主要是加载kernel
- rootfs（root file system）：在bootfs之上，各种linux的发行版，包含/bin，/etc等

![[docker容器技术 Image[30].jpg | 加载]]

分层的镜像是为了复用镜像

镜像层是只读的，容器层可写，对容器的改动都发生在容器层中

当容器启动时，一个可写的容器层加载到镜像顶部，容器层之下都是镜像层

![[docker容器技术 Image[31] 6.jpg| 分层]]

## 制作镜像

1. 运行容器并在容器内作出一些更改，比如`yum install vim`
2. `docker commit -m="描述信息" -a="作者" 容器id 目标镜像名[:版本]`

# 镜像仓库

![[docker容器技术 Image[33].jpg | 镜像推送]]

## 阿里云

前提：在阿里云创建一个公开的容器仓库

1. 登录阿里云：`docker login --username=mofei1214 crpi-nflqx3rvvb0zcup5.cn-chengdu.personal.cr.aliyuncs.com`
2. 推送镜像：
	1. `docker tag 镜像id crpi-nflqx3rvvb0zcup5.cn-chengdu.personal.cr.aliyuncs.com/mofei1214_docker/mofei1214_repository[版本]`
	2. `docker push crpi-nflqx3rvvb0zcup5.cn-chengdu.personal.cr.aliyuncs.com/mofei1214_docker/mofei1214_repository[:版本]`
3. 拉取镜像：`docker pull crpi-nflqx3rvvb0zcup5.cn-chengdu.personal.cr.aliyuncs.com/mofei1214_docker/mofei1214_repository:[版本]`

## 私有库

### 搭建私库

利用官方工具docker registry构建私有镜像仓库

- `docker pull registry`：拉取registry镜像
- `docker run -d -p 5000:5000 -v /krisswen/myregistry/:/tmp/registry --privileged=true registry`：运行registry
	- `-p`：指定一个或多个端口号
	- `-v`：绑定挂载数据卷
	- `/krisswen/myregistry/`：docker所在主机的目录
	- `/tmp/registry`：容器内的目录
	- `--privileged=true`：必须加，否则挂载失败

### 推送

需要保证registry在运行，且端口号`5000`打开

1.  使用curl工具查看私库上有什么镜像：`curl -XGET http://192.168.200.200:5000/v2/_catalog`，`192.168.200.200`是私库所在主机ip
2.  将要推送的镜像修改为符合私服库规范的Tag：`docker tag 源镜像名:版本 私库主机ip:端口号/目标镜像名:版本`，比如`docker tag a2:1.1 192.168.200.200:5000/anolis:1.1`
3. 修改docker配置文件`/etc/docker/daemon.json`支持http，添加：
	```json
	"insecure-registries": [
		  "192.168.200.200:5000"
	]
	```
	注意逗号
4. 重启docker和registry
5. 推送准备好的镜像：`docker push 192.168.200.200:5000/anolis:1.1`
6. 使用url检查私库上的镜像

### 拉取

- `docker pull 192.168.200.200:5000/anolis:1.1`

# 容器数据卷

## 概念

- 容器卷是目录或文件，docker所在的主机中的目录通过docker挂载到容器内的目录，类似redis的rdb和aof文件，可以保存容器在运行过程中产生的数据
- docker不会在删除容器时删除其挂载的卷
- 数据卷可以挂载到多个容器，可以实现数据共享
- 卷中的更改可以实时生效，不包含在镜像的更新中

![[Pasted image 20260907170454.png | 容器卷]]

## 案例

- 运行容器同时挂载数据卷：`docker run -it --privileged=true -v 宿主机目录:容器目录 镜像id|镜像名 /bin/bash`，目录不存在会创建，比如：`docker run -it --privileged=true -v /tmp/hostData:/tmp/dockerData1 anolis /bin/bash`
- 挂载关系形成后，一端的数据更改会立即同步到另一端；docker容器停止时在宿主机端修改的数据，在容器启动后也会同步
- 查看数据卷挂载信息：`docker inspect 容器id`，查看`Mounts`条目
- 使容器对数据卷只读：挂载时添加`ro`标识，比如：`docker run -it --privileged=true -v /tmp/hostData:/tmp/dockerData1:ro anolis /bin/bash`
- 继承其他容器的数据卷：`docker run -it --privileged=true --volumes-from 要继承的容器名|容器id 镜像名|镜像id /bin/bash`，子类和父类容器共享一个数据卷

# 常用软件安装

## 基础安装

### MySQL

1. 拉取镜像：`docker pull mysql:5.7`
2. 运行镜像：`docker run -d -p 3307:3306 --privileged=true -v /opt/mysql/log:/var/log/mysql -v /opt/mysql/data:/var/lib/mysql -v /opt/mysql/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=密码 --name=mysql mysql:5.7`
	- `-e`：设置环境变量
3. 在`/opt/mysql/conf`下创建文件`my.cnf`，文件中添加：
	```
	[client]
	default_character_set=utf8
	[mysqld]
	collation_server = utf8_general_ci
	character_set_server = utf8
	```
4. 重启容器
5. 进入容器：`docker exec -it d5ca9f74d5b3 /bin/bash`
6. 登录mysql：`mysql -u root -p`
7. 查看mysql编码：`SHOW VARIABLES LIKE '%character%';`

### Redis

1. 拉取镜像：`docker pull redis:6.0.8`
2. 创建目录`/opt/app/redis/`
3. 拷贝一个配置文件`redis.conf`到`/opt/app/redis`
4. 修改配置文件：
	1. `bind`设置为`0.0.0.0`，允许redis外部连接
	2. `daemonize`设置为`no`，否则与`docker run -d`冲突
	3. `appendonly`设置为`yes`，开始aof持久化
5. 运行镜像：`docker run -p 6379:6379 --name=redis --privileged=true -v /opt/app/redis/redis.conf:/etc/redis/redis.conf -v /opt/app/redis/data:/data -d redis:6.0.8 redis-server /etc/redis/redis.conf`

## 高级安装

### MySQL主从复制

#### 主从复制原理


##### 原理

- 数据库有一个binary log二进制文件，记录所有sql语句
- 三个线程处理主从复制：
	1. 主机为每个要同步的从机创建一个线程用于发送binary log文件
	2. 从机IO线程用于发送更新请求，接收binary log文件并拷到本地文件，包括relay log文件
	3. 从机创建一个SQL线程，读取relay log的更新并执行

![[docker容器技术 Image[51].jpg | 原理]]

##### 流程

1. 主库更新事件写到binary log
2. 从库连接到主机
3. 主库创建一个binlog dump thread线程，把binlog的内容发送到从库
4. 从库创建一个I/O线程，读取主库传过来的binlog内容并写入到relay log
5. 从库还会创建一个SQL线程，从relay log里面读取内容，从Exec_Master_Log_Pos位置开始执行读取到的更新事件，将更新内容写入数据库

##### 复制方式

![[docker容器技术 Image[52].jpg | 复制方式]]

#### 搭建主从复制

1. 创建mysql-master容器：
	```shell
	docker run -p 3307:3306 --name mysql-master \
	-v /mydata/mysql-master/log:/var/log/mysql \
	-v /mydata/mysql-master/data:/var/lib/mysql \
	-v /mydata/mysql-master/conf:/etc/mysql/conf.d \
	-e MYSQL_ROOT_PASSWORD=密码 \
	-d mysql:5.7
	```
2. 在`/mydata/mysql-master/conf`下创建文件`my.cnf`，文件中添加：
```
[mysqld]
## 设置server_id，同一局域网中需要唯一
server_id=101
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql
## 开启二进制日志功能
log-bin=mall-mysql-bin
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed
## 二进制日志过期清理时间。默认值为0，表示不自动清理。
expire_logs_days=7
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
```
3. 重启容器
4. 进入容器：`docker exec -it mysql-master /bin/bash`
5. 登录mysql：`mysql -u root -p`
6. 创建数据同步用户：
	1. 创建用户：`CREATE USER 'slave'@'%' IDENTIFIED BY '密码';`
	2. 授权用户：`GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';`
7. 创建`mysql-slave`容器：
	```shell
	docker run -p 3308:3306 --name mysql-slave \
	-v /mydata/mysql-master/log:/var/log/mysql \
	-v /mydata/mysql-master/data:/var/lib/mysql \
	-v /mydata/mysql-master/conf:/etc/mysql/conf.d \
	-e MYSQL_ROOT_PASSWORD=密码 \
	-d mysql:5.7
	```
8. 在`/mydata/mysql-slave/conf`下创建文件`my.cnf`，文件中添加：
```
[mysqld]
## 设置server_id，同一局域网中需要唯一
server_id=102
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql
## 开启二进制日志功能，以备Slave作为其它数据库实例的Master时使用
log-bin=mall-mysql-slave1-bin
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed
## 二进制日志过期清理时间。默认值为0，表示不自动清理。
expire_logs_days=7
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
```
9. 重启容器
10. 在主库中查看主从同步状态：`show master status;`
11. 进入mysql-slave容器，登录数据库
12. 从库中配置主从复制：`change master to master_host='宿主机ip', master_user='slave',master_password='密码', master_port=3307, master_log_file='mall-mysql-bin.000001', master_log_pos=617, master_connect_retry=30;`，注意master_log_pos和主机中查看的position参数保持一致
	- master_host：主数据库的IP地址
	- master_port：主数据库的运行端口
	- master_user：在主数据库创建的用于同步数据的用户账号
	- master_password：在主数据库创建的用于同步数据的用户密码
	- master_log_file：指定从数据库要复制数据的日志文件，通过查看主数据的状态，获取File参数
	- master_log_pos：指定从数据库从哪个位置开始复制数据，通过查看主数据的状态，获取Position参数
	- master_connect_retry：连接失败重试的时间间隔，单位为秒
13. 在从库开启主从同步：`start slave;`
14. 在从库中查看主从同步状态：`show slave status \G;`，查看`Slave_IO_Running`和`Slave_SQL_Running`为Yes

### Redis集群

#### 集群搭建

1. 启动6个redis容器，6381：`docker run -d --name redis-node-1 --net host --privileged=true -v /data/redis/share/redis-node-1:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6381`
2. 进入容器redis-node-1并为6台机器构建集群关系：
	1. `docker exec -it redis-node-1 /bin/bash`
	2. `redis-cli --cluster create ip1:port1 ip2:port2 ip3:port3 ip4:port4 ip5:port5 ip6:port6 --cluster-replicas 1`
3. 在任意一个容器内进入redis查看集群状态：
	1. `redis-cli -p 6381`
	2. `cluster info`
4. 连接集群：`redis-cli -c -p 6381`

#### 集群扩容

3主3从扩为4主4从

1. 启动2个redis容器6387，6388
2. 进入6387容器，作为master加入集群：
	1. `docker exec -it redis-node-7 /bin/bash`
	2. `redis-cli --cluster add-node 新节点ip:新节点port 旧节点ip:旧节点port`：旧节点ip和旧节点port可以用集群中任意一个节点的
3. 重新分配插槽：`redis-cli --cluster rehard ip:port`，要分配的插槽数设置为16384/主节点数，插槽来源设置为所有原来的主节点
4. 分配从节点：`redis-cli --cluster add-nocde 新从ip:新从port 新主ip:新主port --cluster-slave --cluster-master-id 新主id`

#### 集群缩容

4主4从缩为3主3从

1. 删除一个从节点：`redis-cli --cluster del-node 要删ip:要删port 要删节点id`
2. 重新分配插槽，将要删的主节点的插槽全部分给其他主节点：`redis-cli --cluster reshard ip:port`
3. 删除从节点：`redis-cli --cluster del-node 要删ip:要删port 要删节点id`

# Dockerfile

dockerfile用来构建镜像

![[docker容器技术 Image[77].jpg | 构建镜像]]

1. 每条保留字指令必须大写且后面至少要有一个参数
2. 指令按从上到下顺序执行
3. `#`注释
4. 每条指令都会创建一个新的镜像层并对镜像进行提交

## 流程

1. docker从基础镜像运行一个容器
2. 执行一条指令对容器修改
3. 提交一个新的镜像层
4. docker基于刚提交的镜像运行一个新容器
5. 执行下一条指令，循环
6. `docker build -t 镜像名:版本 目录`，目录指Dockerfile所在目录

## 常用保留字

- `FROM`：基础镜像，作为模板，第一条指令必须是FROM
- `MAINTAINER`：维护者名字邮箱信息
- `RUN`：构建时需要执行的命令，在`docker build`的时候运行
	- shell格式
	- exec格式：`RUN ["可执行文件名","参数1","参数2"]`
- `EXPOSE`：对外打开的端口
- `WORKDIR`：创建容器后，默认的工作目录
- `USER`：指定用户，默认是root
- `ENV`：设置环境变量，`ENV 变量名 值`，使用环境变量需要加`$`
- `VOLUME`：指定容器数据卷
- `ADD`：将宿主机的文件拷贝到容器，会自动处理URL和tar压缩包
- `COPY`：类似`ADD`，`COPY src dest`，自动添加不存在的目录
- `CMD`：启动容器后要执行的命令，shell格式和exec格式，只有最后一个CMD指令生效，但可能被`docker run`后的参数替换，如`/bin/bash`
- `ENTRYPOINT`：类似`CMD`，不会被替换，`ENTRYPOINT ["可执行文件名","参数1","参数2"]`，若`docker run`后有参数，会传给`ENTRYPOINT`指定的程序；`ENTRYPOINT`和`CMD`一起使用时，`CMD`不执行命令而是给`ENTRYPOINT`传参

## 虚悬镜像

虚悬镜像是名称和标签都为`<none>`的镜像，没有实际价值，一般需要删除

- `docker image ls -f dangling=true`：查看所有虚悬镜像
- `docker image prune`

# Docker网络

启动docker后用`ifconfig`查看网络信息，docker0是一个虚拟网桥，可以实现宿主机和docker容器以及docker容器之间的通信

`docker network ls`：查看3中网络模式

| 网络模式 | 简介 |
|----------|------|
| bridge | 为每一个容器分配、设置ip，并将容器连接到一个名为docker0的虚拟网桥，默认为该模式。 |
| host | 容器将不会虚拟出自己的虚拟网卡，设置自己的ip等。而是使用宿主机的ip的端口。使用--network host 参数可以指定。 |
| none | 容器有独立的network namespace，但并没有对其进行任何网络设置，仅分配veth pair和网络桥接ip等。使用--network none参数指定。一般很少使用。 |
| container | 新创建的容器不会创建自己的网卡和设置自己的ip。而是和一个指定的容器共享ip端口范围等。 |

## 基本命令

- `docker network ls`：查看网络
- `docker network inspect 网络名`：查看网络的详细信息
- `docker network create 网络名`：创建一个网络
- `docker network rm 网络名`：删除网络
- `docker inspect 容器名`：在`Networks`查看容器的网路信息

## 网络模式

### bridge模式

docker服务默认创建一个docker0网桥，连通其他网卡，让主机和容器可以通过docker0通信，同时也是容器的默认网关

docker容器启动时会分配一个Container-IP

docker容器ip产生规则：在bridge模式下，新运行的容器可能会分配到已关闭的容器曾用过的ip

docker0创建成对的虚拟设备接口veth-eth0（veth pair）彼此联通，veth在docker0网桥上，eth0在容器和主机上

![[docker容器技术 Image[94].jpg | bridge]]

### host模式

运行容器时通过`--network host`参数指定，使用host模式后指定的端口号映射会失效

直接使用宿主机的IP地址与外界进行通信，不再需要额外进行NAT转换，和宿主机共用一个Network Namespace

![[docker容器技术 Image[95].jpg | host]]

### container模式

运行容器时通过`--network container:被共享的容器`参数指定

共享某个容器的网络ip配置，不会创建自己的网卡，配置自己的ip

![[docker容器技术 Image[97].jpg | container]]

### 自定义模式

运行容器时通过`--network 网络名`参数指定

使用bridge模式，容器的ip在某些情况下会变换，使用容器ip通信可能产生问题，可以使用容器名通信

两个bridge模式的容器可以通过ip相互ping通，但不能通过容器名ping通，使用自定义模式可以ping通

自定义网络本身就维护好了主机名和ip的对应关系（ip和域名都能通）

# Docker Compose

docker compose实现对docker容器集群的快速编排

定义docker-compose.yml，写好多个容器之间的调用关系，可以同时打开/关闭多个容器

使用步骤：
1. 构造镜像文件
2. 使用`docker-compose.yml`定义一个完整的业务单元
3. `docker-compose up`启动并运行整个应用程序

## 安装

1. ``curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose``
2. `chmod +x /usr/local/bin/docker-compose`
3. `docker-compose --version`

## 基本命令

- `docker-compose -h`：查看帮助
- `docker-compose up`：启动所有docker-compose服务
- `docker-compose up -d`：启动所有docker-compose服务并后台运行
- `docker-compose down`：停止并删除容器、网络、卷、镜像。
- `docker-compose exec yml里面的服务id`：进入容器实例内部，可以指定shell，比如`/bin/bash`
- `docker-compose ps`：展示当前docker-compose编排过的运行的所有容器
- `docker-compose top`：展示当前docker-compose编排过的容器进程
- `docker-compose logs yml里面的服务id`：查看容器输出日志
- `docker-compose config`：检查配置
- `docker-compose config -q`：检查配置，有问题才有输出
- `docker-compose restart`：重启服务
- `docker-compose start`：启动服务
- `docker-compose stop`：停止服务

## 实例

编写微服务的yml文件：
```yml
version: "3"

services:
	microService:
		image: account_docker:1.1
		container_name: account
		ports:
			- "7001:7001"
		volumes:
			- /app/microService:/data
		networks:
			- wen_net
		depends_on:
			- mysql
	mysql:
		image: mysql:5.7
		environment:
			MYSQL_ROOT_PASSWORD: '123456'
			MYSQL_ALLOW_EMPTY_PASSWORD: 'no'
			MYSQL_DATABASE: 'docker'
			MYSQL_USER: 'wen'
			MYSQL_PASSWORD: 'wen123'
		ports:
			- "3306:3306"
		volumes:
			- /app/mysql/db:/var/lib/mysql
			- /app/mysql/conf/my.cnf:/etc/my.cnf
			- /app/mysql/init:/docker-entrypoint-initdb.d
	networks:
		- wen_net
	command: --default-authentication-plugin=mysql_native_password #解决外部无法访问
networks:
	wen_net:

```

# Docker可视化工具

## Portainer

Portainer是一款轻量级的应用，它提供了图形化界面，用于方便地管理Docker环境，包括单机环境和集群环境

安装：
1. docker命令安装：`docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer`
2. 在浏览器访问`ip:9000`访问

## CIG

CAdvisor监控收集+InfluxDB存储数据+Granfana展示图表

![[docker容器技术 Image[109].jpg | CIG]]

- CAdvisor:
	- 展示Host和容器两个层次的监控数据
	- 展示历史变化数据
- InfluxDB：
	- 基于时间序列，支持与时间相关的函数
	- 可度量性，可以实时对大量数据进行计算
	- 它支持任意的事件数据
- Granfana：
	- 丰富灵活的图形化选项
	- 多个数据源

### 搭建CIG

1. 在目录`/mydocker/cig`下创建文件`docker-compose.yml`，写入：
```yml
version: '3.1'

volumes:
	grafana_data: {}

services:
	influxdb:
		`image: tutum/influxdb:0.9
		restart: always
		environment:
			- PRE_CREATE_DB=cadvisor
		ports:
			- "8083:8083"
			- "8086:8086"
		volumes:
			- ./data/influxdb:/data`
	cadvisor:
		image: google/cadvisor
		links:
			- influxdb:influxsrv
		command: -storage_driver=influxdb -storage_driver_db=cadvisor -storage_driver_host=influxsrv:8086
		restart: always
		ports:
			- "8080:8080"
		volumes:
			- /:/rootfs:ro
			- /var/run:/var/run:rw
			- /sys:/sys:ro
			- /var/lib/docker/:/var/lib/docker:ro
	grafana:
		user: "104"
		image: grafana/grafana
		user: "104"
		restart: always
		links:
			- influxdb:influxsrv
		ports:
			- "3000:3000"
		volumes:
			- grafana_data:/var/lib/grafana
		environment:
			- HTTP_USER=admin
			- HTTP_PASS=admin
			- INFLUXDB_HOST=influxsrv
			- INFLUXDB_PORT=8086
			- INFLUXDB_NAME=cadvisor
			- INFLUXDB_USER=root
			- INFLUXDB_PASS=root

```
2. 启动`docker-compose.yml`
	1. `docker-compose config -q`，检查配置
	2. `docker-compose up`，启动

### 访问服务

- 访问CAdvisor：`ip:8080`
- 访问InfluxDB：`ip:8083`
- 访问Granfana：`ip:3000`

# Swarm Mode

Swarm Mode用于多主机的容器编排

## 基本概念

运行docker的主机可以初始化一个swarm集群或加入一个swarm集群

- 管理节点：执行命令，将服务下发到工作节点
- 工作节点：执行任务

![[docker容器技术 Image[120].jpg | swarm集群]]

- 任务：swarm中的最小调度单位
- 服务：一组任务的集合，通过`docker service create`的`--mode`参数指定模式
	- replicated services：按一定队则在各个工作节点上运行指定个数的任务
	- global services：每个工作节点上运行一个任务

![[docker容器技术 Image[121].jpg | 任务/服务]]

## 搭建swarm集群

搭建一个管理节点，两个工作节点

1. 在三台主机上运行docker
2. 创建管理节点`docker swarm init --advertise-addr 主机ip`
3. 根据创建管理节点时的提示在另外两个主机上创建工作节点并加入集群
4. 在管理节点上查看节点信息：`docker node ls`

## 服务部署

### 使用命令

- 新建nginx服务：`docker service create --replicas 3 -p 80:80 --name nginx nginx:1.13.7-alpine`，浏览器`ip:80`可以访问nginx
- 查看swarm集群运行的服务：`docker service ls`
- 查看服务日志：`docker service logs 服务名`
- 查看服务信息：`docker service ps 服务名`
- 改变服务运行的容器数量：`docker service scale 服务名=运行服务的容器数`
- 删除服务：`docker servie rm 服务名`

### 使用docker-compose文件

使用docker-compose.yml可以一次性启动多个关联的服务

1. 进入`/swarm`目录创建`docker-compose.yml`，写入：
```yml
version: "3"

services:
	wordpress:
		image: wordpress
		ports:
			- 80:80
			networks:
			- overlay
		environment:
			WORDPRESS_DB_HOST: db:3306
			WORDPRESS_DB_USER: wordpress
			WORDPRESS_DB_PASSWORD: wordpress
		deploy:
			mode: replicated
			replicas: 3
	db:
		image: mysql
		networks:
			- overlay
		volumes:
			- db-data:/var/lib/mysql
		environment:
			MYSQL_ROOT_PASSWORD: somewordpress
			MYSQL_DATABASE: wordpress
			MYSQL_USER: wordpress
			MYSQL_PASSWORD: wordpress
		deploy:
			placement:
				constraints: [node.role == manager]
	visualizer:
		image: dockersamples/visualizer:stable
		ports:
			- "8080:8080"
		stop_grace_period: 1m30s
		volumes:
			- "/var/run/docker.sock:/var/run/docker.sock"
		deploy:
			placement:
				constraints: [node.role == manager]
volumes:
	db-data:
networks:
	overlay:
```
2. 部署服务：`docker stack deploy -c docker-compose.yml 服务名`
3. 查看服务：`docker stack ls`
4. 浏览器`ip:8080`可以查看节点运行状态