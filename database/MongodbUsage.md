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


#### MongoDB����

1. ����
������Ҫʹ��MongoTemplate.insert()����insertALL()������
- void insert (Object objectToSave):��������뵽Ĭ��collection�У�Ĭ��collectionֵȡֵ���ȡ���ڲ�������Ƿ�ʹ��@Documentע�⣬��ʹ���˸�ע�⣬��Ĭ��collectionΪ��ע��ֵ������Ϊ���������������Сд����com.example.Movie��Ӧ��collectionΪmovie��
- void insert (Object objectToSave, String collectionName):�������ָ��collection�С�
insert�ɲ���Collection�������ڲ����������ڲ���ʱ����ݲ���Ķ���ѡ��**_id**ֵ����������������ʹ��```@Id(org.springframework.data.annotation.Id)```
ע���ֵ����ֵ���ͱ���Ϊ��**String**,**ObjectId**����**BigInteger**�����Ը�ֵΪ**_id**��ֵ������ֱ��ʹ��mongodb���ɵ�Ψһidֵ��Ϊ_idֵ��ʹ��insert()/insertAll()��������Ĭ�ϸ�����������**class**���ԣ�
����ֵĬ��Ϊ�����������Ϣ����:**com.example.Movie**����ͨ���ڲ��������������ʹ��@TypeAlias("classValue")�����Զ��壬��Ӹ�ֵ��Ҫ������findbyClass()������
����Ҫɾ����ֵ�����ͨ���Զ���MongoTypeMapper����ʹ��null��ʼ��DefaultMongoTypeMapper�ķ���ʵ�֣�ʵ��ʵ�����£�
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
		
		//ʹ��null��ʼ��DefaultMongoTypeMapper���ɲ����classֵ�����������
        mappingMongoConverter.setTypeMapper(new DefaultMongoTypeMapper(null));
        mongoTemplate = new MongoTemplate(new SimpleMongoDbFactory(mongoClient(), this.getDatabaseName()), mappingMongoConverter);
        return mongoTemplate;
    }

    protected String getDatabaseName() {
        return this.database;
    }
}
```

ִ�в������ʱ����_idֵ��ͬ������ʧ�ܡ�

2. ����
���淽����Ҫ��save()��**save()��insert()��ͬ�����ڣ�����������������ͬ��_idʱ��save()�����Ḳ�����еĶ���**
- void save (Object objectToSave): �����󱣴浽Ĭ��collection�С�
- void save (Object objectToSave, String collectionName): �����󱣴浽ָ��collection�С�

3. ����
���·���������
- **updateFirst**�����µ�һ�����ϲ�ѯ������ĵ���
- **updateMulti**���������з��ϲ�ѯ������ĵ���

> updateFirst��֧��������Ҫʹ�������ʹ��**findAndModify**������

4. ���Ҳ�����
��Ҫ����ΪfindAndModify()������ɸѡ���������ĵ���
``` java
<T> T findAndModify(Query query, Update update, Class<T> entityClass);
<T> T findAndModify(Query query, Update update, Class<T> entityClass, String collectionName);
<T> T findAndModify(Query query, Update update, FindAndModifyOptions options, Class<T> entityClass);
<T> T findAndModify(Query query, Update update, FindAndModifyOptions options, Class<T> entityClass, String collectionName);
```
ʹ��ʾ����
``` java
public FileInfo findAndModifyFileInfo(Map<String, Object> updateParam, Map<String, Object> filter) {
    Update update = this.makeUpdate(updateParam);
	Query query = this.makeQuery(filter);
	FindAndModifyOptions findAndModifyOptions = FindAndModifyOptions.options();
    //ʹ��findAndModifyOptions.returnNew(true)ʹ���صĽ��Ϊ���º�Ľ��
    FileInfo file = this.getMongoTemplate().findAndModify(query, update, findAndModifyOptions.returnNew(true), FileInfo.class, "file");
    return file;
}
```

5. ���Ҳ��滻
��Ҫ����ΪfindAndReplace(),���ҷ����������ĵ����������ĵ��滻Ϊ�����͵��ĵ�
ʹ��ʾ����
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
> ʹ������������������ĵ�ʱ���µ������в��ܰ�����id����Ϊ��ô����ʹ���µ�idֵ���Ǿɵ�idֵ��findAndReplace()ֻ���滻��һ������������ֵ��ȡ����ʹ�õ����򷽷���

5. ���Ҳ�ɾ��
ɾ��������Ҫ������remove(), findAllAndRemove()
ʹ��ʾ����
``` java
	/** 
     * ɾ��ָ��fileInfo����Ҫ����FileInfo�е�_id����������ѯɾ��
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
     * ��collectionName����������ɾ������ɸѡ��������������
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
     * ��collectionName����������ɾ������ɸѡ��������������
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