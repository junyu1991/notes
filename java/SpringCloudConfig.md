# Spring cloud config使用加密配置(RSA非对称加密)

## 1 使用keytool生成密钥文件

``` sh
keytool -genkeypair -alias config-server -keyalg RSA \ 
  -dname "CN=yj, OU=company, O=organization, L=city, ST=province, C=china" \
  -keypass 222222 \
  -keystore config-server.keystore \
  -storepass 111111 \
  -validity 365 \
```

## 2 配置config-server项目使用步骤1中的密钥文件

在config-server项目中的bootstrap.yml或者bootstrap.propertis文件中添加密钥文件配置：
``` yml
encrypt:
  key-store:
    location: file:///E:\\code\\eclipse\\cipher\\config-server.keystore
    alias: config-server
    password: config
	#password  keystore的密码
    secret: config
	#secret key的密码
```
> 密钥文件的配置必须放在bootstrap.yml或者bootstrap.propertis文件中

## 3 测试生成密文

启动config-server后，使用curl工具测试：
生成密文：
``` sh
curl http://serverhost:port/encrypt -d plaintext
```
测试解密(获取明文)：
``` sh
curl http://serverhost:port/decrypt -d encrypttext
```

## 4 配置文件配置加密串

配置文件中配置加密串只需在值前加:{cipher} ，yml文件和properties文件区别在于，yml文件需要使用引号(单双皆可)将{cipher}和密文包起来。如：
yml配置：
``` yml
password: '${cipher}ciphertext'
```
properties配置：
``` propertis
password = ${cipher}ciphertext
```

## 5 config client加载多个配置文件

1. github或者svn中的配置文件名模式为：config client中的spring.application.name值 + *.yml，如：
config-cipher.yml, config-cipher-dev.yml均可被config-cipher项目加载
2. config client中的spring.cloud.profile和spring.cloud.label值需要按照需求配置，
如：spring.cloud.profile=dev;spring.cloud.label=master即可拿到所有的配置文件
spring.cloud.profile=dev;spring.cloud.label=master只能单独拿到config-cipher.yml配置文件中配置项
