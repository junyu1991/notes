# MySQL使用

## 部分常用但不常见的使用方法
1. 查询表中多余的重复记录，查询重复记录主要使用group by column_name having count(column_name)>1
``` sql
-- 以单个字段来判断重复，以peopleId为例。
select * from people where peopleId in (select peopleId from people group by peopleId having count(peopleId) > 1);
-- 以多个字段来判断数据重复
select * from vita a where (a.peopleId, a.seq) in (select peopleId,seq from vita group by peopleId,seq having count(*)>1); 
```

2. 分页查询
分页查询主要是用limit以及offset两个关键字，offset用于设置偏移量（即从多少条开始计数），limit则用于设置查询条数。也可指使用limit offset_num,limit_num 的方式。
``` sql
select * from table_name limit 10 offset 10;
select * from table_name limit 10,10;
```
以上两条查询语句的意思为：从第10条数据开始计数，查询10条数据。即每页10条数据，查询第二页的10条数据。分页查询offset的计算公式为：offset = page_num * limit;
使用limit以及offset实现分页查询时，查询效率会随着offset的值增大而降低，特别是查询大数据量的数据库表时会更加明显。因此，当效率降低时，可使用子表查询以及join查询。
``` sql
--子表查询的方式分页
select * from table_name where index_id >= (select index_id from table_name order by index_id limit "$offset_num",1) limit "$limit_num";
select * from table_name where index_id >= (select index_id from table_name order by index_id limit 10000,1) limit 10;
--join方式
select * from table_name as t1 join (select index_id from table_name order by index_id desc 
limit 1 offset "($page-1)*($pagesize)") as t2 where t1.id <= t2.id order by t1.id desc limit "$pagesize";
select * from table_name as t1 join (select index_id from table_name order by index_id desc 
limit 1 offset 9999) as t2 where t1.id <= t2.id order by t1.id desc limit 10000;
```
上面的示例中，index_id建议是添加了索引的列。

## MySQL sql语句优化

MySQL sql语句性能优化步骤：
1. 查看语句执行计划
2. 根据执行计划修改查询语句或者创建索引

#### 1.执行计划

使用 explain 查看语句的执行计划，explain可查看select,delete,insert,replace以及update语句的执行计划。
