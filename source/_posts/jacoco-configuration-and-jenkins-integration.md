---
title: 配置Jenkins集成JaCoCO
date: 2018-05-14 10:30:00
tags:
- Jenkins
- JaCoCo
- DevOps
- Java
categories: 工具
---

最近公司的一个项目需要配置JaCoCo与Jenkins的集成，将配置步骤记载于此备忘。

**WORK IN PROGRESS**

<!--more-->

# 与Maven集成

## 在pom.xml中引入JaCoCo插件

```xml

<properties>
    <!-- Other properties -->
    <!-- You can pick any version you like -->
    <jacoco.version>0.8.1</jacoco.version>
</properties>

<!-- Other configurations -->

<build>
    <plugins>
        <!-- Other plugins -->

        <!-- JaCoCo plugin -->
        <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>${jacoco.version}</version>
                <configuration>
                    <!-- You can dump JaCoCo data from remote server running JaCoCo Agent -->
                    <!-- IP or hostname of the server -->
                    <address>localhost</address>
                    <!-- Port which JaCoCo Agent listening to. Default is 6300 -->
                    <port>6300</port>
                    <!-- Path to the output file for execution data -->
                    <destFile>/tmp/jacoco.exec</destFile>
                    <!-- If set to true and the execution data file already exists, coverage data is appended to the existing file. If set to false, an existing execution data file will be replaced. -->
                    <append>true</append>
                    <!-- Sets whether a reset command should be sent after the execution data has been dumped. -->
                    <reset>true</reset>
                    <!-- Specify packages or classes you don't want JaCoCo to scan -->
                    <!-- You can use wildcards here -->
                    <excludes>
                        <exclude>path/to/package/or/classes</exclude>
                    </excludes>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>prepare-package</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
    </plugins>
</build>

```

## 生成单元测试覆盖率数据文件

在引入JaCoCo插件后，每当执行Maven的test goal时，JaCoCo都会自动执行，并生成代码覆盖率报告文件**target/jacoco.exec**。

# 与ANT集成

**WORK IN PROGRESS**

# 使用JaCoCo Agent生成功能测试覆盖率数据

这里使用Tomcat作为示例，其他容器请自行查找配置方法。

首先，将jacocoagent.jar复制到一个合适的位置，如**$TOMAT_HOME/lib/jacocoagent.jar**，然后配置**$TOMCAT_HOME/bin/setenv.sh**，内容如下：

```bash
# 省略其他内容

# 配置解释
# 1. 指定jacocoagent.jar位置为/usr/local/opt/tomcat@8/libexec/lib/jacocoagent.jar
# 2. 指定要监控的包是com.example.*
# 3. 数据文件输出位置为/tmp/jacoco.exec。该文件将在容器停机时被写入
# 4. 指定作为tcpserver方式输出，监听的地址为*，即监听本机所有地址的传入连接。因为没有指定端口号，所以使用默认的6300
export JAVA_OPTS="-javaagent:/usr/local/opt/tomcat@8/libexec/lib/jacocoagent.jar=includes=com.example.*,destfile=/tmp/jacoco.exec,output=tcpserver,address=*"
```

编辑完成，并确认setenv.sh拥有执行权限后，启动Servlet容器，然后JaCoCo就会开始检测，并准备通过TCP连接传出数据。

# 生成报告

因为这个文件是二进制数据文件，无法直接打开，需要借助第三方工具解析这个文件，或者使用JaCoCo生成HTML格式的报告。

## 通过SonarQube

**WORK IN PROGRESS**

## 通过JaCoCo读取数据文件

执行Maven的**jacoco:report** goal即可生成HTML格式的报告

```bash
mvn jacoco:report
```

执行成功后，可以在**target/site/jacoco**下找到，报告页面示例如下图：
![Sample JaCoCo HTML report](/images/jenkins-jacoco-integration/jacoco-report.png)

## 从远程JaCoCo Agent中dump数据

如果在项目的pom.xml中配置了JaCoCo Agent的连接信息，那么就可以使用**mvn jacoco:dump**命令从远程服务器获取数据并保存到本地的jacoco.exec中。

然后通过**mvn jacoco:report**命令，或通过第三方工具，即可通过刚才获取到的数据生成覆盖率报告。

# 与Jenkins集成

Jenkins提供了可以解析JaCoCo数据文件并生成报告的插件[JaCoCo](https://plugins.jenkins.io/jacoco)。使用该插件前，需要先使用JaCoCo生成数据文件。

## 配置

首先，需要在“构建”步骤中，使用构建工具调用JaCoCo生成数据文件。

然后，在“构建后操作”步骤中，添加“Record JaCoCo coverage report”，并配置好各项参数，实例如下图

![JaCoCo plugin configuration sample](/images/jenkins-jacoco-integration/jenkins-jacoco-plugin.png)

# 参考文档

+ [Intro to JaCoCo - Baeldung](http://www.baeldung.com/jacoco)
+ [JaCoCo Plugin - Jenkins Wiki](https://wiki.jenkins.io/display/JENKINS/JaCoCo+Plugin)