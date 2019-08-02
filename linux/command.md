# Linux命令

### find

1. 根据文件大小查找文件
	``` sh
	find /path/ -size [+/-]n[b/c/w/k/M/G]
	# +/-分别代表文件大小大于/小于n个单位，如果不指定则相当于等于
	# 单位:c bytes, b 512-byte blocks, w 2-bytes, k kb, M MB, G GB
	```

2. 根据文件时间查找文件
	``` sh
	find /path/ -[atime/amin/ctime/cmin/mtime/mmin] [+/-]n 
	#命令解析：时间参数首字母可分为：a access, c changed, m modified，后半部分分为：time 和 min
	#这两个值决定后面的时间单位：time n*24小时, min n分钟
	# +/- 分别代表时间大于/小于,不指定则为等于
	如: find ./ -mtime +1 为查找当前目录下modified时间是在1*24小时之前的文件
	```
	> 时间条件可叠加使用，如查找文件modified时间在过去5-2天之内的文件命令为：
	  find ./ -mtime +2 -mtime -5

3. 根据文件名查找文件
	``` sh
	find /path/ -name 'name-pattern'
	```
	name-pattern可使用正则表达式

4. 查找到文件进行后续操作命令可使用-exec 和 xargs，示例分别如下：<br>
	-exec
	``` sh
	find ./ -type f -name "*.log" -exec mv {} {}.bak \;
	```
	xargs
	``` sh
	find ./ -type f -name '*.log' | xargs grep .*
	```