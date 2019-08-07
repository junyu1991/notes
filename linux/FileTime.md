# Linux下修改文件时间

Linux下的文件时间包括：
	access time 文件最近打开时间(有待考证，目前测试发现通过cat，vim,less等命令打开文件并不能修改文件的access time)
	modifiy time文件最近定义时间，即文件内容修改时间
	change time文件最近修改时间，即文件属性(文件权限，文件位置等)和文件内容修改时间

1. 可通过stat命令(stat filename)查看文件时间属性，如:
``` sh
  File: "test.log"
  Size: 303             Blocks: 8          IO Block: 4096   普通文件
  Device: 803h/2051d      Inode: 25698258    Links: 1
  Access: (0664/-rw-rw-r--)  Uid: (  517/cdm6_dev)   Gid: (  519/cdm6_dev)
  Access: 2019-08-07 14:18:47.191624576 +0800
  Modify: 2019-08-07 14:27:23.933623859 +0800
  Change: 2019-08-07 14:27:23.933623859 +0800
```

2. 使用ls命令查看文件显示的时间是文件的modify time

3. 修改文件时间，使用touch可修改文件时间

 3.1 修改access time：使用-a 参数即可修改文件的access time为当前系统时间 
``` sh
touch -a filename
```

 3.2 修改modify time：使用-m 参数即可修改文件的modify time为当前系统时间	 
``` sh
touch -m filename
```

 3.3 修改文件的access time以及modify time为指定时间：使用-t或者-d参数均可同时修改文件的access以及modify time为指定时间	 
``` sh
touch -t 201908071455.22 filename
touch -d '2019-08-07 14:27:23.933623859 +0800' filename 
#使用-d参数时，后面的参数需使用引号包含，否则结果会不正确
```

> -t 参数值格式为[[CC]YY]MMDDhhmm[.ss]
> 使用-d参数时，后面的参数需使用引号包含，否则结果会不正确

 3.4 修改文件change time：使用-c 参数可修改文件的change time为当前系统时间，也会同时修改access以及modify time	  
``` sh
touch -c filename
```

 3.5 修改文件change time为指定时间
	 目前并没有直接修改文件的change time的工具，通过翻查资料发现，可通过修改系统时间的方式来修改文件的change time。但需要root权限<br>
	 具体操作为：
``` sh
#备份当前时间值
now=`date`
#设置当前系统时间为想要设定的时间值，需要root权限
date --set "2019-05-08 12:20:12"
#修改文件的时间属性
touch -c filename
#将系统时间还原，需要root权限
date --set "${now}"
#删除时间值
unset now
 
#以下为可选步骤
#删除时间修改日志记录，需要root权限
echo > /var/log/lastlog
#删除登录记录，如果不是ssh登录可不用此步骤，需要root权限
echo > /var/log/wtmp
echo > /var/log/btmp
#清空当前登录session的操作记录,若不是ssh登录或者tty登录可不用此步骤
history -r
```

## 总结

以上可得出结论，修改文件的access以及modify time为指定时间较为简单，但是修改change time为指定时间比较复杂，上文中的方案需要root权限，较为鸡肋，因此在安全排查检查异常文件时，仅仅使用ls命令会漏过异常文件，可使用stat命令查看文件的完整时间属性，也可使用find命令批量查找出change time异常的文件，如:
``` sh
#使用-cmin参数
find /path -cmin +30
#也可使用-ctime参数
find /path -ctime +2
```
> find命令使用可参考：[find命令使用](https://github.com/junyu1991/notes/blob/master/linux/command.md)