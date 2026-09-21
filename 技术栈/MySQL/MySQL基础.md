> MySQL 是目前最流行的开源的，免费的关系型数据库，适用于中小型甚至大型互联网应用，能够在windows 和 linux 平台上部署

# 基本概念

- 数据库（Database）：存储在计算机磁盘上的有组织、可共享的大量数据的集合
- 分类：关系型数据库，非关系型数据库
	- 关系型数据库：
		- MySQL：小型数据库管理
		- Oracle：大型数据库管理
		- SQLserver：小型数据库管理
		- SQLite：嵌入式Linux开发的轻量级数据库
	- 非关系型数据库：Redis，MongoDB
- 数据库管理系统（DataBase Management System）：简称DBMS，主要用于科学组织和存储数据，高效地获取和维护数据
- 记录：能够描述一条数据的完整信息，即行
- 字段：描述数据的不可分割的最小单位，即列

连接数据库：`mysql -h MySQL的服务器IP -u 用户名 -p`
修改root密码：`ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '密码';`

# SQL

> 结构化查询语言（Structured Query Language），简称SQL，结构化查询语句分为数据定义语言、数据操作语言、数据查询语言和数据控制语言四大类

## SQL分类

| 名称 | 描述 | 命令 |
| :--- | :--- | :--- |
| 数据定义语言<br>（DDL） | 数据库、数据表的创建、修改和删除 | CREATE、ALTER、DROP |
| 数据操作语言<br>（DML） | 数据的增加、修改和删除 | INSERT、UPDATE、DELETE |
| 数据查询语言<br>（DQL） | 数据的查询 | SELECT |
| 数据控制语言<br>（DCL） | 用户授权、事务的提交和回滚 | GRANT、COMMIT、ROLLBACK |

## DDL

> 数据定义语言（Data Define Language），定义数据库，数据表

### 数据库操作

`[]`表示可选

- 创建数据库：`CREATE DATABASE [IF NOT EXISTS] 数据库名称 DEFAULT CHARACTER SET 字符集 COLLATE 排序规则;`
	- `CREATE DATABASE IF NOT EXISTS lesson DEFAULT CHARACTER SET GBK COLLATEGBK_CHINESE_CI;`
- 修改数据库：`ALTER DATABASE 数据库名称 CHARACTER SET 字符集 COLLATE 排序规则`
- 删除数据库：`DROP DATABASE [IF EXISTS] 数据库名称`
- 查看数据库：`SHOW DATABASES`
- 使用数据库：`USE 数据库名称`

### 列类型

在 MySQL 中，常用列类型主要分为数值类型、日期时间类型、字符串类型

#### 数值类型

| 类型 | 说明 | 取值范围 | 存储需求 |
| :--- | :--- | :--- | :--- |
| `tinyint` | 非常小的数据 | 有符号值：-2⁷ ~ 2⁷-1 无符号值：0 ~ 2⁸-1 | 1字节 |
| `smallint` | 较小的数据 | 有符号值：-2¹⁵ ~ 2¹⁵-1 无符号值：0 ~ 2¹⁶-1 | 2字节 |
| `mediumint` | 中等大小的数据 | 有符号值：-2²³ ~ 2²³-1 无符号值：0 ~ 2²⁴-1 | 3字节 |
| `int` | 标准整数 | 有符号值：-2³¹ ~ 2³¹-1 无符号值：0 ~ 2³²-1 | 4字节 |
| `bigint` | 较大的整数 | 有符号值：-2⁶³ ~ 2⁶³-1 无符号值：0 ~ 2⁶⁴-1 | 8字节 |
| `float` | 单精度浮点数 | 无符号值：1.1754351 \* 10⁻³⁸ ~ 3.402823466 \* 10³⁸ | 4字节 |
| `double` | 双精度浮点数 | 无符号值：2.22507385 \* 10⁻³⁰⁸ ~ 1.79769313 \* 10³⁰⁸ | 8字节 |
| `decimal` | 字符串形式的浮点数 | decimal(m, d) 整个字符串最长m，小数部分最长d| m个字节  |

#### 日期时间类型

| 类型 | 说明 | 取值范围 |
| :--- | :--- | :--- |
| `DATE` | YYYY-MM-dd，日期格式 | 1000-01-01 ~ 9999-12-31 |
| `TIME` | HH:mm:ss，时间格式 | -838:59:59.000000 ~ 838:59:59.000000 |
| `DATETIME` | YY-MM-dd HH:mm:ss | 1000-01-01 00:00:00.000000 ~ 9999-12-31 23:59:59.999999 |
| `TIMESTAMP` | YYYY-MM-dd HH:mm:ss 格式表示的时间戳 | 1970-01-01 00:00:01.000000 ~ 2038-01-19 03:14:07.999999 |
| `YEAR` | YYYY 格式的年份值 | 1901~2155 |

#### 字符串类型

| 类型 | 说明 | 最大长度 |
| :--- | :--- | :--- |
| `char` [(M)] | 固定长字符串，检索快但费空间， 0 <= M <= 255 | M字符 |
| `varchar` [(M)] | 可变字符串 0 <= M <= 65535 | 变长度 |
| `text` | 文本串 | 2¹⁶-1字节 |

#### 修饰属性

| 属性名 | 说明 | 示例 |
| :--- | :--- | :--- |
| `UNSIGNED` | 无符号，只能修饰数值类型，表示该列数据不能出现负数 | INT(4) UNSIGNED，表示只能为4位大于等于0的整数 |
| `ZEROFILL` | 不足的位数使用0来填充 | INT(4) ZEROFILL，如果给定的值为10，此时只有2位，而该列需要4位，不足的2位由0来填充，最终值为0010 |
| `NOT NULL` | 表示该列类型的值不能为空 | VARCHAR(20) NOT NULL，表示该列数据不能为空值 |
| `DEFAULT` | 表示设置默认值 | INT(4) DEFAULT 0，表示该列不赋值时默认为0 |
| `AUTO_INCREMENT` | 表示自增长，只能应用于数值列类型，该列类型必须为键，且不能为空 | INT(11) AUTO_INCREMENT NOT NULL PRIMARY KEY。第一次为该列中插入值时1，第二次为2 |

### 数据表操作

MySQL中的数据表类型：MyISAM，InnoDB，HEAP，BOB，CSV等
MyISAM和InnoDB常用

#### MyISAM和InnoDB区别

| 名称 | MyISAM | InnoDB |
| :--- | :--- | :--- |
| 事务处理 | 不支持 | 支持 |
| 数据行锁定 | 不支持 | 支持 |
| 外键约束 | 不支持 | 支持 |
| 全文索引 | 支持 | 不支持 |
| 表空间大小 | 较小 | 较大，约2倍 |

- 数据行锁定：一行数据，当一个用户在修改该数据时，可以直接将该条数据锁定
- 选择数据表类型：当涉及的业务操作以查询居多，修改和删除较少时，可以使用MyISAM；当涉及的业务操作经常会有修改和删除操作时，使用InnoDB

#### 操作

- 创建数据表：
	```sql
	CREATE TABLE [IF NOT EXISTS] 数据表名称{
		字段名1 列类型(长度) [修饰属性] [键/索引] [注释],
		字段名2 列类型(长度) [修饰属性] [键/索引] [注释],
		字段名1 列类型(长度) [修饰属性] [键/索引] [注释]
	} [ENGINE = 数据表类型] [CHARSET=字符串编码] [注释];
	```
	
	```sql title:"学生表"
	CREATE TABLE IF NOT EXISTS student(
		`number` VARCHAR(30) NOT NULL PRIMARY KEY COMMENT '学号，主键',
		name VARCHAR(30) NOT NULL COMMENT '姓名',
		sex TINYINT(1) UNSIGNED DEFAULT 0 COMMENT '性别：0-男 1-女 2-其他',
		age TINYINT(3) UNSIGNED DEFAULT 0 COMMENT '年龄',
		score DOUBLE(5, 2) UNSIGNED COMMENT '成绩'
	)ENGINE=InnoDB CHARSET=UTF8 COMMENT='学生表';
	```
- 修改数据表：
	- 修改表名：`ALTER TABLE 表名 RENAME AS 新表名;`
	- 增加字段：`ALTER TABLE 表名 ADD 字段名 列类型(长度) [修饰属性] [键/索引] [注释];`
	- 查看表结构：`DESC 表名;`
	- 修改字段：
		- `ALTER TABLE 表名 MODIFY 字段名 列类型(长度) [修饰属性] [键/索引] [注释];`，只能修改修饰属性
		- `ALTER TABLE 表名 CHANGE 字段名 新字段名 列类型(长度) [修饰属性] [键/索引] [注释];`
	- 删除字段：`ALTER TABLE 表名 DROP 字段名;`
- 删除数据表：`DROP TABLE [IF EXISTS] 表名;`

## DML

> 数据操作语言（Data Manipulation Language），对数据的增删改

- 插入：
	- `INSERT INTO 表名(字段名1,字段名2,字段名3) VALUES(字段值1,字段值2,字段值3);`，字段名和字段值一一对应
	- `INSERT INTO 表名 VALUES(字段值1,字段值2,字段值3);`，字段值和创建表时的字段名一一对应
	- `INSERT INTO 表名 VALUES(字段值1,字段值2,字段值3),(字段值1,字段值2,字段值3),(字段值1,字段值2,字段值3);`，可以一次性插入多条数据
- 修改：`UPDATE 表名 SET 字段名1=值1[,字段名2=值2,字段名3=值3] [WHERE 条件];`
	- `WHERE`条件子句：使用`>`，`<`，`>=`，`<=`，`=`，`!=`，`AND`，`OR`等
- 删除：
	- `DELETE FROM 表名 [WHERE 条件];`：删除表中的数据，不会重置自增长计数器，可以使用事务回滚恢复数据， MySQL 不允许在`DELETE`语句的`WHERE`子句中直接使用正在被更新的表
	- `TRUNCATE [TABLE] 表名;`：清空表中数据，会重置自增长计数器，数据无法恢复

## DQL

> 数据查询语言（Data Query Language），查询数据

- 查询：`SELECT ALL 字段名1 AS 别名1[,字段名2 AS 别名2] FROM 表名 WHERE 条件;`
	- `ALL`表示查询所有满足条件的记录，可以省略；若为`DISTINCT`表示去重
	- 若用`*`代替字段名，表示显示所有字段
	- `AS`可以给字段，数据表取别名

### 比较操作符

| 操作符 | 语法 | 说明 |
| :--- | :--- | :--- |
| `IS NULL` | `字段名 IS NULL` | 如果字段的值为NULL，则条件满足 |
| `IS NOT NULL` | `字段名 IS NOT NULL` | 如果字段的值不为NULL，则条件满足 |
| `BETWEEN...AND` | `字段名 BETWEEN 最小值 AND 最大值` | 如果字段的值在最小值与最大值之间（能够取到最小值和最大值），则条件满足 |
| `LIKE` | `字段名 LIKE '%匹配内容%'` | 如果字段值包含有匹配内容，则条件满足，两边的%表示两边可能还有东西 |
| `IN` | `字段名 IN(值1, 值2, ..., 值n)` | 如果字段值在值1,值2, ..., 值n中，则条件满足 |

- `SELECT * FROM course WHERE score BETWEEN 2 AND 4;`：从课程表查询学分在2~4之间的课程所有字段
- `SELECT * FROM course WHERE name LIKE '%v%';`：从课程表查询课程名包含"V"的课程所有字段
- `SELECT * FROM course WHERE name LIKE '___'`：从课程表查询课程名有三个字符的课程所有字段
- `SELECT * FROM course WHERE name LIKE 'J%';`：从课程表查询课程名以"J"开头的课程的所有字段
- ````SELECT * FROM course WHERE `number` IN (1,3,5)````：从课程表查询编号在1，3，5中的课程的所有字段

### 分组

#### 分组查询

> 分组查询所得的结果只是该组中的第一条数据

- `SELECT ALL 字段名1 AS 别名1[,字段名2 AS 别名2] FROM 表名 WHERE 条件 GROUP BY 字段名1[,字段名2,字段名3];`

#### 聚合函数

- `COUNT()`：统计满足条件的数据总条数
	- `SELECT COUNT(*) total FROM student WHERE score>80;`
- `SUM()`：计算满足条件的字段值总和，只能用于数值类型的字段或表达式
	- `SELECT COUNT(*) totalCount, SUM(score) totalScore FROM student WHERE score<60;`
- `AVG()`：计算满足条件的字段平均值，只能用于数值类型的字段或表达式
- `MAX()`：计算满足条件的字段最大值，只能用于数值类型的字段或表达式
- `MIN()`：计算满足条件的字段最小值，只能用于数值类型的字段或表达式

#### 分组查询结果筛选

- `SELECT ALL 字段名1 AS 别名1[,字段名2 AS 别名2] FROM 表名 WHERE 条件 GROUP BY 字段名1[,字段名2,字段名3] HAVING 筛选条件;`：`HAVING`后的条件是对组的筛选条件

### 排序

- `SELECT 字段名1,字段名2 FROM 表名 WHERE 条件 ORDER BY 字段名1 ASC[,字段名2 DESC]`
	- `ORDER BY`必须在`WHERE`后面
	- `ASC`表示升序，`DESC`表示降序

### 分页

- `SELECT 字段名1,字段名2 FROM 表名 WHERE 条件 LIMIT 偏移量 查询条数`
	- 偏移量表示要跳过的行数
	- 查询条数表示要显示的结果的最大行数

一个查询中先后顺序：分组，排序，分页

# 常用函数

## 数学函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| ABS(X) | 返回X的绝对值。 | SELECT ABS(-8); |
| FLOOR(X) | 向下取整 | SELECT FLOOR(1.3); |
| CEIL(X) | 向上取整 | SELECT CEIL(1.3); |
| TRUNCATE(X,D) | 返回数值X保留到小数点后D位的值，截断时不进行四舍五入。 | SELECT TRUNCATE(1.2328,3); |
| ROUND(X) | 四舍五入为整数 | SELECT ROUND(1.8); |
| ROUND(X,D) FORMAT(X,D) | 四舍五入到小数点后D位 | SELECT ROUND(1.2323,3); |
| RAND() | 返回0~1的随机数。 | SELECT RAND(); |
| MOD(N,M) | 返回N除以M以后的余数。 | SELECT MOD(9,2); |

## 字符串函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| CHAR_LENGTH(str) | 计算字符串字符个数。 | SELECT CHAR_LENGTH('中国'); |
| LENGTH(str) | 返回值为字符串str的长度，单位为字节。 | SELECT LENGTH('中国'); |
| CONCAT(s1,s2, ...) | 将多个字符串拼接在一起，其中任意一个为NULL则返回值为NULL。 | SELECT CONCAT('ad','min'); |
| LOWER(str)<br>LCASE(str) | 将str中的字母全部转换成小写。 | SELECT LOWER('ABC');<br>SELECT LCASE('ABC'); |
| UPPER(str)<br>UCASE(str) | 将字符串中的字母全部转换成大写。 | SELECT UPPER('abc');<br>SELECT UCASE('abc'); |
| LEFT(s,n)<br>RIGHT(s,n) | 前者返回字符串s从最左边开始的n个字符，后者返回字符串s从最右边开始的n个字符。 | SELECT LEFT('abcdefg', 5);<br>SELECT RIGHT('abcdefg', 5); |
| LTRIM(s)<br>RTRIM(s) | 前者返回字符串s，其左边所有空格被删除，后者返回字符串s，其右边所有空格被删除。 | SELECT LTRIM(' abcde ');<br>SELECT RTRIM(' abcde '); |
| TRIM(s) | 返回字符串s删除了两边空格之后的字符串。 | SELECT TRIM(' abcde '); |
| REPLACE(s,s1,s2) | 返回一个字符串，用字符串s2替代字符串s中所有的字符串s1。 | SELECT REPLACE('ababac', 'ab', 'd'); |
| SUBSTRING(s,n,len) | 从字符串s中返回一个第n个字符开始长度为len的字符串。 | SELECT SUBSTRING('abcdef', 2, 3); |

## 日期和时间函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| CURDATE()<br>CURRENT_DATE() | 返回当前日期 | SELECT CURDATE(); |
| CURTIME()<br>CURRENT_TIME() | 返回当前时间 | SELECT CURTIME(); |
| NOW()<br>CURRENT_TIMESTAMP()<br>SYSDATE() | 返回当前日期和时间 | SELECT NOW(); |
| YEAR(d) | 返回日期d中的年 | SELECT YEAR(NOW()); |
| MONTH(d) | 返回日期d中的月份值，范围1~12 | SELECT MONTH(NOW()); |
| DAYOFMONTH(d) | 返回给定日期d是当月的第几天 | SELECT DAYOFMONTH(NOW()); |
| DAYOFWEEK(d) | 返回给定日期d是星期几，星期日是1 | SELECT DAYOFWEEK(NOW()); |
| HOUR(d) | 返回给定日期d的小时数 | SELECT HOUR(NOW()); |
| MINUTE(d) | 返回给定日期d的分钟数 | SELECT MINUTE(NOW()); |
| SECOND(d) | 返回给定日期d的秒数 | SELECT SECOND(NOW()); |
| ADDDATE(d, n) | 返回起始日期d加上n天的日期 | SELECT ADDDATE(NOW(), 3); |
| TIMESTAMPDIFF(INTERVAL expr type, d1, d2) | 返回给定日期 d1 和 d2 的时间差 | SELECT TIMESTAMPDIFF(YEAR,'2019-10-10', '2021-10-1'); |
| DATE_FORMAT(d,f) | 返回给定日期格式的字符串 | SELECT DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')，24小时制时%H，12小时制是%h |

- 查询今天过生日的学生信息：`SELECT * FROM stu WHERE MONTH(birthday)=MONTH(NOW()) AND DAYOFMONTH(birthday)=DAYOFMONTH(NOW());`
- 查询本周过生日的学生信息：`SELECT * FROM stu WHERE RIGHT(birthday, 5) > RIGHT(DATE_FORMAT(ADDDATE(NOW(), -DAYOFWEEK(NOW())), '%Y-%m-%d'), 5) AND RIGHT(birthday, 5) <=RIGHT(DATE_FORMAT(ADDDATE(NOW(),7-DAYOFWEEK(NOW())), '%Y-%m-%d'), 5);`

## 条件判断函数

### IF

- `IF(条件,表达式1,表达式2)`：条件满足使用表达式1，否则使用表达式2
	- `SELECT id,stu_name,course, IF(score>=60, '及格','不及格') score FROM score;`
- `IFNULL(字段名,表达式)`：字段为空使用表达式，否则使用字段值
	- `SELECT id,stu_name,course, IFNULL(score, '缺考') score FROM score;`
- 
	```sql
	IF 条件 THEN
	ENDIF;
	```

### CASE WHEN

- `CASE WHEN 条件1 THEN 表达式1 [WHEN 条件2 THEN 表达式2] ELSE 表达式n END`：相当于C++中的if-else语句
	- 查询每位学生的各科成绩：
	```sql
	SELECT
	stu_name,
	course,
	MAX(CASE WHEN (course = 'Java') THEN score ELSE 0 END) Java,
	MAX(CASE WHEN (course = 'Html') THEN score ELSE 0 END) Html,
	MAX(CASE WHEN (course = 'Jsp') THEN score ELSE 0 END) Jsp,
	MAX(CASE WHEN (course = 'Spring') THEN score ELSE 0 END) Spring
	FROM score
	GROUP BY stu_name;
	```

## 系统信息函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| VERSION() | 获取数据库的版本号 | SELECT VERSION(); |
| CONNECTION_ID() | 获取服务器的连接数 | SELECT CONNECTION_ID(); |
| DATABASE()<br>SCHEMA() | 获取当前数据库名 | SELECT DATABASE();<br>SELECT SCHEMA(); |
| USER()<br>SYSTEM_USER()<br>SESSION_USER() | 获取当前用户名 | SELECT USER(); |
| CURRENT_USER()<br>CURRENT_USER | 获取当前用户名 | SELECT CURRENT_USER; |

# 联表查询

## 主外键关联关系

**外键**的值使用的是关联表中的**主键**的值

```sql title:"定义"
DROP TABLE IF EXISTS cls;
CREATE TABLE cls(
	number INT(11) AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT '班级编号，主键',
	name VARCHAR(20) NOT NULL COMMENT '班级名称',
	grade VARCHAR(20) NOT NULL COMMENT '年级'
)ENGINE=InnoDB CHARSET=UTF8 COMMENT='班级表';

DROP TABLE IF EXISTS student;
CREATE TABLE student(
	number BIGINT(20) AUTO_INCREMENT NOT NULL COMMENT '学号，主键',
	name VARCHAR(20) NOT NULL COMMENT '姓名',
	sex VARCHAR(2) DEFAULT '男' COMMENT '性别',
	age TINYINT(3) DEFAULT 0 COMMENT '年龄',
	cls_number INT(11) NOT NULL COMMENT '所属班级',
	-- number定义为学生表的主键
	PRIMARY KEY(number),
	-- 字段cls_number与cls表中的number字段相关联
	FOREIGN KEY(cls_number) REFERENCES cls(number)
)ENGINE=InnoDB CHARSET=UTF8 COMMENT='学生表';
```

## 约束

### 对表的约束

```sql title:"主键约束"sql title:"主键约束"
--添加主键约束，保证数据唯一性
ALTER TABLE 表名 ADD PRIMARY KEY(字段名1,字段名2,字段名3);
--删除主键约束
ALTER TABLE 表名 DROP PRIMARY KEY;
```

```sql title:"外键约束"
--添加外键约束
ALTER TABLE 表名1 ADD CONSTRAINT 外键名 FOREIGN KEY(外键的字段名) REFERENCES 表名2(主键的字段名);
--删除外键约束
ALTER TABLE 表名 DROP FOREIGN KEY 外键名;
```

```sql title:"唯一约束"
--添加唯一约束
ALTER TABLE 表名 ADD CONSTRAINT 约束名 UNIQUE(字段名1,字段名2,字段名3);
--删除唯一约束
ALTER TABLE 表名 DROP KEY 约束名;
```

### 对字段的约束

```sql title:"非空约束"
--添加非空约束
ALTER TABLE 表名 MODIFY 字段名 列类型 NOT NULL;
--删除非空约束
ALTER TABLE 表名 MODIFY 字段名 列类型 NULL;
```

```sql title:"默认值约束"
--添加默认值约束
ALTER TABLE 表名 MODIFY 字段名 SET DEFAULT 默认值;
--删除默认值约束
ALTER TABLE 表名 MODIFY 字段名 DROP DEFAULT;
```

```sql title:"自增约束"
--添加自增约束
ALTER TABLE 表名 MODIFY 字段名 列类型 AUTO_INCREMENT;
--删除自增约束
ALTER TABLE 表名 MODIFY 字段名 列类型;
```

## 索引

> 在关系数据库中，索引是一种单独的、物理的对数据库表中一列或多列的值进行排序的一种存储结构，它是表中一列或多列值的集合和相应的指向表中物理标识这些值的数据页的逻辑指针清单

### 作用

- 保证数据的准确性
- 提高检索速度
- 提高系统性能

### 类型

- 唯一索引（UNIQUE）：不可以出现相同的值，可以有NULL值
- 普通索引（INDEX）：允许出现相同的索引内容
- 主键索引（PRIMARY KEY）：不允许出现相同的值
- 全文索引（FULLTEXT INDEX）：可以针对值中的某一个单词，效率不高，InnoDB不支持全文索引
- 组合索引：实质上是将多个字段建到一个索引里，列值的组合必须唯一

### 操作

```sql
--创建索引
ALTER TABLE 表名 ADD INDEX 索引名 (字段名1,字段名2,字段名3);
--创建全文索引
ALTER TABLE 表名 ADD FULLTEXT 索引名 (字段名1,字段名2,字段名3);
--删除索引
ALTER TABLE 表名 DROP INDEX 索引名;
```

### 注意

- 虽然索引大大提高了查询速度，但也会降低更新表的速度，比如对表进行`INSERT`,`UPDATE`和`DELETE`操作时，数据库不仅要保存数据，还要保存索引文件
- 建立索引会占用磁盘空间的索引文件；如果索引创建过多（尤其是在字段多、数据量大的表上创建索引），就会导致索引文件过大，这样反而会降低数据库性能；因此，索引要建立在**经常进行查询操作**的字段上
- 不要在列上进行运算（包括函数运算），这会忽略索引的使用
- 不建议使用`LIKE`操作，如果非使用不可，注意正确的使用方式；`LIKE '%查询内容%'`不会使用索引，而`LIKE '查询内容%'`可以使用索引
- 避免使用`IS NULL`，`NOT IN`，`<`，`>`，`!=`，`OR`操作，这些操作都会忽略索引而进行全表扫描

## 多表查询

### 内连接

相当与在笛卡尔体积上加上了连接条件；若没有连接条件，内连接上升为笛卡尔体积

```sql
SELECT 字段名1,字段名2,字段名3 FROM 表名1 [INNER] JOIN 表名2 [ON 连接条件];
SELECT 字段名1,字段名2,字段名3 FROM 表名1,表名2 [WHERE 关联条件 AND 查询条件];
```

### 外连接

- 涉及两张表：主表和从表，要查询的信息主要来源于主表
- 外连接查询的结果为主表中所有的记录，如果从表中有和它匹配的，则显示匹配的值，这部分相当于内连接查询出来的结果；如果从表中没有和它匹配的，则显示null
- 外连接查询结果=内连接查询结果+主表中有的而内连接结果中没有的信息

```sql
--左外连接
SELECT 字段名1,字段名2,字段名3 FROM 主表 LEFT JOIN 从表 [ON 连接条件];
--右外连接
SELECT 字段名1,字段名2,字段名3 FROM 从表 RIGHT JOIN 主表 [ON 连接条件];
```

## 子查询

> 子查询就是嵌套在其他查询中的查询

```sql title:"SELECT...FROM之间"
SELECT
	id,
	`name`,
	(SELECT text FROM dict WHERE type='sex' AND value=sex) sex,
	birthday,
	class
FROM
	stu;
```

```sql title:"FROM...WHERE之间"
SELECT c.*, d.* FROM stu c
INNER JOIN
	score d ON c.id=d.stu_id
INNER JOIN
	(SELECT    --子查询的结果本身是一个表
		TIMESTAMPDIFF(YEAR, a.birthday,NOW()) age,
		b.score
	FROM stu a INNER JOIN score b ON a.id=b.stu_id
	WHERE a.name='mofei'
	AND b.course='Java') e
ON TIMESTAMPDIFF(YEAR, c.birthday,NOW())=e.age AND d.score=e.score
WHERE d.course='Java';
```

```sql title:"WHERE之后"
--前提是子查询返回一个值
SELECT a.*, b.* FROM stu a INNER JOIN score b ON a.id=b.stu_id
WHERE b.score=(SELECT MAX(score) FROM score WHERE course='Java')
AND b.course='Java';
```

# 变量

MySQL中的变量分为局部变量，用户变量，会话变量，全局变量；局部变量和用户变量应用较多

## 全局变量

MySQL全局变量会影响服务器整体操作，当服务启动时，它将所有全局变量初始化为默认值；要想更改全局变量，必须具有管理员权限；作用服务器的整个生命周期

- 显示所有全局变量：`SHOW GLOBAL VARIABLES;`
- 设置全局变量：
	- `SET GLOBAL sql_warnings=ON;`
	- `SET @@GLOBAL.sql_warnings=OFF;`
- 查询全局变量的值：
	- `SELECT @@GLOBAL.sql_warnings;`
	- `SHOW GLOBAL VARIABLES LIKE '%sql_warnings%';`

## 会话变量

MySQL会话变量是服务器为每个连接的客户端维护的一系列变量；其作用域仅限于当前连接，因此，会话变量是独立的

- 显示所有会话变量：`SHOW SESSION VARIABLES;`
- 设置会话变量：
	- `SET SESSION auto_increment_increment=1;`
	- `SET @@SESSION.auto_increment_increment=2;`
	- `SET auto_increment_increment=3;`，默认缺省为SESSION，即设置会话变量的值
- 查询会话变量的值：
	- `SELECT @@auto_increment_increment;`
	- `SELECT @@SESSION.auto_increment_increment;`
	- `SHOW SESSION VARIABLES LIKE '%auto_increment_increment%';`，SESSION关键字可以省略或用关键字LOCAL替代

## 用户变量

MySQL中用户变量不用提前声明，在用的时候直接用`@变量名`使用；其作用域为当前连接

- 赋值：
	- `SET @age=18;`，可以使用`=`或`:=`
	- `SELECT @age:=18;`，必须使用`:=`
	- `SELECT @age:=age FROM stu WHERE name='mofei';`，必须使用`:=`
	- `SELECT age INTO @age FROM stu WHERE name='mofei';`
	- `SELECT 18 INTO @age;`
- 查询：`SELECT @age;`

## 局部变量

MySQL的局部变量只能用在`BEGIN/END`块中，比如存储过程的`BEGIN/END`块

- 定义局部变量：`DECLARE age INT(3) DEFAULT 0;`
- 对局部变量的赋值和查询与用户变量一样

# SQL语句集

## 存储过程

> 在大型数据库系统中，存储过程（Procedure）是一组为了完成特定功能而存储在数据库中的SQL语句集，一次编译后永久有效

作用：
- 运行速度快：
	在存储过程创建的时候，数据库已经对其进行了一次解析和优化，存储过程一旦执行，在内存中就会保留一份这个存储过程，下次再执行同样的存储过程时，可以从内存中直接调用，所以执行速度会比普通SQL语句快
- 减少网络传输：
	存储过程直接就在数据库服务器上跑，所有的数据访问都在数据库服务器内部进行，不需要传输数据到其它服务器，所以会减少一定的网络传输
- 增强安全性：
	提高代码安全，防止SQL被截获，篡改

```sql title:"语法"
--声明分割符
DELIMITER $$  --将语句的结束符号从分号;临时改为两个$$(可以是自定义)
CREATE PROCEDURE 存储过程名称 (参数类型 参数名1 数据类型,参数类型 参数名2 数据类型,参数类型 参数名3 数据类型)
--语句块开始
BEGIN
	--SQL语句集
END $$
--还原分隔符
DELIMITER ;

--调用存储过程
CALL 存储过程名(参数1,参数2,参数3);
```

参数类型：
- `IN`：输入参数，调用者向存储过程传入值
- `OUT`：输出参数，存储过程向调用者传出值，只能是变量
- `INOUT`：输入输出参数，只能是变量

```sql title:"银行转账业务"
DELIMITER $$
CREATE PROCEDURE transfer(IN transferFrom BIGINT,IN tranferTo BIGINT,IN transferMoney BIGINT(20))
BEGIN
	UPDATE account SET balance=balance-transferMoney WHERE id=transferFrom;
	UPDATE account SET balance=balance+transferMoney WHERE id=transferTo;
END $$
DELIMITER ;
```

```sql title:"优化"
DROP PROCEDURE IF EXISTS transfer;
DELIMITER $$
CREATE PROCEDURE transfer(IN transferFrom BIGINT,IN tranferTo BIGINT,IN transferMoney BIGINT(20))
BEGIN
	--定义执行结果变量，0失败，1成功
	DECLARE result TINYINT(1) DEFAULT 0;
	--转账用户的余额必须大于转账金额
	UPDATE account SET balance=balance-transferMoney WHERE id=transferFrom AND balance>=transferMoney;
	--检测受影响的行数，ROW_COUNT()表示受上一条语句影响的行数受上一条语句影响的行数
	IF ROW_COUNT()=1    --更新成功
	THEN
		UPDATE account SET balance=balance+transferMoney WHERE id=transferTo;
		IF ROW_COUNT()=1
		THEN
			SET result=1;
		END IF;
	END IF;
	--查询结果
	SELECT result;
END $$
DELIMITER ;
```

## 事务

> 事务（Transaction）是访问并可能操作各种数据项的一个数据库操作序列，这些操作要么全部执行，要么全部不执行，是一个不可分割的工作单位；事务由事务开始与事务结束之间执行的全部数据库操作组成

事务特性：
- 原子性（Automicity）：事务的各元素是不可分的，它们是一个整体，要么都执行，要么都不执行
- 一致性（Consistency）：事务完成时，必须保证所有数据保持一致；转账操作完成后，所有账户总金额应保持不变，若总金额发生了改变，数据处于非一致状态
- 隔离性（Isolation）：对数据库操作的多个并发事务彼此独立，互不影响
- 持久性（Durability）：对于已提交的事务，系统需保证该事务对数据库的改变不被丢失，即便数据库出现故障

使用`START TRANSACTION`,`ROLLBACK`,`COMMIT`实现事务

```sql title:"银行转账业务"
DELIMITER $$
CREATE PROCEDURE transfer(IN transferFrom BIGINT,IN transferTo BIGINT,IN transferMoney BIGINT,OUT result TINYINT(1))
BEGIN
	SET result=1;
	--声明一个处理器，若SQLEXCEPTION发生，设置result为0
	--CONTINUE表示SQLEXCEPTION发生后继续执行后面的语句，若为EXIT，直接退出当前存储过程
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET result=0;
	--开启事务
	START TRANSACTION;
	UPDATE account SET balance=balance-transferMoney WHERE id=transferFrom AND balance>=transferMoney;
	SET result=ROW_COUNT();
	IF result=1 THEN
		UPDATE account SET balance=balance+transferMoney WHERE id=transferTo;
		SET result=ROW_COUNT();
	ENDIF;
	IF result=1 THEN COMMIT;    --两条语句都执行成功，提交事务
	ELSE ROLLBACK;    --两条语句没有全部执行成功，回滚事务
	ENDIF;
END $$
DELIMITER ;

--调用存储过程
CALL transfer(123,124,5000,@res);
SELECT @res;
```

## 自定义函数

> 函数（Function）就是在大型数据库系统中，一组为了完成特定功能而存储在数据库中的SQL语句集，一次编译后永久有效

### 语法

```sql
DELIMITER $$
CREATE FUNCION 函数名(参数1 数据类型,参数2 数据类型,参数3 数据类型)
RETURNS 数据类型
函数特征
BEGIN
	--SQL语句集
	RETURN 返回值;
END $$
DELIMITER ;

--调用函数
SELECT 函数名(参数1,参数2,参数3);
```

函数特征：多个特征用`|`隔开
- `DETERMINISTIC`：不确定的
- `NO SQL`：没有SQL语句
- `CONTAINS SQL`：含有SQL语句
- `READS SQL DATA`：要读取数据
- `MODIFIES SQL DATA`：要修改数据

### 循环结构

```sql title:"WHILE"
WHILE 循环条件 DO
	--SQL语句集
END WHILE
```

```sql title:"REPEAT"
REPEAT
	--SQL语句集
UNTIL 循环终止条件 END REPEAT;
```

```sql title:"LOOP"
标号:LOOP
	--SQL语句集
	IF 循环终止条件 THEN LEAVE 标号;
	END IF;
END LOOP;
```

实例：

```sql title:"生成指定长度随机字符串"
DROP FUNCTION IF EXISTS randomStr;
DELIMITER $$
CREATE FUNCTION randomStr(len INT(11))
RETURNS VARCHAR(255)
NO SQL
BEGIN
	--随机字符种子
    DECLARE s VARCHAR(50) DEFAULT "abcdefghijklmnopqrstuvwxyz0123456789";
    --返回值
    DECLARE result VARCHAR(255) DEFAULT "";
    --循环变量
    DECLARE i INT(11) DEFAULT 0;
    --随机字符在s中的位置
    DECLARE posi INT(11);
    --随机字符
    DECLARE temp VARCHAR(5);
    --循环获取len个随机字符并拼接
    WHILE i<len DO
        SET posi = MOD(RAND()*10000,CHAR_LENGTH(s))+1;
        SET temp = SUBSTRING(s,posi,1);
        SET result=CONCAT(result,temp);
        SET i=i+1;
    END WHILE;
    RETURN result;
END$$

DELIMITER ;

SELECT randomStr(10);
```

## 触发器

> 触发器（trigger）是用来保证数据完整性的一种方法，由事件来触发，比如当对一个表进行增删改操作时就会被激活执行，经常用于加强数据的完整性约束和业务规则

### 语法

```sql
DELIMITER $$
CREATE TRIGGER 触发器名称 执行时机 触发器类型 ON 表名 FOR EACH ROW
BEGIN
	--SQL语句集
END $$
DELIMITER ;
```

执行时机：
- `BEFORE`：在触发之前执行
- `AFTER`：在出发之后执行

触发器类型：
- `INSERT`：`NEW`表示要插入的数据
- `UPDATE`：`OLD`表示修改前的数据，`NEW`表示修改后的数据
- `DELETE`：`OLD`表示要删除的数据

### 使用场景

现有商品表`goods`和订单表`orders`

- 每一个订单的生成都意味着商品数量的减少

	```sql
	DROP TRIGGER IF EXISTS addOrder;
	DELIMITER $$
	CREATE TRIGGER addOrder AFTER INSERT ON `orders` FOR EACH ROW
	BEGIN
		UPDATE goods SET number=number-NEW.sal_count WHERE id=NEW.goods_id;
	END $$
	DELIMITER ;
	```

- 每一个订单的取消都意味着商品数量的增加

	```sql
	DROP TRIGGER IF EXISTS deleteOrder;
	DELIMITER $$
	CREATE TRIGGER deleteOrder DELETE ON `orders` FOR EACH ROW
	BEGIN
		UPDATE goods SET number=number+OLD.sal_count WHERE id=OLD.goods_id;
	END $$
	DELIMITER ;
	```

- 每一个订单购买数量的更新都意味着商品数量的变动

```sql
DROP TRIGGER IF EXISTS updateOrder;
DELIMITER $$
CREATE TRIGGER updateOrder MODIFY ON `orders` FOR EACH ROW
BEGIN
	DECLARE diffNum INT(11) DEFAULT 0;
	SET diffNum=NEW.sal_count-OLD.sal_count;
	UPDATE goods SET number=number+diffNum WHERE id=OLD.goods_id;
END $$
DELIMITER ;
```

## 视图

> 视图（View）是一张虚拟表，本身不存数据，对视图使用SQL操作时本质是对其他表操作

### 语法

```sql
--创建视图
CREATE VIEW 视图名称 AS SELECT 字段名1,字段名2,字段名3 FROM 表名1,表名2 WHERE 条件;
--创建或更新更新视图
CREATE OR REPLACE VIEW 视图名称 AS SELECT 字段名1,字段名2,字段名3 FROM 表名1,表名2 WHERE 条件;
--删除视图
DROP VIEW [IF EIXSTS] 视图名;
```

### 使用场景

- 定制用户数据，聚焦特定的数据：例如，如果频繁获取销售人员编号、姓名和代理商名称，可以创建视图

	```sql
	-- 删除视图
	DROP VIEW IF EXISTS salesInfo;
	-- 创建或者更新视图
	CREATE OR REPLACE VIEW salesInfo AS
	SELECT
		a.id,
		a.`name` saleName,
		b.`name` agentName
	FROM
		sales a,
		agent b
	WHERE
		a.agent_id = b.id;
	```

- 简化数据操作：例如，使用联表查询时，涉及到的表较多，SQL语句较长，可以使用查询视图代替联表查询

	```sql
	DROP VIEW IF EXISTS searchOrderDetail;
	CREATE OR REPLACE VIEW searchOrderDetail AS
	SELECT
		a.id regionId,
		a.`name` regionName,
		b.id agentId,
		b.`name` agentName,
		c.id saleId,
		c.`name` saleName,
		d.sale_count saleCount,
		d.created_time createdTime,
		e.`name` goodsName
	FROM
		region a,
		agent b,
		sales c,
		`order` d,
		goods e
	WHERE
		a.id = b.region_id
		AND b.id = c.agent_id
		AND c.id = d.sales_id
		AND d.goods_id = e.id;
	```

- 提高安全性能：例如，用户密码属于隐私数据，用户不能直接查看密码。可以使用视图过滤掉这一字段

```sql
DROP VIEW IF EXISTS userInfo;
CREATE OR REPLACE VIEW userInfo AS
SELECT
	username,
	salt,
	failure_times,
	last_log_time
FROM
	`user`;
```

**注意**：视图不能提升查询速度，只是为了方便业务开发，但同时加大了数据库服务器压力，需要合理使用视图

# 数据库设计

## 设计数据库

- 实体：软件开发中设计到的事物，通常是一类数据对象的个体
- 数据库设计：将实体和实体之间的关系进行规划和结构化的过程
- 数据库设计理由：如果数据库的设计不当，会造成数据冗余、修改复杂、操作数据异常等问题；而好的数据库设计，则可以减少不必要的数据冗余，通过合理的数据规划提高系统的性能

设计数据库过程：
1. 收集信息
2. 标识实体：实体一般是名词，每个实体只描述一件事情，不能出现含义相同的实体
3. 标识实体的详细属性
4. 标识实体之间的关系

## ER图

> ER图（Entity Relation）即实体之间的关系图

![[绘制ER图.jpg]]

![[ER图实例.jpg]]

## 数据库模型图

- 关系模式：实体关系的描述

![[关系模式.jpg]]

## 数据库三大范式

注意：在实际开发中，为了满足性能的需要，数据库设计可能会打破三大范式的约束，比如：

以空间换时间：当数据库中存储的数据越来越多，查询效率下降，为了提高查询效率，可能会在表中增加新字段，不再满足三大范式

### 第一范式

最基本的范式，确保每列保持原子性，即**每列不可再分**

![[第一范式.jpg]]

### 第二范式

在第一范式的基础上，每张表的**属性完全依赖于主键**，每张表只描述一件事情

![[第二范式.jpg]]

### 第三范式

在第二范式的基础上，确保**每列都直接依赖于主键**，而不是间接依赖，不能存在依赖传递

![[第三范式.jpg]]

# C的mysql接口

linux安装接口库：
- CentOS：`yum install mysql-devel`
- Ubuntu：`apt-get install libmysqlclient-dev`

编译时需要链接`-lmysqlclient`

头文件：`<mysql/mysql.h>`

- `MYSQL mysql`：定义操作数据库的句柄
- `MYSQL *mysql_init(MYSQL *mysql)`：初始化，失败返回nullptr
	- 参数：数据库句柄地址，若mysql为空，分配并初始化，否则只初始化
	- 返回值：失败返回`nullptr`
- `MYSQL* mysql_real_connect(MYSQL* myql,const char* host,const char* usr,const char* passwd,const char* db,unsigned int port,const char* unix_socket,unsigned long client_flag)`：连接数据库服务器
	- 参数：
		- 数据库句柄
		- 主机ip
		- mysql用户名
		- mysql密码
		- 要使用的数据库名
		- 主机端口号
		- 域套接字，不指定为nullptr
		- 通常为0
	- 返回值：失败返回nullptr
- `int mysql_query(MYSQL *mysql, const char *query)`：执行sql语句
	- 参数：
		- 数据库句柄
		- 要执行的sql语句
	- 返回值：成功返回0，失败返回非0值
- `MYSQL_RES* mysql_store_result(MYSQL *mysql)`：获取结果集
	- 参数：数据库句柄
	- 返回值：`MYSQL_RES`类型的结果集，失败返回nullptr
- `unsigned int mysql_num_fields(MYSQL_RES *result)`：获取列数
- `unsigned int mysql_num_rows(MYSQL_RES *result)`：获取行数
- `MYSQL_FIELD *mysql_fetch_fields(MYSQL_RES *result)`：获取列
- `MYSQL_ROW mysql_fetch_row(MYSQL_RES *result)`：获取一行，通过下标`row[0]`获取一行中的某一列
- `void mysql_free_result(MYSQL_RES *result)`：释放结果集资源
- `void mysql_close(MYSQL *mysql);`：关闭数据库
- `const char *mysql_error(MYSQL *mysql)`：返回错误信息
- `unsigned int mysql_errno(MYSQL *mysql)`：返回错误码

```C title:"实例"
#include <stdio.h> 
#include <mysql.h> // mysql 文件，如果配置ok就可以直接包含这个文件

int main(void) {
    MYSQL* mysql=nullptr; //数据库句柄

    //初始化数据库 
    mysql=mysql_init(mysql);
    
    //设置字符编码
    mysql_options(mysql, MYSQL_SET_CHARSET_NAME, "gbk");
    
    //连接数据库
    mysql=mysql_real_connect(mysql, "127.0.0.1", "root","password", "database_name", 3306, NULL, 0) == NULL) {
	if(!mysql){
		//连接失败
	}


    //查询数据
    int ret = mysql_query(mysql, "select * from student;");
    //student是自己在数据库中所建的表名
    printf("ret: %d\n", ret);
    
    MYSQL_RES* res; //查询结果集 
    MYSQL_ROW row; //记录结构体
    //获取结果集
    res = mysql_store_result(mysql);
    
    //给 ROW 赋值，判断 ROW 是否为空，不为空就打印数据。
    while (row = mysql_fetch_row(res)) {
        printf("%s ", row[0]); //打印 ID
        printf("%s ", row[1]); //打印姓名
        printf("%s ", row[2]); //打印班级
        printf("%s \n", row[3]);//打印性别
    }
    
    //释放结果集 
    mysql_free_result(res); 
    
    //关闭数据库
    mysql_close(mysql);
    system("pause");
    return 0;
}
```