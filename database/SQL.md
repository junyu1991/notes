# SQL语句

> 本文只用于记录不熟悉的sql语句查询

## select distinct
当表中一个列包含多个重复值，且只需要查询出不同(distinct)的值时就可以使用distinct。
distinct关键词用于返回唯一不同的值。
``` sql
select distinct column_name from table_name;
```

## select top,limit,rownum
select top子句用于规定要返回的记录的数目。
select top子句对于用于数千条记录的大型表来说是非常有用的。

> 并不是所有的数据库都支持select top语句。mysql支持limit语句来选取指定的条数数据，oracle可以使用rownum来选取。

### SQL Server/MS Access语法
``` sql
select top number|percent column_name(s) from table_name;
```
select top percent 示例：
``` sql
select top 50 percent * from table_name;
```

### MySQL语法
``` sql
select column_name(s) from table_name limit number;
```

### Oracle语法
``` sql
select column_name(s) from table_name where rownum <= number;
```

## like
like操作符用于在where子句中搜索列中的指定模式。
``` sql
select column_name(s) from table_name where column_name like pattern;
```
like需要配合通配符使用，sql中可使用的通配符包括：
| 通配符 | 描述 |
| :--- | :--- |
| % | 替代0个或多个字符 |
| _ | 替代一个字符 |
| [charlist] | 字符列中的任何一个单一字符 |
| [^charlist]或[!charlist] | 不在字符列中的任何单一字符 |

> [charlist]在mysql中需要使用**regexp**或者**not regexp**来使用，Oracle不支持[charlist]

使用示例：
``` sql
--查询所有以"tom"结尾的name行
select * from table_name where name like '%tom';
--查询所有以"Tom"开头的name行
select * from table_name where name like 'Tom%';
--查询所有name中包含"tom"的行
select * from table_name where name like '%tom%';
--查询所有name以任意字符开始，然后是"om"的行
select * from table_name where name like '_om';
--查询所有name以"T"开始，然后是任意字符，以"m"结尾的行
select * from table_name where name like 'T_m';
--查询所有name以"To"开始，然后以任意字符结尾的行
select * from table_name where name like 'To_';
--查询所有name以T,J或K字符开始，以"om"结尾的行
select * from table_name where name like '^[TJK]om';
--查询所有name不是以T,J或K字符开始且以"om"结尾的行
select * from table_name where name like '^[!TJK]om';
```

## in
in操作符用于在查询条件中规定多个值
``` sql
--查询column_name值是value中值的行
select column_name(s) from table_name where column_name in (value1, value2,...);
--查询column_name值不是value中值的行
select column_name(s) from table_name where column_name not in (value1, value2,...);
```

## join
SQL join 子句用于把来自两个或多个表的行结合起来，基于这些表之间的共同字段。
不同sql join类型：
- inner join:如果表中有至少一个匹配，则返回行
- left join:即使右表中没有匹配，也从左表返回所有的行
- right join:即使左表中没有匹配，也从右表返回所有的行
- full join/full outer join:只要其中一个表存在匹配，则返回行

> MySQL不支持full outer join

用法：
``` sql
select column_name(s) from table1 inner join table2 on table1.column_name1=table2.column_name2;
select column_name(s) from table1 join table2 on table1.column_name1=table2.column_name2;
select column_name(s) from table1 left join table2 on table1.column_name1=table2.column_name2;
select column_name(s) from table1 right join table2 on table1.column_name1=table2.column_name2;
```

## union/union all
union操作符用于合并两个或多个select语句的结果。union内部的每个select语句必须拥有相同数量的列。列必须用于相似的数据类型。同时，每个select语句中的列的顺序必须相同。
语法：
``` sql
select column_name(s) from table1 union select column_name(s) from table2;
select column_name(s) from table1 union all select column_name(s) from table2;
```
union默认选取不同的值。如果允许重复的值，则需要使用union all。

## select into
select into语句从一个表复制数据，并将数据插入到另一个新表中。
语法：
``` sql
select column_name(s) into newtable from table;
```

> MySQL不支持select...into语句，支持insert into .... select，通常情况下可以使用以下语句来
拷贝表结构以及数据：
``` sql
create table newtable as select column_name(s) from oldtable;
```

## insert into select
insert into select语句从一个表复制数据，然后把数据插入到一个已存在的表中。目标表中任何已存在的行都不会受到影响。
语法：
``` sql
insert into table2 (column_name(s)) select column_name(s) from table1;
```

## foreign key
一个表中的foreign key指向另一个表中的unique key(唯一约束的键)。
foreign key约束用于预防破坏表之间连接的行为。foreign key约束也能防止非法数据插入外键列，因为它必须是它指向的那个表中的值之一。
创建foreign key示例：

- 在create table时创建外键约束：
``` sql
--mysql
CREATE TABLE Orders
(
	O_Id int NOT NULL,
	OrderNo int NOT NULL,
	P_Id int,
	PRIMARY KEY (O_Id),
	FOREIGN KEY (P_Id) REFERENCES Persons(P_Id)
);
--SQL Server / Oracle / MS Access：
CREATE TABLE Orders
(
	O_Id int NOT NULL PRIMARY KEY,
	OrderNo int NOT NULL,
	P_Id int FOREIGN KEY REFERENCES Persons(P_Id)
);
--重命名foreign key约束
CREATE TABLE Orders
(
	O_Id int NOT NULL,
	OrderNo int NOT NULL,
	P_Id int,
	PRIMARY KEY (O_Id),
	CONSTRAINT fk_PerOrders FOREIGN KEY (P_Id)
	REFERENCES Persons(P_Id)；
);
```
- 使用alter table创建外键约束：

