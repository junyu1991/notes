# Spring Cloud

Spring cloud与Spring boot版本对应关系

| Spring Boot | Spring Cloud |
| :--: | :--: |
| 1.2.x | Angel |
| 1.3.x | Brixton |
| 1.4.x stripes | Camden |
| 1.5.x | Dalston,Edgware |
| 2.0.x | Finchley |

详细版本


| spring-boot-starter-parent | spring-cloud-dependencies |
| :--: | :--: |
|  |  |

| 版本号 | 发布日期 |  | 版本号 | 发布日期 |  |
| :--: | :--: | :--: | :--: | :--: | :--:|
| 1.5.2.RELEASE | 2017.01 | 稳定版 | Dalston.RC1 | 2017 |  |
| 1.5.9.RELEASE | 2017.11 | 稳定版 | Edgware.RELEASE | 2017.11 | 稳定版 |
| 1.5.16.RELEASE |  |  | Edgware.SR5 | 2017 |  |
| 1.5.20.RELEASE |  |  | Edgware.SR5 | 2017 |  |
| 2.0.2.RELEASE | 2018.05 |  | Finchley.BUILD-SNAPSHOT | 2018 |  |
| 2.0.6.RELEASE | 2018 |  | Finchley.SR2 |  |  |
| 2.1.4.RELEASE |  |  | Greenwich.SR1 |  |  |

## Eureka

> Eureka 2.0现已停止更新，酌情选用

1. Eureka Server:注册中心，包含有一个注册表，用于保存各个服务的信息：所在机器以及端口号。同类型的还有Consul,Zookeeper。
2. Eureka Client:负责将当前服务信息注册到Eureka Server中。

## Feign

Spring Cloud Feign是用于简化Web服务调用的客户端，基于Netflix Feign实现。

## Ribbon

Spring Cloud Ribbon是基于Netflix Ribbon实现的客户端负载均衡的工具。服务间发起请求时，从一个服务的多台机器中选择一台。

## Hystrix

Spring Cloud Hystrix主要提供服务熔断（调用的服务未在规定时间内返回结果，直接就返回先前制定的结果），服务降级功能。

## Zuul

Spring Cloud Zuul主要负责网络路由。如果前端，移动端要调用后端系统，统一从Zuul网关进入，由Zuul网关转发请求给对应的服务。


# Spring Cloud Zookeeper

