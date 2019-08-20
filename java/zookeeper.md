# Zookeeper

Zookeeper是一个为分布式应用设计的开源分布式服务。它向分布式应用提供了同步，配置管理，分组以及命名等高级服务。

## Zookeeper设计

1. zookeeper允许分布式进程通过和标准文件系统(文件和目录)类似的分层命名空间(znodes)与其他进程进行协调工作。
2. zookeeper会从同一组中的zookeeper中复制数据，在同一组中的zookeeper必须知道其他的所有的zookeeper信息（在配置文件中配置）。
组成zookeeper service的所有zookeeper服务器会维护状态的内存镜像以及持久性存储中的事务日志以及快照。
3. zookeeper是有序的？
4. zookeeper速度特别快，特别是在读写比为10:1时效率最高。

## Zookeeper数据模型和分层命名空间

zookeeper提供的命名空间和标准的文件系统非常相似，一个命名是由一串被 **/** 分割的序列组成，如: /service/testapp 。在zookeeper
的命名空间中的每个节点(node)都是由一个路径来标识。

## Zookeeper节点

1. zookeeper节点中包含有瞬时节点和永久节点，瞬时节点只会在创建此节点(zkCli.sh使用create -e创建)的会话（session）有效时存在。当会话失效时节点会被立即删除。
瞬时节点可用于服务注册，分布式锁等功能。

2. zookeeper提供了节点监控(watch)功能，客户端可以给需要监控的节点设置监控(watch)，当被监控节点被删除或者节点信息被改变时，watch事件会被触发，
watch事件被触发时，添加了该节点监控(watch)的客户端会收zookeeper server发送的信息(需要客户端和zookeeper服务之间保持连接)，包信息中不包括节点的新状态（节点值或者节点是否存在）
watch事件通知是一次性的，触发watch事件后并发送信息后，之前设置的监控就失效了，后续节点变化就不会再通知客户端了，如果需要继续监视节点，则需重新添加监控事件。

3. zookeeper节点常见的操作:
 3.1 create 创建节点
 3.2 delete 删除节点
 3.3 exists 测试是否存在节点
 3.4 get data 从节点中读取数据
 3.5 set data 将数据写入到节点中，zookeeper的写入信息是全覆盖，不会只修改部分信息
 3.6 get children 检索节点的子节点列表
 3.7 sync 

4. zookeeper特性
 4.1 时序性，客户端更新操作将按发送顺序实现。
 4.2 原子性，更新操作要么成功，要么失败，不会出现中间状态。
 4.3 单系统映像(Single System Image)，无论客户端连接的是zookeeper集群中哪台服务器，获取到的数据都是一样的。
 4.4 可靠性，只要节点信息被更新了，节点值将会被持久化保存直到其他更新操作修改了该节点的值。
 4.5 timeliness(实时性)，保证客户端在特定时间范围内获取到的数据是最新的。

## Zookeeper实现原理

![zookeeper components](./img/zkcomponents.jpg)

Zookeeper包含三个组件：Request Processor, Atomic Broadcast, Replicated Database.
除请求处理器(Request Processor)外，构成ZooKeeper服务的每个服务器都复制其自己的每个组件的副本。
Replicated Database是包含了整个数据树的内存数据库。更新操作会被记录到磁盘以提供恢复操作，并且在写入到内存中之前会先序列化到磁盘。database是包含了整个数据树的内存数据库。更新操作会被记录到磁盘以提供恢复操作，并且在写入到内存中之前会先序列化到磁盘。
当客户端进行读操作时，zookeeper会从本地的内存数据库中获取信息直接返回，进行写操作时，zookeeper则会进行一系列操作：
客户端中的所有写操作请求都被转发到主节点zookeeper服务器，主节点再将更新信息转发给所有的从节点，从节点接收来自主节点的更新消息并进行本地更新。

## Zookeeper角色

Zookeeper可使用单机模式，也可多个Zookeeper节点组成集群服务，多个节点可提高分布式服务可靠性。当使用Zookeeper集群时，Zookeeper可有三个角色：leader，follower，observer。
leader主要负责进行投票(写请求)的发起和决议，更新系统状态。也可处理客户端的读写请求，处理读请求时直接返回节点本地数据库中的数据，处理写请求时会负责写请求投票的发起和决议，以达到数据统一，leader还会处理其他节点（follower，observer）发送的写请求：进行投票的发起和决议。
follower主要处理客户端的读写请求，与leader不同的是处理写请求时是将写操作请求转发至leader，follower还需要在leader宕机时进行投票选举，选举出新的leader。
observer不进行投票（既不投票选leader，也不投票写操作），其他功能和follower相同，处理客户端的读写请求。observer主要是为了解决：过多的follower会导致Zookeeper服务的写入性能降低。因为写操作需要集群中至少一半的节点投票达成一致，因此随着更多的投票者增加，投票成本会更高。

由于observer不投票，所以他们不是zookeeper集群的重要组成部分，因此当observer出现异常宕机时对zookeeper集群影响也不大，不会影响zookeeper的可用性。

### 使用observer
在observer zookeeper配置文件中添加：
```
peerType=observer
```
在所有的zookeeper服务器配置文件的server定义处给每个observer添加 **:observer** ，如：
```
server.1:localhost:2181:3181:observer
```




