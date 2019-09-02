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

## Redis配置

### redis-server 配置
