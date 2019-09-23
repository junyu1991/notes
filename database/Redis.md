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


## Redis Sentinel

Redis Sentinel(哨兵)系统是为提高Redis可用性而推出的一套分布式系统(也可单例运行)，哨兵系统具有Redis实例监控，消息通知，自动故障转移，
向客户端提供配置功能。

- **监控功能**，哨兵系统会检查所有的Redis主节点和从节点的运行状态。
- **消息通知**，哨兵系统会通过API向其它进程或者系统管理员通知Redis节点状态出现了异常。
- **自动故障转移**，当检测到Redis集群中的主节点因为异常而宕机时，哨兵系统会从从节点中选出新的主节点，然后其它的从节点会被重新配置连接新的主节点，
也会在客户端连接时通知其使用新的Redis地址。
- **向客户端提供配置功能**，客户端可向哨兵系统询问当前的Redis集群中的主服务器。当发生故障转移时，哨兵系统会提供新的地址。

Redis Sentinel是一套分布式系统，使用分布式有以下好处：

1. 进行故障监控时，只有多个哨兵系统就给定的Redis主机不可再用达成共识时，才会执行故障检测。降低了误报的可能性。
2. 即使不是所有的Sentinel进程都在工作，Sentinel仍能正常工作。即使不是所有的哨兵系统都正常工作也不会影响哨兵系统的功能。

#### Redis Sentinel使用

从Redis 2.8开始稳定版Redis Sentinel就被集成在Redis发布包中了，编译后的Redis中已经包含了Redis Sentinel。

启动Redis Sentinel：
``` shell
#使用redis-sentinel启动
redis-sentinel /path/to/sentinel.conf
#也可在启动redis-server时以哨兵模式启动
redis-server /path/to/sentinel.conf --sentinel
```
> 使用配置文件启动Redis Sentinel是强制要求的，如果没有指定sentinel配置文件，哨兵系统将不能被启动成功。

#### Redis Sentinel配置

Redis编译包中已经包含了sentinel配置示范文件**sentinel.conf**，该文件中包含了用于配置sentinel的基本配置项。
简略版配置文件如下：
``` conf
sentinel monitor mymaster 127.0.0.1 6379 2
sentinel down-after-milliseconds mymaster 60000
sentinel failover-timeout mymaster 180000
sentinel parallel-syncs mymaster 1

sentinel monitor resque 192.168.1.3 6380 4
sentinel down-after-milliseconds resque 10000
sentinel failover-timeout resque 180000
sentinel parallel-syncs resque 5
```

只需指定需要监控的主节点，如果有多个需要监控的主节点，则给每个需要监控的主节点取不同的名字即可。不需要指定从节点的信息，哨兵系统会
自动扫描从节点信息。哨兵会使用从节点的其他信息自动更新当前使用的配置文件。当发生故障转移以及新的哨兵连接时，哨兵也会更新当前使用的配置文件。

使用sentinel monitor设置监控项：
``` conf
sentinel monitor <master-group-name> <ip> <port> <quorom>
```
**quorom**是需要就主节点不可访问这一事实达成共识的哨兵人数，以便将子节点真正标记为发生故障，并在可能的情况下最终启动故障转移过程。该参数仅能用于故障检测。

其他参数：
- down-after-milliseconds 用于配置哨兵系统和被监控主机之间的延迟时间，当超过改时间哨兵系统未获取到被监控主机的消息，则会开始投票该主机是否已经宕机。
- parallel-syncs 设置在故障转移后可以重新配置为使用新主机的从机数量。该数字越小，完成故障转移过程所花费的时间就越多，但是，如果将从属服务器配置为提供旧数据，则您可能不希望所有从属服务器都与主服务器同时重新同步。虽然复制过程对于从属服务器几乎没有阻塞，但有一段时间会停止从主服务器加载批量数据。通过将此选项设置为值1，您可能希望确保一次只能访问一个从站。

sentinel与redis一致，可在运行期间修改配置项。