---
title: 在SuSE Linux上安装Oracle Database 12c手记
date: 2018-08-13 14:04:01
tags:
- Database
- Oracle
categories: 
- 数据库
- Oracle
---
本文记录根据[Oracle官方安装文档](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/ladbi/index.html)，在`openSuSE Leap 15.0`上安装`Oracle Database 12c`(以下简称`Oracle 12c`)的过程。

<!-- more -->

# 安装前准备

## 检查物理内存空间及swap空间

`Oracle 12c`要求最低`1GB`物理内存，建议安装`2GB`物理内存。

```bash
$ free -m
              total        used        free      shared  buff/cache   available
Mem:           3833         945         919         156        1968        2449
Swap:          8472           0        8472
```

可见本机物理内存总计`4GB`，满足需求。

`Oracle 12c`要求当物理内存在`2GB`~`16GB`之间时，swap空间需等同于物理内存大小。如上结果可见`swap`空间约为`8GB`，大于需求值。

## 检查软件版本

### 检查操作系统内核版本

本机操作系统为`openSuSE Leap 15`，套用安装文档关于`SUSE Linux Enterprise Server 12 SP1`的要求`3.12.49-11.1 or later`。

```bash
$ uname -r
4.12.14-lp150.12.13-default
```

可见内核版本满足需求。

### 检查服务器配置

```bash
# 检查 /tmp 目录空间
$ df -h | grep /tmp
/dev/sda1        40G   11G   29G  28% /tmp

# 检查硬盘空间是否大于7.5GB
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        1.9G     0  1.9G   0% /dev
tmpfs           1.9G  4.0K  1.9G   1% /dev/shm
tmpfs           1.9G   18M  1.9G   1% /run
tmpfs           1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/sda1        40G   11G   29G  28% /
/dev/sda1        40G   11G   29G  28% /.snapshots
/dev/sda1        40G   11G   29G  28% /boot/grub2/x86_64-efi
/dev/sda1        40G   11G   29G  28% /boot/grub2/i386-pc
/dev/sda1        40G   11G   29G  28% /opt
/dev/sda1        40G   11G   29G  28% /tmp
/dev/sda1        40G   11G   29G  28% /var
/dev/sda1        40G   11G   29G  28% /root
/dev/sda1        40G   11G   29G  28% /srv
/dev/sda1        40G   11G   29G  28% /usr/local
/dev/sda3       250G  1.6G  249G   1% /home
tmpfs           384M  8.0K  384M   1% /run/user/1000
```

## 检查用户和组

### 检查Oracle Inventory和Oracle Inventory Group

```bash
$ more /etc/oraInst.loc
more: stat of /etc/oraInst.loc failed: No such file or directory

$ grep oinstall /etc/group
<NOTHING>
```

说明`Oracle Inventory Group`不存在。创建这个组。

```bash
$ sudo /usr/sbin/groupadd -g 54321 oinstall
```

### 创建一系列特权组

```bash
# Oracle Automatic Storage Management特权组
$ sudo /usr/sbin/groupadd -g 54327 asmdba

# Oracle Automatic Storage Management启动、停止特权组
$ sudo /usr/sbin/groupadd -g 54328 asmoper

# 数据库SYSDBA特权组
$ sudo /usr/sbin/groupadd -g 54322 dba

# 数据库SYSOPER特权组(有限的数据库管理权限)
$ sudo /usr/sbin/groupadd -g 54323 oper

# 数据库备份、恢复特权组
$ sudo /usr/sbin/groupadd -g 54324 backupdba

# Data Guard操作特权组
$ sudo /usr/sbin/groupadd -g 54325 dgdba

# Transparent Data Encryption keystore操作特权组
$ sudo /usr/sbin/groupadd -g 54326 kmdba

# Oracle RAC cluster日常管理特权组
$ sudo /usr/sbin/groupadd -g 54330 racdba
```

### 创建Oracle Software Owner User

```bash
# 创建用户
$ sudo /usr/sbin/useradd -u 54321 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba oracle

# 为该用户创建家目录，并设定umask
$ sudo /sbin/mkhomedir_helper oracle 022
```

### 检查ulimit

在`/etc/security/limits.conf`配置如下内容

```conf
# Resource limits for user oracle
oracle          soft    nofile          1024
oracle          hard    nofile          65536
oracle          soft    nproc           2047
oracle          hard    nproc           16384
oracle          soft    stack           10240
oracle          hard    stack           32768
```

# 安装

## 下载安装介质

访问Oracle下载页面下载`Oracle 12c`安装程序。



