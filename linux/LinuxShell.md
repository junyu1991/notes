# Linux Shell

## 变量

1. 定义变量时变量名不加美元符号($)，使用变量名时需要在变量名前加美元符号($)，如：
``` sh
#设置变量
name="test" 
#使用变量名
echo $name
echo ${name}
```

2. 其他赋值形式(语句赋值)
``` sh
for file in `ls -lhtr /etc`
for file in $(ls /etc)
```

3. 变量其他信息
``` sh
current_path=`pwd`
#只读变量
readonly current_path
#删除变量
unset current_path
```

## 字符串
shell字符串可用单引号，双引号或者不使用引号。

1. 单引号字符串中的变量以及转义字符是无效的，单引号中不能出现单独一个单引号（转义后也不行）,<br>
但可成对出现，作为字符串拼接使用。
``` sh
str='this is a string'
```

2. 双引号字符串中可以有变量以及转义字符
``` sh
name="test"
greeting="hello,${name}"
```

3. 字符串操作
``` sh
string="abcdef"
#获取字符串长度
echo ${#string} #输出6
#提取字符串
echo ${string:1:3} #输出 bcd
#查找字符串(此例中的shell查找字符串不会搜索整个词语，而是单独查找每个字符，哪个字符先出现就计算哪个)
echo `expr index "$string" ed` #输出 4
```

## 数组
shell中使用英语括号来表示数组，数组元素用空格符号分割。<br>

1. 数组定义格式如下:<br>

	``` sh
	arrayname=(value1 value2 value3 ... valuen) 
	```
	
	也可以单独定义数组各个分量（可以不使用连续的下标，而且下标范围没有限制），如:<br>
	
	``` sh
	array_name[0]=value0
	array_name[1]=value1
	array_name[3]=value3
	array_name[12]=value12
	```

2. 读取数组格式如下：<br>
	
	``` sh
	${array_name[index]}
	```
	
	使用@符号可以获取数组中的所有元素，如：
	
	``` sh
	echo ${array_name[@]}
	```

3.获取数组长度
	
	``` sh
	#获取数组元素个数
	length=${#array_name[@]}
	#或者
	length=${#array_name[*]}
	#获取数组单个元素的长度
	lengthn=${#array_name[n]}
	```
	

## shell传递参数


我们可在执行shell脚本时向shell脚本传递参数，脚本内获取参数格式为：$n 。n代表一个数字，1为执行脚本<br>
的第一个参数，2为第二个参数，以此类推，0代表执行文件名。例：<br>

``` shell
#!/bin/bash
echo "执行文件名：$0"
echo "第一个参数为：$1"
echo "第二个参数为：$2"
echo "第三个参数为：$3"
```

特殊字符：

| 参数处理 | 说明 |
| :--: | :--- |
| $# | 传递到脚本的参数个数 |
| $* | 以一个单字符串显示所有向脚本传递的参数，<br>如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 |
| $$ | 脚本运行的当前进程ID号 |
| $! | 后台运行的最后一个进程的ID号 |
| $@ | 与$*相同，但是使用时加引号，并在引号中返回每个参数。<br>如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。  |
| $- | 显示shell使用的当前选项，与set命令功能相同 |
| $? | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

## shell运算符

	1. 算术运算符和Java，Python相同
	
| 运算符 | 说明 | 举例 |
| :--- | :--- | :--- |
| + | 加法 | `expr $a + $b` 结果为 30。 |
| - | 减法 | `expr $a - $b` 结果为 -10。 |
| * | 乘法 | `expr $a \* $b` 结果为  200。 |
| / | 除法 | `expr $b / $a` 结果为 2。 |
| % | 取余 | `expr $b % $a` 结果为 0。 |
| = | 赋值 | a=$b 将把变量 b 的值赋给 a。 |
| == |	相等。用于比较两个数字，相同则返回 true。 |  [ $a == $b ] 返回 false。 |
| != |	不相等。用于比较两个数字，不相同则返回 true。 |  [ $a != $b ] 返回 true。 |
	
	> 条件表达式要放在方括号之间，并且要有空格，例如: [$a==$b] 是错误的，必须写成 [ $a == $b ]。
	
	2. 关系运算符
	关系运算符只支持数字，不支持字符串，除非字符串的值是数字。<br>
	下表列出了常用的关系运算符，假定变量 a 为 10，变量 b 为 20：
	
| 运算符 | 说明 | 举例 |
| :--- | :--- | :--- |
| -eq |	检测两个数是否相等，相等返回 true。 | [ $a -eq $b ] 返回 false。|
| -ne |	检测两个数是否不相等，不相等返回 true。 | [ $a -ne $b ] 返回 true。 |
| -gt |	检测左边的数是否大于右边的，如果是，则返回 true。 | [ $a -gt $b ] 返回 false。 |
| -lt |	检测左边的数是否小于右边的，如果是，则返回 true。 |	[ $a -lt $b ] 返回 true。 |
| -ge |	检测左边的数是否大于等于右边的，如果是，则返回 true。 |	[ $a -ge $b ] 返回 false。 |
| -le |	检测左边的数是否小于等于右边的，如果是，则返回 true。 |	[ $a -le $b ] 返回 true。 |
	
	3. 布尔运算符
	下表列出了常用的布尔运算符，假定变量 a 为 10，变量 b 为 20：<br>
	
| 运算符 | 说明 | 举例 |
| :--- | :--- | :--- |
| ! | 非运算，表达式为 true 则返回 false，否则返回 true。 |	[ ! false ] 返回 true。 |
| -o | 或运算，有一个表达式为 true 则返回 true。 |	[ $a -lt 20 -o $b -gt 100 ] 返回 true。 |
| -a | 与运算，两个表达式都为 true 才返回 true。 |	[ $a -lt 20 -a $b -gt 100 ] 返回 false。 |
	
	4. 逻辑运算符
	以下介绍 Shell 的逻辑运算符，假定变量 a 为 10，变量 b 为 20:<br>
	
| 运算符 | 说明 | 举例 |
| :--- | :--- | :--- |
| && | 逻辑的 AND |	[[ $a -lt 100 && $b -gt 100 ]] 返回 false |
| || |	逻辑的 OR |	[[ $a -lt 100 || $b -gt 100 ]] 返回 true |
	
	5. 字符串运算符
	下表列出了常用的字符串运算符，假定变量 a 为 "abc"，变量 b 为 "efg"：
	
| 运算符 | 说明 | 举例 |
| :--- | :--- | :--- |
| = | 检测两个字符串是否相等，相等返回 true。 | [ $a = $b ] 返回 false。 |
| != | 检测两个字符串是否相等，不相等返回 true。 |	[ $a != $b ] 返回 true。 |
| -z | 检测字符串长度是否为0，为0返回 true。 |	[ -z $a ] 返回 false。 |
| -n | 检测字符串长度是否为0，不为0返回 true。 | 	[ -n "$a" ] 返回 true。 |
| $ | 检测字符串是否为空，不为空返回 true。 |	[ $a ] 返回 true。 |
	
	6. 文件测试运算符
	文件测试运算符用于检测 Unix 文件的各种属性。<br>
	属性检测描述如下：
	
| 运算符 | 说明 | 举例 |
| :--- | :--- | :--- |
| -b file | 检测文件是否是块设备文件，如果是，则返回 true。| [ -b $file ] 返回 false。 |
| -c file |	检测文件是否是字符设备文件，如果是，则返回 true。 |	[ -c $file ] 返回 false。 |
| -d file |	检测文件是否是目录，如果是，则返回 true。 |	[ -d $file ] 返回 false。 |
| -f file |	检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。 |	[ -f $file ] 返回 true。 |
| -g file |	检测文件是否设置了 SGID 位，如果是，则返回 true。 |	[ -g $file ] 返回 false。 |
| -k file |	检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。 |	[ -k $file ] 返回 false。 |
| -p file |	检测文件是否是有名管道，如果是，则返回 true。 |	[ -p $file ] 返回 false。 |
| -u file |	检测文件是否设置了 SUID 位，如果是，则返回 true。 |	[ -u $file ] 返回 false。 |
| -r file |	检测文件是否可读，如果是，则返回 true。 | [ -r $file ] 返回 true。 |
| -w file |	检测文件是否可写，如果是，则返回 true。 | [ -w $file ] 返回 true。 |
| -x file |	检测文件是否可执行，如果是，则返回 true。 |	[ -x $file ] 返回 true。 |
| -s file |	检测文件是否为空（文件大小是否大于0），不为空返回 true。 |	[ -s $file ] 返回 true。 |
| -e file |	检测文件（包括目录）是否存在，如果是，则返回 true。| [ -e $file ] 返回 true。 |
| -S file | 检测文件是否socket |  |
| -L file | 检测文件是否存在并且是一个符号链接。 |  |

## shell流程控制

1. if else if使用方法
``` sh
if condition
then
	command1
	command2
	command3
	....
	commandn
elif condition2
then
	command4
else
	command6
fi
```

使用示例：
``` sh
#!/bin/bash
if [ $# -gt 1 ] then
	echo "第一个参数： $1"
elif [ $# -gt 2 ] then
	echo "第二个参数: $2"
else
	echo "没有参数"
fi
```

2. for loop使用方法
``` sh
for var in item1 item2 ... itemn
do
	command1
	command2
	...
	commandn
done
#或者
for var in item1 item2 ... itemn; do command1; command2... done;
```

示例：
``` sh
#!/bin/sh

for loop in 1 2 3 4 5
do
	echo "The value is: ${loop}"
done

for str in 'This is a test'
do 
	echo $str
done
```

3. while loop
``` sh
while condition
do 
	command
done
```

示例：
``` sh
#!/bin/bash
int=1
while(( $int<=5 ))
do	
	echo $int
	let "int++"
done
```

> let命令用于执行一个或多个表达式，变量计算中不需要加上$来表示变量

4. until loop
``` sh
until condition
do 
	command
done
```

示例：
``` sh
#!/bin/bash
a=0
until [ ! $a -lt 10 ]
do 
	echo $a
	a=`expr $a+1`
done
```

5. case
``` sh
case value in 
mode1)
	command
	;;
mode2)
	command2
	;;
esac
```

case工作方式如上所示。取值后面必须为单词in，每一模式必须以右括号结束。取值可以为变量或常数。<br>
匹配发现取值符合某一模式后，其间所有命令开始执行直至 ;;。
取值将检测匹配的每一个模式。一旦模式匹配，则执行完匹配模式相应命令后不再继续其他模式。<br>
如果无一匹配模式，使用星号 * 捕获该值，再执行后面的命令。 

示例：
``` sh 
#!/bin/bash
echo '输入 1 到 3之间的数字：'
echo '你输入的数字为：'
read aNum
case $aNum in 
	1) echo '你输入了 1'
	;;
	2) echo '你输入了 2'
	;;
	3) echo '你输入了 3'
	;;
	*) echo '你没有输入1到3之间的数字'
	;;
esac
```

6. 跳出循环
continue和break均可跳出循环，break是跳出所有循环，continue是跳出当前循环

7. 无限循环
``` sh
#while dead loop
while :
do 
	command
done
# or
while true
do
	command
done
# for dead loop
for(( ; ; ))
```