---
title: 监听Tomcat的启动、停止事件
date: 2018-08-15 09:53:47
tags:
- Tomcat
categories: 
- Java
- Tomcat
---
在 Servlet API 中有一个 ServletContextListener 接口，它能够监听 ServletContext 对象的生命周期，实际上就是监听 Web 应用的生命周期。

当Servlet 容器启动或终止Web 应用时，会触发ServletContextEvent 事件，该事件由ServletContextListener 来处理。在 ServletContextListener 接口中定义了处理ServletContextEvent 事件的两个方法。 

<!-- more -->

# 监听器类编写

新建一个监听器类`TomcatListener`并实现`ServletContextListener`接口

```java
public class DemoListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        System.out.println("Tomcat Started");
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
        System.out.println("Tomcat Destroyed");
    }
}
```

# 配置web.xml

在`web.xml`中添加`listener`条目

```xml
<listener>
    <listener-class>com.project.name.listener.DemoListener</listener-class>
</listener>
```

# 验证

将WAR包部署到`Tomcat`并启动，检查`catalina.out`

在`Tomcat`启动时看到如下日志：

```
15-Aug-2018 15:58:44.632 INFO [localhost-startStop-1] org.apache.catalina.startup.HostConfig.deployWAR Deploying web application archive [/usr/local/Cellar/tomcat@8/8.5.28/libexec/webapps/tomcatlistener.war]
Tomcat Started
```

在`Tomcat`停止时看到如下日志：

```
15-Aug-2018 16:02:22.582 INFO [main] org.apache.catalina.core.StandardService.stopInternal Stopping service [Catalina]
Tomcat Destroyed
```

输出内容与`TomcatListener`所写内容一致，Q.E.D.
