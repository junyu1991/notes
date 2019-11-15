# Java垃圾回收

## 1 JVM

JVM结构如下：
![](./img/hotspot_jvm_architecture.PNG)

与JVM性能的有关的组件就是下图中高亮的部分。
![关键组件](./img/key_component.PNG)

当JVM调节性能时，JVM主要关注三个组件：heap(堆)，JIT Compiler，Garbage Collector。
- heap(堆)主要用于存储对象数据，这片区域被JVM启动时选择的Garbage collector(垃圾回收)管理。大多数JVM参数选项选项都与堆大小有关，尽量选择最合适的垃圾回收算法。
- JIT Compiler(JIT编译器)对于JVM的性能影响很大，但新版本的JVM基本很少需要调整。

## 2 Java垃圾回收机制

Java的自动垃圾回收（GC）机制主要用于管理JVM中的堆(heap)区域内存，鉴定哪些对象是正在使用的，哪些不是，然后删除未使用的对象，压缩堆内存空间以供继续使用。对于如何鉴别对象是够可被回收，主要辨别依据是是否还存在指向该对象的引用。

垃圾回收的步骤主要包括以下几步：
1. 标记：扫描堆中的所有对象，标记出能够删除的对象。
![mark](./img/GC_mark.PNG)

2. 删除：正常的删除第一步中标记出的可删除的对象
![delete](./img/GC_delete.PNG)

2. 删除并压缩：这与直接删除操作不同的是在进行删除操作后，就对堆空间进行压缩操作，将可用对象移到一起，减少内存碎片。
![delete_compacting](./img/GC_delete_compacting.PNG)

#### 2.1 JVM世代划分

为提高垃圾回收的效率，JVM中的对被划分为几个世代：年轻代(Young Generation)，老年代(Old Generation)，永久代(Permanent Generation)。
![generation](./img/JVM_Generations.PNG)

- 年轻代中主要是新的对象以及等待老化(被移动到老年代)的对象。当年轻代被填满时，就会触发一次小垃圾回收(minor garbage collection)，minor collection是基于年轻代中的对象都是高死亡率的。年轻代中的对象大多数都是生命周期很短的对象，其中一部分未被回收的对象会被移动到老年代中。所有的minor garbage collection都是**“停止世界”**事件，当执行minor collection时，所有的应用线程都会被暂停直到回收操作完成。
- 老年代中主要是生命周期较长的对象。通常情况下，对于年轻代中的对象都会设置一个阈值，当年轻代中的对象生存周期达到了该阈值，则会将该对象移动到老年代中。即使是老年代，也需要进行垃圾回收，该操作被称作“大型垃圾回收”（major garbage collection）。major garbage collection同样也是“停止世界”事件，但是该操作执行频率较低，因为老年代中大部分都是生命周期较长的对象。因此对于追求应用响应速度的应用，应该要尽量减少major garbage collection。major garbage collection停止世界的时间受垃圾回收算法的影响。
- 永久代中主要是应用中JVM需要的类以及方法的元数据。永久代中的数据主要是JVM在运行期间根据应用程序需要使用的类，另外，Java SE的类库和方法也存储在永久代中。当JVM发现永久代中的类不会再被使用或者需要新的空间用于存储新的类时也会被集中起来处理掉。永久代的垃圾回收通常是在“全面垃圾回收”（full garbage collection）的操作中。

#### 2.2 对象分配以及老化过程

1. 初始阶段，此时新对象都被分配到了eden空间，两个survivor空间都是空的
![](./img/young_start.PNG)

2. 新对象不断被分配到年轻代的eden空间中，当年轻代中的eden空间被填满时就会触发minor garbage collection。
![](./img/young_eden_fillup.PNG)

3. eden中存在引用的对象会被移动到第一个survivor空间(S0)中，而不存在引用的对象就被删除了，移动到S0中的对象年龄(ege)都标记为1。
![](./img/young_collection.PNG)

4. 在下一次的minor GC中，eden空间中的对象会重复第3步骤中的操作，然而此次eden中的可引用对象是被移动到第二个survivor空间(S1)中，而且此次的GC还会针对S0中的对象做处理，S0中的无引用对象会被删除，而引用对象会被移动到S1空间，且其age加1，从eden移动到S1的对象age是被标记为1的。在执行完GC后，eden以及S0空间应该都被清空了。
![](./img/young_collection_2.PNG)

5. 接下来的GC中会重复第四步骤中的操作，但是S0和S1对调，即引用对象都被移动到S0中，且age均加1。执行完GC后，eden以及S1空间均被清空了。
![](./img/young_collection_3.PNG)

6. 循环经过前几个步骤后，当年轻代中存在对象age达到设定的阈值(此演示中为8)时，达到阈值的对象就会被提升到老年代。
![](./img/young_collection_promoted.PNG)

7. 当minor GC继续执行时，年轻代中符合条件的对象会持续被提升到老年代中。
![](./img/young_collection_promoted_continue.PNG)

8. 以上步骤基本覆盖了年轻代的GC操作。最终，major GC操作会清理并压缩老年代中的空间。
![](./img/collection_result.PNG)

参考链接：
1. [JVM总览](https://docs.oracle.com/javase/specs/jvms/se13/html/jvms-2.html)
2. [Java Garbage Collection Basics](https://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html)
3. [Java Platform, Standard Edition HotSpot Virtual Machine Garbage Collection Tuning Guide](https://docs.oracle.com/javase/9/gctuning/introduction-garbage-collection-tuning.htm#JSGCT-GUID-326EB4CF-8C8C-4267-8355-21AB04F0D304) 