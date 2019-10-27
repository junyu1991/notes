# MongoDB使用

## Spring-data方式

> 官方文档地址：[Documentation](https://docs.spring.io/spring-data/mongodb/docs/current/reference/html/)

#### 一 添加Maven依赖包

向pom文件中添加```<dependencyManagement \>```，再添加```<dependency/>```
``` xml
<dependencies>
  <dependency>
    <groupId>org.springframework.data</groupId>
    <artifactId>spring-data-mongodb</artifactId>
	<!-- 如果要使用其他的数据库则修改spring-data-mongodb为指定数据库，如:spring-data-redis -->
  </dependency>
</dependencies>
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

#### 二 连接MongoDB(初始化MongoDB Client客户端)

1. 初始化MongoClient
```com.mongodb.MongoClient```是MongoDB驱动程序API的入口点，所有其他的接口都会依靠该接口。
MongoClient初始化主要需要Server host以及port，某些配置了用户名以及用户密码的MongoDB Server还需设置用户名密码，若Server
端使用的是集群模式，初始化MongoClient时则需要传入MongoDB Server端的所有host以及端口。

初始化MongoClient可使用Java代码初始化，也可使用Spring XML进行配置初始化

Java初始化代码：
``` java
	/**
     * 只是用host以及port初始化MongoClient
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link com.mongodb.MongoClient}
     * @exception:
    */
    @Bean("simpleMongoClient")
    public MongoClient simpleMongoClient() {
        return new MongoClient(host, port);
    }

    /**
     * 使用集群MongoDB server初始化MongoClient，Spring会扫描所有的MongoDB Server节点，获取集群信息
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link com.mongodb.MongoClient}
     * @exception:
    */
    @Bean("mongoClientWithReplicat")
    public MongoClient mongoClientWithReplicat() {
        MongoClient mongoClient = new MongoClient(getAllServerAddress());
        return mongoClient;
    }

    /**
     * 将配置文件中的MongoDB Server连接方式(host:port)转换成ServerAddress列表
     * 配置文件中的配置示例： 192.168.0.102:21017, 192.168.0.107:21017
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link java.util.List<com.mongodb.ServerAddress>}
     * @exception:
    */
    private List<ServerAddress> getAllServerAddress() {
        List<String> strings = Arrays.asList(hosts);
        List<ServerAddress> serverAddresses = new ArrayList<>();
        for(String host : strings) {
            String[] split = host.split(":");
            if(split.length == 2) {
                serverAddresses.add(new ServerAddress(split[0], Integer.parseInt(split[1])));
            }
        }
        return serverAddresses;
    }

    /**
     * 使用MongoClientOptions以及MongoCredential(用于配置用户名以及密码相关项目)初始化MongoClient
     * 若MongoDB Server是集群模式，则初始化MongoClient时传入<code>List<ServerAddress></code>即可
     * @author: yujun
     * @date: 2019/10/14
     * @description: TODO
     * @param
     * @return: {@link MongoClient}
     * @exception:
    */
    @Bean(name = "mongoClient")
    public MongoClient mongoClient() {
        MongoClientOptions mongoClientOptions = mongoClientOptions();
        ServerAddress serverAddress = new ServerAddress(host, port);
        MongoCredential mongoCredential = MongoCredential.createCredential(userName, userDb, password.toCharArray());
        //return new MongoClient(getAllServerAddress(), mongoCredential, mongoClientOptions); //使用List<ServerAddress>初始化即可使用Mongo集群
        return new MongoClient(serverAddress, mongoCredential, mongoClientOptions);
    }
```
完成代码示例：[Connector.java](https://github.com/junyu1991/database/blob/master/MongoDB/src/main/java/com/yujun/database/mongodb/Connector.java)
[XML示例](https://github.com/junyu1991/database/blob/master/MongoDB/src/main/resources/spring-mongo.xml)

2. MongoDbFactory
```com.mongodb.MongoClient```是MongoDB驱动程序API的入口点，但如果需要对mongodb 数据库进行操作，还需要其他的信息，如：数据库名，
用户名以及密码(用户名以及密码可在初始化MongoClient时设置)，通过以上信息，就可获得```com.mongodb.client.MongoDatabase```对象，
可使用该对象进行collection相关操作，如：创建，查询，删除。Spring提供了```org.springframework.data.mongodb.core.MongoDbFactory```
接口来进行MongoDbFactory管理。

MongoDbFactory初始化标准代码：
``` java
	/**
     * 初始化MongoDbFactory
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link org.springframework.data.mongodb.MongoDbFactory}
     * @exception:
    */
    @Bean(name = "mongoDbFactory")
    public MongoDbFactory mongoDbFactory() {
        SimpleMongoDbFactory simpleMongoDbFactory = new SimpleMongoDbFactory(mongoClient(), database);
        MongoDatabase db = simpleMongoDbFactory.getDb();//可获取MongoDatabase对象
        return simpleMongoDbFactory;
    }
```

3. MongoTemplate
```org.springframework.data.mongodb.core.MongoTemplate```是提供MongoDB增删改查方法主要类。
MongoTemplate可使用MongoDbFactory初始化，同时还可指定MappingMongoConverter；也可直接使用MongoClient以及数据库名初始化。

初始化代码：
``` java
	/**
     * 使用mongoClient以及数据库名初始化MongoTemplate
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link org.springframework.data.mongodb.core.MongoTemplate}
     * @exception:
    */
    public MongoTemplate simpleMongoTemplate() {
        return new MongoTemplate(mongoClient(), database);
    }
    
    /**
     * 使用MongoDbFactory初始化MongoTemplate
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link org.springframework.data.mongodb.core.MongoTemplate}
     * @exception:
    */
    @Bean(name = "mongoTemplate")
    public MongoTemplate mongoTemplate() throws Exception {
        MongoTemplate mongoTemplate = new MongoTemplate(mongoDbFactory());
    /*    MappingMongoConverter mappingMongoConverter = super.mappingMongoConverter();
        mappingMongoConverter.setTypeMapper(new DefaultMongoTypeMapper(null));
        mongoTemplate = new MongoTemplate(mongoDbFactory(), mappingMongoConverter);*/
        return mongoTemplate;
    }

    /**
     * 使用MongoDbFactory以及MappingMongoConverter初始化MongoTemplate
     * @author: yujun
     * @date: 2019/10/24
     * @param
     * @return: {@link org.springframework.data.mongodb.core.MongoTemplate}
     * @exception:
    */
    @Bean(name = "geoMongoTemplate")
    public MongoTemplate geoMongoTemplate() throws Exception {
        MongoTemplate mongoTemplate = null;
        MappingMongoConverter mappingMongoConverter = super.mappingMongoConverter();
        mappingMongoConverter.setTypeMapper(new DefaultMongoTypeMapper(null));
        mongoTemplate = new MongoTemplate(new SimpleMongoDbFactory(mongoClient(), geoDatabase), mappingMongoConverter);
        return mongoTemplate;
    }
```

关于MongoDB文档与实体类之间的映射，Spring使用的是```MongoConverter```接口的实现类，Spring提供了```MappingMongoConverter```(MongoTemplate默认使用的映射类)类。
如果有需求，可自行实现```MongoConverter```接口。

#### 三 进行MongoDB增删改查操作

1. 插入
插入主要使用MongoTemplate.insert()或者insertALL()方法，
- void insert (Object objectToSave):将对象插入到默认collection中，默认collection值取值情况取决于插入对象是否使用@Document注解，若使用了该注解，则默认collection为该注解值，否则为插入对象类类名的小写，如com.example.Movie对应的collection为movie。
- void insert (Object objectToSave, String collectionName):插入对象到指定collection中。
insert可插入Collection对象，用于插入多个对象。在插入时会根据插入的对象选择**_id**值，如果插入对象中有使用```@Id(org.springframework.data.annotation.Id)```
注解的值，该值类型必须为：**String**,**ObjectId**或者**BigInteger**，则以该值为**_id**的值，否则直接使用mongodb生成的唯一id值作为_id值。使用insert()/insertAll()方法，会默认给插入对象添加**class**属性，
属性值默认为插入对象类信息，如:**com.example.Movie**，可通过在插入对象类声明中使用@TypeAlias("classValue")进行自定义，添加该值主要方便于findbyClass()方法。
若需要删除该值，则可通过自定义MongoTypeMapper或者使用null初始化DefaultMongoTypeMapper的方法实现，实现实例如下：
``` java
@Configuration
public class SampleMongoConfiguration extends AbstractMongoConfiguration {
    
    private String host = "127.0.0.1";
   
    private int port = 27017;
    
    private String database = "test";

    @Bean(name = "mongoClient")
    public MongoClient mongoClient() {
		return new MongoClient(host, port);
    }
 
    @Bean(name = "mongoTemplate")
    public MongoTemplate mongoTemplate() throws Exception {
        MongoTemplate mongoTemplate = new MongoTemplate(mongoClient(), this.getDatabaseName());
        mongoTemplate = new MongoTemplate(new SimpleMongoDbFactory(mongoClient(), this.getDatabaseName()));
        MappingMongoConverter mappingMongoConverter = super.mappingMongoConverter();
		
		//使用null初始化DefaultMongoTypeMapper即可不添加class值到插入对象中
        mappingMongoConverter.setTypeMapper(new DefaultMongoTypeMapper(null));
        mongoTemplate = new MongoTemplate(new SimpleMongoDbFactory(mongoClient(), this.getDatabaseName()), mappingMongoConverter);
        return mongoTemplate;
    }

    protected String getDatabaseName() {
        return this.database;
    }
}
```

执行插入操作时，若_id值相同则会插入失败。

2. 保存
保存方法主要是save()，**save()与insert()不同点在于，当操作的数据有相同的_id时，save()操作会覆盖已有的对象**
- void save (Object objectToSave): 将对象保存到默认collection中。
- void save (Object objectToSave, String collectionName): 将对象保存到指定collection中。

3. 更新
更新方法包括：
- **updateFirst**：更新第一个符合查询结果的文档。
- **updateMulti**：更新所有符合查询结果的文档。

> updateFirst不支持排序，需要使用排序的使用**findAndModify**方法。

4. 查找并更新
主要方法为findAndModify()，根据筛选条件更新文档。
``` java
<T> T findAndModify(Query query, Update update, Class<T> entityClass);
<T> T findAndModify(Query query, Update update, Class<T> entityClass, String collectionName);
<T> T findAndModify(Query query, Update update, FindAndModifyOptions options, Class<T> entityClass);
<T> T findAndModify(Query query, Update update, FindAndModifyOptions options, Class<T> entityClass, String collectionName);
```
使用示例：
``` java
public FileInfo findAndModifyFileInfo(Map<String, Object> updateParam, Map<String, Object> filter) {
    Update update = this.makeUpdate(updateParam);
	Query query = this.makeQuery(filter);
	FindAndModifyOptions findAndModifyOptions = FindAndModifyOptions.options();
    //使用findAndModifyOptions.returnNew(true)使返回的结果为更新后的结果
    FileInfo file = this.getMongoTemplate().findAndModify(query, update, findAndModifyOptions.returnNew(true), FileInfo.class, "file");
    return file;
}
```

5. 查找并替换
主要方法为findAndReplace(),查找符合条件的文档，并将旧文档替换为新类型的文档
使用示例：
``` java
public VideoInfo findAndReplace(VideoInfo videoInfo, Map<String, Object> filter) {
    Query query = this.makeQuery(filter);
    Optional<VideoInfo> andReplace = this.getMongoTemplate().update(FileInfo.class)
            .matching(query).replaceWith(videoInfo)
            .withOptions(FindAndReplaceOptions.options().upsert())
            .withOptions(FindAndReplaceOptions.options().returnNew())
            .as(VideoInfo.class)
            .findAndReplace();
    return andReplace.get();
}
```
> 使用新类型替代就类型文档时，新的数据中不能包含有id，因为这么做会使用新的id值覆盖旧的id值。findAndReplace()只会替换第一个符合条件的值。取决于使用的排序方法。

5. 查找并删除
删除方法主要包括：remove(), findAllAndRemove()
使用示例：
``` java
	/** 
     * 删除指定fileInfo，主要根据FileInfo中的_id（主键）查询删除
     * @author: yujun
     * @date: 2019/10/16
     * @description: TODO 
     * @param fileInfo
     * @return: 
     * @exception: 
    */
    public void removeFileInfo(FileInfo fileInfo) {
        this.getMongoTemplate().remove(fileInfo);
    }

	/**
     * 从collectionName集合中批量删除符合筛选条件的所有数据
     * @author: yujun
     * @date: 2019/10/16
     * @description: TODO
     * @param filter
     * @param collectionName
     * @return:
     * @exception:
    */
    public void removeFileInfo(Map<String, Object> filter, String collectionName) {
        Query query = this.makeQuery(filter);
        this.getMongoTemplate().remove(query, collectionName);
    }

    /**
     * 从collectionName集合中逐条删除符合筛选条件的所有数据
     * @author: yujun
     * @date: 2019/10/16
     * @description: TODO
     * @param filter
     * @param collectionName
     * @return:
     * @exception:
    */
    public void removeFileInfoOneByOne(Map<String, Object> filter, String collectionName) {
        Query query = this.makeQuery(filter);
        this.getMongoTemplate().findAllAndRemove(query, collectionName);
    }
```

6. 查询操作

查询的方法主要包括：
- findAll: 从集合中查询所有同一类型的文档列表。
- findOne: 从集合中查找符合条件的第一个文档
- findById: 按照_id值查找文档
- find: 从集合中查找符合筛选条件的文档列表
- findAndRemove: 从集合中查找符合条件的文档从中删除第一个文档并返回被删除的文档。
查询主要使用**Query**，**Query**使用**Criteria**进行查询条件的组装。使用Query的limit(int limit)方法限制查询条数，
使用with(Sort sort)进行排序查询，使用with(Pageable pageable)进行分页查询，Pageable也可进行排序。
使用示例如下：
``` java
/**
 * 按照条件分页查询
 * @author: admin
 * @date: 2019/10/17
 * @param pageSize
 * @param pageNo
 * @param filename
 * @param orderFiled
 * @return: {@link List< FileInfo>}
 * @exception:
*/
public List<FileInfo> queryPageFileInfo(int pageSize, int pageNo, String filename, String orderFiled) {
    Query query = new Query();
    Criteria criteria = Criteria.where("filename").regex(filename);
    query.addCriteria(criteria);
    Pageable pageable = new QueryPage(pageNo, pageSize, Sort.by(orderFiled));
    query.with(pageable);
    return this.getMongoTemplate().find(query, FileInfo.class, "file_collection");
}
/**
 * 查询size个FileInfo
 * @author: yujun
 * @date: 2019/10/17
 * @description: TODO
 * @param size
 * @return: {@link List< FileInfo>}
 * @exception:
*/
public List<FileInfo> queryFileInfo(int size, long fileSize, String filename, String orderFiled) {
    Query query = new Query();
    Criteria criteria = Criteria.where("fileSize").lt(fileSize);
    criteria.andOperator(criteria.where("filename").regex(filename));
    query.addCriteria(criteria);
    query.limit(size);
    query.with(Sort.by(orderFiled, "filename"));
    return this.getMongoTemplate().find(query, FileInfo.class, "file_collection");
}
```

7. 查询不同的值
使用distinct("filedName")可从符合查询条件的结果中查询filedName不同的文档，返回结果为filedName的列表。
使用示例：
``` java
/**
 * 查询相同文件大小的不同文件信息，使用filename区分
 * @author: admin
 * @date: 2019/10/17
 * @param fileSize
 * @return: {@link List< String>}
 * @exception:
*/
public List<String> queryFileInfoByFileSize(long fileSize) {
    Query query = Query.query(Criteria.where("fileSize").is(fileSize));
    List<FileInfo> filename = null;
    try {
        filename = this.getMongoTemplate().query(FileInfo.class).inCollection("file_collection").distinct("filePath").matching(query).as(FileInfo.class).all();
    } catch (DataAccessException e) {
        log.error("Get result failed.", e);
    }
    return filename;
}
```
使用as(Class clazz)可指定查询结果的类类型。all()方法用于返回所有符合条件的结果，该方法会抛出**DataAccessException**异常。

8. 地理空间查询
MongoDB支持地理空间查询，主要支持图形包括：圆，方框，以及点。查询的方法包括：$near, $within, geoWithin, 以及 $nearSphere。
[使用示例代码](https://github.com/junyu1991/database/blob/master/MongoDB/src/main/java/com/yujun/database/mongodb/geo/GeoQuery.java)

9. 文本搜索
MongoDB支持文本搜索，需要使用文本搜索时，先创建被搜索字段的索引，并设置搜索字段的权重。
[Java使用示例代码](https://github.com/junyu1991/database/blob/master/MongoDB/src/main/java/com/yujun/database/mongodb/text/TextSearch.java)

10. 归类(根据语言归类，如：英语，中文，法语等)
MongoDB 3.4之后就支持了用于收集和索引创建以及各种查询操作的归类。
``` java
Collation collation = Collation.of("fr")         
  .strength(ComparisonLevel.secondary()          
  .includeCase())
  .numericOrderingEnabled()                      
  .alternate(Alternate.shifted().punct())        
  .forwardDiacriticSort()                        
  .normalizationEnabled();   
```

11. Json协议
MongoDB 3.6之后就支持了Json协议，可在创建collection使用Json协议来规定保存在该collection下的文档的格式等信息。如：
``` json
{
  "type": "object",                                                        
  "required": [ "firstname", "lastname" ],                                 
  "properties": {                                                          
    "firstname": {                                                         
      "type": "string",
      "enum": [ "luke", "han" ]
    },
    "address": {                                                           
      "type": "object",
      "properties": {
        "postCode": { "type": "string", "minLength": 4, "maxLength": 5 }
      }
    }
  }
}
```
使用Java代码构建以上json协议为：
``` java
MongoJsonSchema.builder().

```
12. 
12. 