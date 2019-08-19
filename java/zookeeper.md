# Zookeeper

Zookeeper是一个为分布式应用设计的开源分布式服务。它向分布式应用提供了如同步，配置管理，分组以及命名等高级服务实现。

## Zookeeper设计

1. zookeeper允许分布式进程通过和标准文件系统(文件和目录)类似的分层命名空间(znodes)与其他进程进行协调工作。
2. zookeeper会从同一组中的zookeeper中复制数据，在同一组中的zookeeper必须知道其他的所有的zookeeper信息（在配置文件中配置）。
组成zookeeper service的所有zookeeper服务器会维护状态的内存镜像以及持久性存储中的事务日志以及快照。
3. zookeeper是有序的？
4. zookeeper速度特别快，特别是在读写比为10:1时效率最高。

## Zookeeper数据模型和分层命名空间

zookeeper提供的命名空间和标准的文件系统非常相似，一个命名是由一串被 **/** 分割的序列组成，如: /service/testapp 。在zookeeper
的命名空间中的每个节点(node)都是由一个路径来标识。

## zookeeper节点

1. zookeeper节点中包含有短暂节点和永久节点(?)，短暂节点只会在创建此节点(create -e)的会话（session）有效时存在。当会话失效时节点会被立即删除。

2. zookeeper支持给没给节点添加watch事件，客户端可以给节点设置watch，当节点被删除或者节点信息被改变时，watch事件均会被触发，
当watch事件被触发时，如果添加了watch的客户端与zookeeper之间的连接未断，客户端会收到包信息通知节点已被修改，但此通知是一次性的，
即触发watch事件后，后续节点变化就不会再通知了，如果需要继续监视节点，则需另外的处理。

3. zookeeper节点常见的操作:
 3.1 create 创建节点
 3.2 delete 删除节点
 3.3 exists 测试是否存在节点
 3.4 get data 从节点中读取数据
 3.5 set data 将数据写入到节点中，zookeeper的写入信息是全覆盖，不会修改部分信息
 3.6 get children 检索节点的子节点列表
 3.7 sync 

4. zookeeper特性
 4.1 时序性，客户端更新操作将按发送顺序实现。
 4.2 原子性，更新操作要么成功，要么失败，不会只操作成功一部分。
 4.3 单系统映像(Single System Image)，无论客户端连接的是zookeeper services中哪台服务器，获取到的服务视图都是一样的。
 4.4 可靠性，只要节点信息被更新了，节点值将会一直持久化知道另外的更新操作修改了该节点的值。
 4.5 timeliness(实时性)，保证客户端在特定时间范围内获取到的数据是最新的。

## Zookeeper实现原理

![zookeeper components](./img/zkcomponents.jpg)

Zookeeper包含三个组件：Request Processor, Atomic Broadcast, Replicated Database.
除请求处理器(Request Processor)外，构成ZooKeeper服务的每个服务器都复制其自己的每个组件的副本。
Replicated Database是包含了整个数据树的内存数据库。更新操作会被记录到磁盘以提供恢复操作，并且在写入到内存中之前会先序列化到磁盘。atabase是包含了整个数据树的内存数据库。更新操作会被记录到磁盘以提供恢复操作，并且在写入到内存中之前会先序列化到磁盘。
当客户端进行读操作时，zookeeper会从本地的内存数据库中获取信息直接返回，进行写操作时，zookeeper则会进行一系列操作：
客户端中的所有写操作请求都被转发到主节点zookeeper服务器，主节点再将更新信息转发给所有的从节点，从节点接收来自主节点的更新消息并进行本地更新。



