# JVM & GC

## 一 JVM结构

#### 1.1 数据类型

JVM可对两种类型的数据进行操作：原始类型以及引用类型。

1. 原始类型
原始类型数据主要包括数字型(numeric)，布尔型(boolean)以及返回地址型(returnAddress)。数字型包括整数型(integral)以及浮点型(floating-point)。
整数型包括：
- byte 其值为8位带符号的二进制补码整数，默认为0
- short 其值为16位带符号的二进制补码整数，默认为0
- int 其值为32位带符号的二进制补码整数，默认为0
- long 其值为64位带符号的二进制补码整数，默认为0
- char 其值是16位无符号整数，表示基本多语言平面中的Unicode代码点，并以UTF-16编码，默认值为空('\u0000')
浮点型包括：
- float 其值是float值集的元素，或者在受支持的情况下是float-extended-exponent值集的元素，其默认值为正零
- double 其值是double值集的元素，或者在支持的情况下是double-extended-exponent值集的元素，并且其默认值为正零
布尔类型的值对真值true和false进行编码，默认值为false。
returnAddress类型的值是指向JVM指令的操作码的指针。在原始类型中只有returnAddress不和Java编程语言类型直接关联。

2. 引用类型
JVM显示的支持对象。对象是动态分配的类实例或数组。对对象的引用被认为具有Java虚拟机类型引用。引用的值可被认为是指向对象的指针。一个对象可能有多个引用。对象始终通过类型引用的值进行操作，传递和测试。
总共有三种引用类型：类类型，数组类型以及接口类型。它们的值是动态创建的类实例，数组或实现接口的类实例或数组的引用。

#### 1.2 运行时数据区
JVM定义了多种运行时数据区(run-time data areas)。某些数据区是在JVM启动时创建且只能在JVM退出时销毁的。某些数据区是每个线程独有的(per-thread)，per-thread数据区是在创建线程时创建并在线程退出时销毁。

1. 程序计数器
JVM支持同时执行多个线程。每个JVM线程都有自己的程序计数器。在任意时刻，JVM线程都只会执行单个方法的代码，即线程的当前执行方法。**如果这个方法不是native方法，则程序计数器包含当前正在执行的Java虚拟机指令的地址。**
**如果当前执行方法是native方法，程序计数器值为未定义。**

2. Java虚拟机栈

每个JVM线程都有一个私有的虚拟机栈(Java Virtual Machine stack)，该栈会在线程创建的同时被创建。JVM栈用于存储帧。Java虚拟机栈类似于常规语言（例如C）中的栈：用于存储局部变量以及部分结果，并在方法的调用以及返回中起作用。除pop和push外JVM不会直接操作JVM stack，
所以帧可能是堆分配的。JVM栈占用的内存不需要是连续的。
> Linux进程中的栈(stack)是一个动态增长和收缩的段，由栈帧(stack frames)组成。系统会为每个当前调用的函数分配一个栈帧。栈帧中存储了函数的局部变量(所谓自动变量)，实参和返回值。在程序块开始时自动分配内存，结束时自动释放内存，其操作方式类似于程序结构中的栈。[参考](https://github.com/junyu1991/notes/blob/master/linux/progress-memory.md)

Java虚拟机栈可具有固定大小，或根据计算要求动态扩展和收缩。如果Java虚拟机栈大小是固定的，那么其大小可在创建每个Java虚拟机栈时独立选择。

Java虚拟机栈可能出现的异常：
- 如果通过计算发现创建一个线程需要的栈大小超过了JVM规定的大小，则JVM会抛出 StackOverflowError
- 如果JVM栈能动态扩张，当创建线程需要扩张栈大小而实际物理内存大小不足导致无法满足扩张时，则会抛出OutOfMemoryError。

3. 堆

Java虚拟机中有一块堆空间，JVM中的所有线程都可共享该空间。堆是运行时数据区，所有的类实例以及数组均存储在该区域。

堆是在虚拟机启动时创建的。JVM的GC（垃圾收集器）管理的就主要是该区域，在Java中，对象不会显式释放。JVM可选择不同的垃圾回收算法。堆的大小可以是固定的，也可根据计算进行扩张或收缩。堆的物理内存空间可以不是连续的。

> 关于JVM的GC，会在后面的章节中讲解。

堆可能出现的异常是：
- 如果计算需要的堆空间大于垃圾回收算法可提供的堆空间，则Java虚拟机会抛出OutOfMemoryError。

4. 方法区(Method Area)

JVM中的方法区是被JVM中的所有线程共享的。该区域与进程内存结构中的"Text"段类似。存储了每个类的类结构如运行时常量池，字段，方法数据以及方法代码和构造函数代码，包括用于类和接口初始化以及实例初始化的特殊方法。

> 文本段(Text)/程序段：包含了进程运行的程序机器语言指令。文本段具有只读属性，以防止进程通过错误指针意外修改自身指令。因为多个进程可同时运行同一程序，所以又将文本段设为可共享，这样，一份代码的拷贝可以映射到所有这些进程的虚拟地址空间中。

方法区是在JVM启动时被创建的，在逻辑上属于堆空间，但是可不被垃圾回收器管理。与堆空间类似，方法区大小可固定也可根据实际需求动态扩张或收缩，且方法区的物理内存不需要是连续的。
方法区可能出现的异常：
- 如果方法区域中的内存无法满足分配请求，JVM会抛出OutOfMemoryError。

5. 运行时常量池(Run-Time Constant Pool)


6. Native方法栈

Java虚拟机的实现可以使用常规栈，俗称“C栈”，以支持本机方法(不是使用Java语言实现的方法)。Native方法也可以用来实现JVM指令的解释器，如C语言。如果JVM的实现不能加载Native方法，那么其本身不依赖常规堆栈的容器也就不需要提供Native方法栈。如果提供了Native方法栈，Native方法栈通常会在每个线程创建时分配给被创建的线程。
Native方法栈的大小可以是固定的，也可以可根据需求动态扩展和收缩。如果Native方法栈的大小是固定的，则其大小可以在创建Native栈是独立选择。
Native栈可能出现的异常：
- 通过计算，发现一个线程需要的Native线程栈的大小超过了允许值，JVM会抛出StackOverflowError
- 如果Native栈的大小是可动态调整的，当动态扩张时，如果需要扩张的大小超过了可提供的空间大小，或没有足够的内存可用于为新线程创建初始本机方法堆栈，JVM会抛出OutOfMemoryError。

#### 1.3 栈帧(Frame)

参考链接：
1. [JVM总览](https://docs.oracle.com/javase/specs/jvms/se13/html/jvms-2.html)
2. [Java Garbage Collection Basics](https://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html)
3. [Java Platform, Standard Edition HotSpot Virtual Machine Garbage Collection Tuning Guide](https://docs.oracle.com/javase/9/gctuning/introduction-garbage-collection-tuning.htm#JSGCT-GUID-326EB4CF-8C8C-4267-8355-21AB04F0D304) 