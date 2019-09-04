# selenium + chrome headless使用

selenium是一个自动化Web浏览器的开源工具。它提供了接口以用于使用其他编程语言编写测试脚本，目前支持的语言包括：Ruby，Java，NodeJS，PHP，Perl，Python和C＃等。

以下主要是使用python和chrome headless进行selenium操作。代码公共初始化部分
``` python
from selenium import webdriver
options = webdriver.ChromeOptions()
options.add_argument('headless') #以headless模式启动
driver = webdriver.Chrome(executable_path='chrome-driver-path', options=options)
#driver = webdriver.Chrome(options=options) #若已配置chrome-driver的环境变量可采用这种简单写法
```

## 进行全网页截图的解决方案
使用selenium和chrome-headeless可对网页进行截图，```driver.save_screenshot('/path/screenshot.jpg')```即可截图，但是只能截出部分网页图片，
截出的图片大小主要受driver的window_size控制，因此，将window_size设置为较大值，则可以截出全网页图片，但如果window_size设置值过大，会导致截图较慢，
影响程序性能，因此可先获取全网页的长宽，再将window_size设置为全网页的长宽即可。具体思路如下：
1. 获取body元素的尺寸
2. 按照body元素的尺寸设置window size
3. 截图

具体代码如下：
``` python
from selenium import webdriver
options = webdriver.ChromeOptions()
options.add_argument('headless') #以headless模式启动
driver = webdriver.Chrome(executable_path='chrome-driver-path', options=options)
#driver = webdriver.Chrome(options=options) #若已配置chrome-driver的环境变量可采用这种简单写法
driver.get("http://target.url")
size = driver.find_element_by_tag_name('body').size  #获取body元素的尺寸
driver.set_window_size(size.get('width'), size.get('height')) #按照body元素的尺寸设置window size
driver.save_screenshot('/path/screenshot.jpg') #截图
driver.close()
```
> 此方案主要依照html中的body元素的长宽来决定窗口的大小，因此截图的结果受body元素的长宽影响，所以在某些页面截图效果不完整，如：豆瓣

## 下载图片
目前暂无使用selenium直接下载图片的较好解决方案，网上的模拟鼠标右键保存的方式，目前未测试成功。因此采用
先获取图片地址，再使用requests或者其他网络库下载图片的方式。
``` python
driver.get('http://target.url')
imgs=driver.find_elements_by_tag_name('img')
for i in imgs:
    img_url = i.get_attribute('src')
    #使用requests下载图片，
    #可使用driver.get_cookies()获取cookie，将requests的访问cookie设置为获取到的cookie
```