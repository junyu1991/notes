# Redis

## 简介

Redis，内存数据库，NoSql，可单独使用，也可集群使用，使用多个Redis构成集群服务能提高服务的稳定性。

## Redis安装

1. 下载Redis安装包，下载地址：[Redis Download Page](https://redis.io/download)，按照需求选择合适版本。（本例中使用5.0.5）
2. 解压下载的Redis压缩包。
3. cd至Redis解压包解压之后的文件夹，使用make命令进行Redis编译，等待编译完成。

## Redis运行

Redis主要的运行文件位于redis解压编译目录下的src目录中，主要使用的文件包括： **redis-server**,**redis-cli**,**redis-sentinel**
三个文件主要作用分别为：
- redis-server 用于启动或停止redis服务
- redis-cli redis客户端，用于连接redis server，主要用于查看数据，测试等作用
- redis-sentinel redis哨兵，用于监控redis server服务状态，使用redis集群时负责选举leader，详情见后面章节。

1. 启动redis server：
```shell script
redis-server /conf/filepath
``` 

2. 使用redis-cli连接redis server
```shell script
redis-cli -h host -p port 
#若redis server设置了密码，可使用-a参数指定密码，但不推荐这种连接，有泄露密码的风险，建议连接上redis server之后使用auth命令进行密码验证
```
 

## Redis配置

### redis-server 配置

## Redis数据结构即操作

#### 1. String

| 命令 | 作用 | 使用方法 | 说明 |
| :--- | :--- | :---: | :---: |
| set | 设置key的value值 | SET key value [expiration EX seconds\|PX milliseconds] [NX\|XX] | NX当key不存在时设置value，XX当key存在时才设置value |
| setnx | 在不存在key的前提下，设置key的value值，存在则不进行操作 | setnx key value | |
| mset | 同时设置多个key的value值 | mset key value [key value] | |
| setex | 设置key-value对，并设置其有效时间 | setex key seconds value | |
| setbit | 设置或更改指定key的value值的指定 | | |
| append | 将字符串添加至指定key中的value值尾，若key不存在则创建 | append key value | |
2. Hash
3. List
4. Set
5. Sorted Set
6. HyperLogLog Redis 
在 2.8.9 版本添加了 HyperLogLog 结构。Redis HyperLogLog 是用来做基数统计的算法，HyperLogLog 的优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定 的、并且是很小的。

## Redis操作命令

### String操作




