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


#### MongoDB方法

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