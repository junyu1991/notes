# Spring 部分注解作用解释

### 1 @ConditionOnXXX

条件装配，@ConditionOnXXX用于不同场景下的Bean装配。可用于类或者方法上：
1. 作用于类上，需要和@Configuration注解一起使用，决定该配置类是否生效
2. 作用于方法上，需要和@Bean注解一起使用，判断该Bean是否生成

> 转载自：[https://www.cnblogs.com/ashleyboy/p/9425179.html][https://www.cnblogs.com/ashleyboy/p/9425179.html]

#### 1.1 Bean条件装配

Spring Boot可通过有没有指定Bean来决定是否配置当前Bean，如：
使用@ConditionOnBean(BeanClass.class)，只有当当前上下文中存在BeanClass Bean对象时才实例化当前Bean
使用@ConditionOnMissingBean(BeanClass.class),只有当当前上下文中不存在BeanClass Bean对象时才实例化当前Bean
例：
``` java
@Configuration
@ConditionalOnBean(PropertiesConfig.class)
public class TestConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public  EncodingConvert createUTF8EncodingConvert(){
        return  new UTF8EncodingConvert();
    }

    @Bean
    public  EncodingConvert createGBKEncodingConvert(){
        return  new GBKEncodingConvert();
    }
}
```
TestConfiguration配置生效的前提是当前上下文中已经配置了PropertiesConfig。
如果当前上下文中没有UTF8EncodingConvert类型Bean，则调用createUTF8EncodingConvert创建。

#### 1.2 Class条件装配

Class条件装配是按照某个类是否在Classpath中来判断是否需要配置Bean。
@ConditionalOnClass：表示classpath有指定的类时，配置才生效
@ConditionalOnMissingClass：表示当classpath中没有指定类，则配置生效
例:
``` java
@Configuration
@ConditionalOnClass(JestClient.class)
//@ConditionalOnClass(name="com.sl.springbootdemo.JestClient")
public  class JestAutoConfiguration{
}
```

#### 1.3 Environment装配

Spring Boot可以根据Environment属性来决定是否实例化Bean，通过@ConditionalOnProperty注解来实现。
根据注解属性name读取Spring Boot的Environment的变量包含的属性 ，再根据属性值与注解属性havingValue的值比较，
判断否实例化Bean，如果没有指定注解属性havingValue，name只要environment属性值不为false，都会实例化Bean。
MatchIfMissing=true，表示如果evironment没有包含message.center.enavled属性,也会实例化Bean，默认是false。
例：
``` java
@Bean
@ConditionalOnProperty(name="com.sl.Encoding",havingValue = "GBK",matchIfMissing = false)
public  EncodingConvert createGBKEncodingConvert(){
    return  new GBKEncodingConvert();
}
```
其他条件装配注解：
@ConditionalOnExpression ：当表达式为true时，才会实例化一个Bean，支持SpEL表达式
@ConditionalOnNotWebApplication：表示不是web应用，才会实例化一个Bean

#### 1.4 Condition接口（自定义条件装配）
当Spring Boot提供的一些列@ConditionalOnXXX注解无法满足需求时，也可以手动构造一个Condition实现，
使用注解@Conditional来引用Condition实现。
Condition接口定义：
``` java
@FunctionalInterface
public interface Condition {
   /**
    * Determine if the condition matches.
    * @param context the condition context
    * @param metadata metadata of the {@link org.springframework.core.type.AnnotationMetadata class}
    * or {@link org.springframework.core.type.MethodMetadata method} being checked
    * @return {@code true} if the condition matches and the component can be registered,
    * or {@code false} to veto the annotated component's registration
    */
   boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata);
}
```
参数ConditionContext类可以获取用于帮助条件判断的辅助类：
1.Environment:读取系统属性、环境变量、配置参数等。
2.ResourceLoader:加载判断资源文件
3.ConfigurableListableBeanFactory:Srping容器
自定义condition示例：
``` java
public class GBKCondition implements Condition {
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata){
        String encoding = context.getEnvironment().getProperty("file.encoding");

        if("gbk".equals(encoding.toLowerCase())){
            return  true;
        }
        return  false;
     }
}
```
使用：
``` java
@Bean
@Conditional(GBKCondition.class) //使用自定义Condition
public  EncodingConvert createGBKEncodingConvert(){
    return  new GBKEncodingConvert();
}
```