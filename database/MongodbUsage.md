# MongoDB使用

## Java中使用MongoDB

#### Spring-data方式

官方文档地址：[Documentation](https://docs.spring.io/spring-data/mongodb/docs/current/reference/html/)

1. 申明maven依赖，向pom文件中添加```<dependencyManagement \>```，再添加```<dependency/>```
``` xml
<dependencies>
  <dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-mongodb</artifactId>
	<!-- 如果要使用其他的数据库则修改spring-data-mongodb为指定数据库，如:spring-data-redis -->
  </dependency>
<dependencies>
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.data</groupId>
      <artifactId>spring-data-releasetrain</artifactId>
      <version>Lovelace-SR10</version>
      <scope>import</scope>
      <type>pom</type>
    </dependency>
  </dependencies>
</dependencyManagement>
```
spring-data-releasetrain版本解释：
- BUILD-SNAPSHOT: 当前快照版本
- M1，M2等：
- RC1，RC2等：候选发布版
- RELEASE： GA发布版
- SR1, SR2等： 服务发布版
如果想要升级项目使用的spring-data-jpa版本，只需要升级spring-data-releasetrain的版本即可。
