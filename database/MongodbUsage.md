# MongoDBʹ��

## Java��ʹ��MongoDB

#### Spring-data��ʽ

�ٷ��ĵ���ַ��[Documentation](https://docs.spring.io/spring-data/mongodb/docs/current/reference/html/)

1. ����maven��������pom�ļ������```<dependencyManagement \>```�������```<dependency/>```
``` xml
<dependencies>
  <dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-mongodb</artifactId>
	<!-- ���Ҫʹ�����������ݿ����޸�spring-data-mongodbΪָ�����ݿ⣬��:spring-data-redis -->
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
spring-data-releasetrain�汾���ͣ�
- BUILD-SNAPSHOT: ��ǰ���հ汾
- M1��M2�ȣ�
- RC1��RC2�ȣ���ѡ������
- RELEASE�� GA������
- SR1, SR2�ȣ� ���񷢲���
�����Ҫ������Ŀʹ�õ�spring-data-jpa�汾��ֻ��Ҫ����spring-data-releasetrain�İ汾���ɡ�
