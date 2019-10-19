# MongoDB基础

## 1. 简介
  MongoDB是一个基于分布式文件存储的数据库，是一个介于关系数据库和非关系数据库之间的产品，是非关系数据库当中功能最
丰富的，最像关系数据的。

> NoSQL(Not Only SQL)，指的是非关系型数据库，是对不同于关系型数据库的数据库管理系统的统称。
> NoSQL用于超大规模数据的存储。(如谷歌或者Facebook每天为用户收集亿万比特的数据)。这些类型的数据存储不需要固定的模式，无需多余操作就可以横向扩展。

## 2. MongoDB概念解析

在MongoDB中基本的概念就是文档，集合，数据库。

| SQL术语/概念 | MongoDB术语/概念 | 解释/说明 |
| :--- | :--- | :--- |
| database | database | 数据库 |
| table | collection | 数据库表/MongoDB中也可叫做集合 |
| row | document | 数据记录行/MongoDB称之为文档 |
| column | field | 数据字段/域 |
| index | index | 索引 |
| table joins | | 表连接，MongoDB不支持 |
| primary key | primary key | 主键，MongoDB自动将_id字段设置为主键 | 

#### **2.1数据库**

一个MongoDB中可建立多个数据库。MongoDB的默认数据库为"db"，该数据库存储在data目录中。

MongoDB的单个实例可以容纳多个独立的数据库，每一个都有自己的集合和权限，不同的数据库也放置在不同的文件中。

使用MongoDB自带的mongo工具连接MongoDB Server时，可用"**show dbs**"查看所有数据库列表。
使用"**db**"命令显示当前数据库对象或集合。使用"**use database**"可连接到指定数据库。(与MySQL类似)

数据库名可以是满足以下条件的任意UTF-8字符串：
- 不能是空字符串
- 不得含有**''(空格)**，**.**，**$**， **/**，**\\** 和 **\0(空字符)**
- 应全部小写
- 最多64字节
数据库名保留字符如下：
- **admin**: 从权限角度来看，这是"root"数据库。如果将一个用户添加到这个数据库，这个用户自动集成所有的数据库权限。一些
特定的服务器端命令只能从这个数据库运行。
- **local**: 这个数据库永远不会被复制，可以用来存储限于本地单台服务器的任意集合。
- **config**: 当MongoDB用于分片设置时，config数据库在内部使用，用于保存分片的相关信息。

#### **2.2文档(Document)**

文档是一组键值(key-value)对(即 BSON)。MongoDB 的文档不需要设置相同的字段，并且相同的字段不需要相同的数据类型，这与关系型数据库有很大的区别，也是 MongoDB 非常突出的特点。

文档键命名规范：
- 键不能含有**\0(空字符)**。这个字符是用来表示键的结尾。
- **.**和**$**有特别的意义，只有在特定环境下才能使用。
- 以下划线**"_"**开头的键是保留的(不是严格要求的)。

#### **2.3集合(Collection)**

集合是MongoDB的文档组，类似于RDBMS(关系数据库管理系统:Relational Database Management System)中的表格。
集合存在于数据库中，集合没有固定的结构。所以可以向集合中插入不同格式和类型的数据，但为了更好的管理，通常情况下插入同一集合的数据都会有一定的关联性。
当第一个文档创建插入时，集合就会被创建，这与数据库的创建是相同的。

集合名的命名规则：
- 集合名不能是空字符串**""**。
- 集合名不能含有**\0**字符（空字符），这个字符表示集合名的结尾。
- 集合名不能以"**system.**"开头，这是为系统集合保留的前缀。
- 用户创建的集合名字不能含有保留字符。有些驱动程序的确支持在集合名里面包含，这是因为某些系统生成的集合中包含该字符。除非你要访问这种系统创建的集合，否则千万不要在名字里出现$。　

#### **2.4capped collections**

Capped collections就是固定大小的collection，有很高的性能以及队列过期的特性（过期按照插入的顺序）。<br>
Capped collections 是高性能自动的维护对象的插入顺序。它非常适合类似记录日志的功能和标准的 collection 不同，你必须要显式的创建一个capped collection，指定一个 collection 的大小，单位是字节。collection 的数据存储空间值提前分配的。<br>
Capped collections 可以按照文档的插入顺序保存到集合中，而且这些文档在磁盘上存放位置也是按照插入顺序来保存的，所以当我们更新Capped collections 中文档的时候，更新后的文档不可以超过之前文档的大小，这样话就可以确保所有文档在磁盘上的位置一直保持不变。<br>
由于 Capped collection 是按照文档的插入顺序而不是使用索引确定插入位置，这样的话可以提高增添数据的效率。MongoDB 的操作日志文件 oplog.rs 就是利用 Capped Collection 来实现的。<br>
要注意的是指定的存储大小包含了数据库的头信息。
```shell script
db.createCollection("collname", {capped:true, size:100000})
```
- 在 capped collection 中，你能添加新的对象。
- 能进行更新，然而，对象不会增加存储空间。如果增加，更新就会失败 。
- 使用 Capped Collection 不能删除一个文档，可以使用 drop() 方法删除 collection 所有的行。
- 删除之后，你必须显式的重新创建这个 collection。
- 在32bit机器中，capped collection 最大存储为 1e9( 1X10^9)个字节。

## 3.MongoDB操作

1. 创建数据库，MongoDB并未提供显示的创建数据库方法，当第一条数据插入数据库中的时候，就会创建数据库

2. 删除数据库，使用```db.dropDatabase()```删除数据库，具体步骤为:
```shell script
use deletedatabase
db.dropDatabase()
```

3. 创建集合
```shell script
db.createCollection(name, options)
```
参数说明：
- name:创建的集合名
- options:可选参数，指定有关内存大小及索引的选项
options参数选项为:

| 字段 | 类型 | 描述 |
| :--- | :--- | :--- |
| capped | boolean | （可选）如果为true，则创建固定集合。固定集合是指有着固定大小的集合，当达到最大值时，它会自动覆盖最早的文档。<br>当该值为 true 时，必须指定 size 参数。 |
| autoIndexId | boolean | （可选）如为 true，自动在 _id 字段创建索引。默认为 false。 |
| size | 数值 | （可选）为固定集合指定一个最大值，以千字节计（KB）。<br>如果 capped 为 true，也需要指定该字段。 |
| max | 数值 | （可选）指定固定集合中包含文档的最大数量。 |

可使用**show collections**或者**show tables**查看已有集合。

4. 删除集合，使用```db.collection.drop()```删除集合，具体步骤为：
```shell script
use deletedatabase
db.createCollection('deletecollection') #创建删除集合
db.deletecollection.drop()
```

5. 插入文档
MongoDB支持单条插入，也支持多条插入
```shell script
db.collection.insertOne(document) #插入单条
db.collection.insertMany(documents) #插入多条
```

6. 更新文档
MongoDB支持三种更新文档的方法。
```shell script
db.collection.updateOne(<fileter>, <update>, <options>)
db.collection.updateMany(<fileter>, <update>, <options>)
db.collection.replaceOne(<fileter>, <update>, <options>)
```

7. 删除文档
```shell script
db.collection.deleteMany()
db.collection.deleteOne()
#示例
db.collection.deleteMany({}) #删除所有文档
db.collection.deleteMany({status:"D"}) #按照条件筛选删除所有状态为D的文档
db.collection.deleteOne({status:"D"}) #按照条件删除状态为D的一个文档
```
删除操作不会删除索引，即使将所有的文档都删除。<br>
单个文档的删除操作是原子操作。MongoDB的所有写操作均是单个文档级别的原子操作。

8. 文档查询
```shell script
db.collection.find()
db.collection.findOne()
#示例
db.collection.find({}) #查询所有文档
db.collection.find({status:"D"}) #按照条件查询文档集合
db.collection.findOne({status:"D"}) #按照条件查询并获取一个结果
```
MongoDB支持条件查询，支持的条件查询如下：
- {\<filed\>:\<value\>} 指定相等条件。
- {\<filed1\>: { \<operator1\>: \<value1\>}, ... } 指定查询条件，如：{status: {$in: ["A","D"]}}，使用了in操作符。
> 当对同一字段进行条件筛选时，推荐使用$in操作符而不是$or操作
- {\<filed1\>:\<value1\>, \<filed2\>:\<value2\>}指定AND，当两个条件并列时就可看做使用了AND操作，如: db.test.find({status:"a", qty: {$lt:30}})条件就为：status="a" and qty \< 30
- 使用$or表达OR操作符，使用示例：db.test.find({$or: [{status:"a"}, {qty: {$lt: 30}}]})解释为：status="a" or qty \< 30
- AND和OR可同时使用，使用示例：db.test.find({status: "A", $or: [{qty: {$lt: 30}}, { item: /^p/}]})解释为：status="a" and (qty<30 or item like "%p")
- MongoDB支持的其他表达式：$gt(>), $lt(<), $gte(>=), $lte(<=)
- MongoDB支持正则表达式，使用方式如下：
``` shell
{<filed>: {$regex:/pattern/, $option: '<options>'}}
{<filed>: {$regex:'pattern', $option: '<options>'}}
{<filed>: {$regex:/pattern/options}}
```
支持的options包括：

| 选项参数 | 作用 | 限制 |
| :--- | :---| :--- |
| i | 匹配大小写 |  |
| m | 对于包含锚点的模式（即^表示开头，$表示结尾），在每行的开头或结尾匹配具有多行值的字符串。如果没有此选项，这些锚点将在字符串的开头或结尾处匹配。<br>如果模式不包含锚点或者字符串值没有换行符（例如\ n），则m选项无效。 | | 
| x | 忽略$regex模式中的所有非转义或未包含在字符类中的空格。 | 需要带有$options语法的$regex |
| s | 允许点字符（即**.**）匹配包括换行符在内的所有字符。 | 需要带有$options语法的$regex |

正则表达式的限制：
1. 不能在$in表达式中使用$regex表达式，要在$in查询表达式中包含正则表达式，您只能使用JavaScript正则表达式对象。如：
``` shell
{ name: { $in: [ /^acme/i, /^ack/ ] } }
```
> 参考链接:[$regex](https://docs.mongodb.com/manual/reference/operator/query/regex/)
