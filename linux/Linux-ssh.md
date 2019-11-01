# Linux ssh命令

## ssh高平率使用参数

- -p 指定远程server端口
- -l 指定登录用户名
- -o 指定ssh选项

## 使用示例

1. 使用某台Linux服务器的SSH作为跳板登录其内网服务器
``` shell
ssh user@192.168.1.102 -o ProxyCommand='ssh out@172.1.25.36 -p 22 -W %h:%p'
```
使用-o指定代理命令ProxyCommand,ProxyCommand的值即为跳转机的ssh登录命令。

> sftp以及scp命令相同的用法。