---
title: 配置Jenkins集成JaCoCO
date: 2018-05-14 10:30:00
tags:
- Jenkins
- JaCoCo
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

## 执行测试

在引入JaCoCo插件后，每当执行Maven的test goal时，JaCoCo都会自动执行，并生成代码覆盖率报告文件**target/jacoco.exec**。

# 与ANT集成

**WORK IN PROGRESS**

# 生成报告

因为这个文件是二进制数据文件，无法直接打开，需要借助第三方工具解析这个文件，或者使用JaCoCo生成HTML格式的报告。

## 通过SonarQube

**WORK IN PROGRESS**

## 通过JaCoCo

执行Maven的**jacoco:report** goal即可生成HTML格式的报告

```bash
mvn jacoco:report
```

执行成功后，可以在**target/site/jacoco**下找到，报告页面示例如下图：
![Sample JaCoCo HTML report](/images/jenkins-jacoco-integration/jacoco-report.png)

# 与Jenkins集成

Jenkins提供了可以解析JaCoCo数据文件并生成报告的插件[JaCoCo](https://plugins.jenkins.io/jacoco)。使用该插件前，需要先使用JaCoCo生成数据文件。

## 配置

首先，需要在“构建”步骤中，使用构建工具调用JaCoCo生成数据文件。

然后，在“构建后操作”步骤中，添加“Record JaCoCo coverage report”，并配置好各项参数，实例如下图

![JaCoCo plugin configuration sample](/images/jenkins-jacoco-integration/jenkins-jacoco-plugin.png)

# 参考文档

+ [Intro to JaCoCo - Baeldung](http://www.baeldung.com/jacoco)
+ [JaCoCo Plugin - Jenkins Wiki](https://wiki.jenkins.io/display/JENKINS/JaCoCo+Plugin)