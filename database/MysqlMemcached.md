# memcached

## 优势

- memcached将所有的信息都存储在内存中，因此读取速度相比每次都从硬盘中读取更快。
- memcached采用**key-value**对的形式存储信息，而对于**value**的数据类型并未做限制，
所以可用于存储结构复杂的信息，如图片，文档等。

## memcached限制

- memcached将所有的信息均保存在内存中，并没有持久化数据，因此当memcached宕机或者重启之后，之前缓存的
信息均需要重新查询数据库手动加载，不能自动加载之前缓存的信息。
- memcached没有提供任何安全协议，没有登录限制，没有权限限制，因此memcached最好用于缓存不重要的信息，
重要敏感的信息需要使用者自己加密存储
- memcached没有提供任何的故障转移功能，即使是使用了多个memcached server，各个memcached server之间也是
相互独立的，互相之间并没有连接，当其中一个memcached server出现故障时只能将其移出服务列表并将其中的缓存的信息
手动存储到另外的memcached server中。**memcached不能组成集群缓存服务。**
- memcached server与客户端之间可能存在延迟的问题
- memcached server决定了key的长度，默认最大长度为250 byte

## memcached常用的场景

memcached常用作缓存作用，应用首先从memcached中获取信息，若memcached中没有相应的信息，则从数据库中查询，
并将查询到的信息存储到memcached中，以提高后续查询请求的查询效率。

## memcached安装

安装memcached有两种方式，一是使用Linux自带的包管理程序安装，二是源码编译安装。

- 使用Linux系统自带的包管理安装memcached
```shell script
yum install memcached #Red Hat或者Fedora系统
apt install memcached #Debian或者Ubuntu系统
emerge install memcached #Gentoo系统
```

- 源码安装

1. 到[http://memcached.org/](http://memcached.org/)网站下载memcached源码包
2. 解压源码压缩包，cd至解压后的目录中开始编译并安装，主要脚本为：
```shell script
gunzip -c memcached-1.2.5.tar.gz | tar xf -
cd memcached-1.2.5
./configure #设置编译选项，以下为可选编译项
#--prefix指定安装地址，
#--with-libevent若系统中没有安装libevent依赖，则用此参数指定libevent路径
#--enable-64bit编译64位版本的memcached（memcached运行时可申请更大的内存空间）
#--enable-threads编译支持多线程的memcached
#--enable-dtrace编译包含一系列DTrace线程的memcached，可用于监视和标记memcached实例
make #编译
make install #安装
```

## memcached使用

1. 启动memcached server，使用memcached运行文件即可启动memcached server
```shell script
memcacehd -d -m 1024 -p 11211 -l 192.168.0.101
```
启动参数：

| 参数 | 参数说明 |
| :--- | :--- | 
| -u user | 如果以root权限启动memcached，使用此参数可指定memcached server的运行用户 |
| -m | 指定memcached使用的最大内存，单位为MB，不指定该参数默认为64MB |
| -d | 指定memcached以后台守护进程的方式运行 |
| -p | 指定memcached server监听端口，不指定则该参数默认为11211 |
| -l | 指定memcached绑定ip |
| -U | 指定UDP连接的端口，如果是0则关闭UDP连接 |
| -s | 指定unix socket监听文件，主要用于客户端和memcached server在同一机器的情景下，使用此参数默认关闭memcached的网络功能，主要使用Unix domain socket进行连接 |
| -a | 指定Unix socket文件的权限，默认为0700 |
| -c | 指定memcached server同时最大客户端连接数，默认为1024 |
| -t | 指定memcached server用于处理连接请求的多线程线程数，默认为4 |
| -r | 当memcached发生故障时会将当前memcached整个内存中的信息导出到一个核心文件中，最高可达setrlimit设置的值。此参数用于设置核心文件的最大值。 |
| -M | 当内存耗尽时向客户端返回错误信息，用于取代从缓存中删除旧项目，以便为新项目腾出空间的正常行为。 |
| -k | 锁定所有分页内存。 |
| -v | 详细模式(?)，打印运行过程中的错误和警告信息。 |
| -vv | -v模式的加强版，还会打印每个客户端的命令以及返回包 |
| -vvv | -vv的加强，还会显示内部状态的转换信息。 |
| -h | 打印帮助文档并退出 |
| -i | 打印memcached和libevent的license |
| -I | mem 指定在memcached实例中存储对象所允许的最大大小。大小支持单位后缀（k:kb,m:mb）,如设置最大大小为23MB则为：memcached -I 23m。该参数最大指定值为128MB，默认为1MB。(1.4.2版本中新加的特性) |
| -b | 设置设置积压队列限制。积压队列配置memcached可以等待处理的网络连接数。默认为1024。 |
| -P | pidfile 将memcached进程ID保存到指定文件。 |
| -f | 设置块大小增长因子。分配新内存块时，通过将默认块(slab)大小乘以此因子来确定新块的分配大小。使用-vv可用于测试此参数 |
| -n | 用于存储key+value+flags信息的最小空间大小，默认为48byte |
| -L | 在支持大内存页的系统上，可以使用大内存页。使用大内存页使memcached能够将项缓存分配到一个大块中，这可以通过减少访问内存时的数量缺失来提高性能。 |
| -C | 禁用CAS（比较和交换）操作。 |
| -D char | 设置默认字符，用作键前缀和ID之间的分隔符。这用于每个前缀的统计信息报告。默认值为冒号（:)。如果使用此选项，则会自动打开统计信息收集。如果未使用，您可以通过将stats detail on命令发送到服务器来启用统计信息收集。 |
| -R num | 设置每个事件进程的最大请求数。默认值为20。 |
| -B protocol | 设置绑定协议，即客户端连接的默认memcached协议支持。可供选择的是ascii，binary或auto。自动（auto）是默认值。 |

> 若memcached端口使用的端口不是1024以下的端口，则尽量避免以root权限启动memcached。
