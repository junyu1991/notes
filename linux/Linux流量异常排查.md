# Linux流量异常排查

1. 使用sar命令查看流量历史，可排查出哪张网卡流量异常
``` shell
sar -n DEV #查看当天从零点到当前时间的网卡流量信息
sar -n DEV 1 5 #每秒显示一次，共显示5次
sar -n DEV -f /var/log/sa/saxx #查看XX日的网卡流量历史
```
IFACE 表示设备名称
rxpck/s 每秒接收的包的数量
txpck/s 每秒发出的包的数量
rxKB/s 每秒接收的数据量，单位KByte 1KB=1000byte=8000bit
txKB/s 每秒发出的数据量，单位KByte
若服务器丢包非常严重，需要查看网卡流量是否异常。接收数据部分 rxpck大于4000，或者rxKB大于5000，则有可能被攻击了，正常服务器网卡流量没有这么大。除非自己在拷贝数据。
计算实际速度，取 rxkb或txkb的峰值，换算成KB，比如是686KByte，然后用686*8/1000=5.4MBit
Bytes 字节,缩写为B 【电脑硬盘的最小单位】
bit 位, 1Byte=8bit 【网络中最小的单位】

bps =bit per second 每秒位数
pps =package per second 每秒数据包 Mb ,Gb,10Gb
10Gb=10000Mb 【电脑中1GB=1024MB，网络中1Gb=1000Mb】
宽带10Mb，下载速度是1.25MB，10Mb=10Mbit 10Mbit/8=1.25Mbyte=1.25MB


参考链接：[Linux基础——sar 查看网卡流量](https://blog.csdn.net/cityzenoldwang/article/details/65442405)

2. 使用工具iftop工具实时查看网络流量情况

- 下载iftop：[Download](http://www.ex-parrot.com/~pdw/iftop/)
- 解压并安装：
``` shell
tar -xvf iftop-version.tar.gz
cd iftop-version
./configure --prefix=/path/to/install/iftop-version
make
make install
```
- 使用iftop查看流量异常的进程
``` shell
iftop -P
```

3. 使用lsof或者通过/proc/pid/的方式查看该进程相关信息。