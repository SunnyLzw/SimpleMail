# SimpleMail

## 介绍
一个简单的邮件发送器

## 软件架构
### .\Bin\Config

配置文件夹，可以删除，运行时自动创建默认配置文件

### .\Bin\Data

数据库文件夹，可以删除，运行时自动创建默认数据库

### .\Bin\Res

资源文件夹，可以删除和替换，但是某些组件可能无法显示图片

### .\Bin\Plugins

插件目录

### .\Bin\Plugins\Plugin

插件开发框架目录

### .\Bin\libeay32.dll

OpenSSL组件，可以删除和替换，但可能无法使用与SSL相关的功能

### .\Bin\ssleay32.dll

OpenSSL组件，可以删除和替换，但可能无法使用与SSL相关的功能

## 字符编码

所有文件默认使用Unicode（UTF-16）编码，说明文档除外