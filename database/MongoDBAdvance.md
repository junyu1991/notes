# MongoDB进阶学习

MongoDB文档地址[Documentation](https://docs.mongodb.com/manual/crud/)

## MongoDB批量操作

1. 批量操作

MongoDB支持批量执行写操作(**bulkWrite()**)，支持的写操作包括：insertOne, updateOne, updateMany, replaceOne, deleteOne, deleteMany。<br>

MongoDB的批量写操作氛围*有序*和*无序*。
有序写操作，MongoDB会严格按照顺序执行写操作，当其中一个写操作出现异常，MongoDB会立即返回而不会继续执行剩下的操作。
无序写操作，MongoDB会并行的执行写操作，但并不保证一定会并行执行。当其中一个写操作出现错误时并不会影响其他的写操作。

2. 向分片集合中执行批量插入

大批量插入操作（包括初始数据插入或例行数据导入）可能会影响分片群集性能。

对于批量插入，有以下几种策略：
2.1 预分片，如果分片集合是空的，则集合只有一个初始块，它位于单个分片上。MongoDB会时间接收数据，创建拆分并将拆分快分发到可用的分片。为避免这种
性能开销，可以预先拆分集合再执行插入操作。预分片参考[https://docs.mongodb.com/manual/tutorial/split-chunks-in-sharded-cluster/](https://docs.mongodb.com/manual/tutorial/split-chunks-in-sharded-cluster/)
2.2 使用无序批量操作，为提高往分片集群执行批量写操作的性能，可使用无序批量写操作，执行无序批量写操作时mongos可以尝试同时将写入发送到多个分片。
对于空集合则先使用预先拆分集合的操作。
2.3 如果分片键在插入期间单调增加，则所有插入的数据将转到集合中的最后一个块，这将总是在一个分片上结束。因此，群集的插入容量永远不会超过该单个分片的插入容量。 
如果插入量大于单个分片可以处理的量，并且如果无法避免单调增加分片键，可考虑对应用程序进行以下修改：
- 反转分片键的二进制位。这样可以保留信息并避免将插入顺序与不断增加的值序列相关联。
- 交换第一个和最后一个16位字以“洗牌”插入。

3. bulkWrite()使用
``` javascript
db.collection.bulkWrite(
   [ <operation 1>, <operation 2>, ... ],
   {
      writeConcern : <document>,
      ordered : <boolean>
   }
)
```
详情:[bulkWrite()](https://docs.mongodb.com/manual/reference/method/db.collection.bulkWrite/#db.collection.bulkWrite)