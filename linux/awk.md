# awk使用

awk是一种处理文本文件的语言，是一个文件分析工具。

## 语法

``` shell
awk [选项参数] 'script' var=value file(s)
或
awk [选项参数] -f scriptfile var=value file(s)
```

部分选项参数说明：
- -F fs or --field-separator fs，指定输入文件折分隔符，fs是一个字符串或者是一个正则表达式，如-F:。
- -v var=value or --asign var=value，赋值一个用户定义变量。
- -f scripfile or --file scriptfile，从脚本文件中读取awk命令。

## awk内建变量

| 变量 | 描述 |
| :--- | :--- |
| $n | 当前记录的第n个字段，字段间由FS分隔 |
| $0 |	完整的输入记录 |
| ARGC |	命令行参数的数目 |
| ARGIND |	命令行中当前文件的位置(从0开始算) |
| ARGV |	包含命令行参数的数组 |
| CONVFMT |	数字转换格式(默认值为%.6g)ENVIRON环境变量关联数组 |
| ERRNO |	最后一个系统错误的描述 |
| FIELDWIDTHS |	字段宽度列表(用空格键分隔) |
| FILENAME |	当前文件名 |
| FNR |	各文件分别计数的行号 |
| FS |	字段分隔符(默认是任何空格) |
| IGNORECASE |	如果为真，则进行忽略大小写的匹配 |
| NF |	一条记录的字段的数目 |
| NR |	已经读出的记录数，就是行号，从1开始 |
| OFMT |	数字的输出格式(默认值是%.6g) |
| OFS |	输出记录分隔符（输出换行符），输出时用指定的符号代替换行符 |
| ORS |	输出记录分隔符(默认值是一个换行符) |
| RLENGTH |	由match函数所匹配的字符串的长度 |
| RS |	记录分隔符(默认是一个换行符) |
| RSTART |	由match函数所匹配的字符串的第一个位置 |
| SUBSEP |	数组下标分隔符(默认值是/034) |

参考链接：[Awk 内建变量](https://www.runoob.com/w3cnote/8-awesome-awk-built-in-variables.html)