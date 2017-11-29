---
title: Ubuntu中安装ShadowSocks及混淆插件的脚本
date: 2017-11-29 17:10:09
tags:
- ShadowSocks
- Simple Obfs
categories: 其他
---
以下脚本目的在于便利自己安装该工具，并不是一个成熟的版本，如要使用，本人不承担任何可能带来的后果。
<!--more-->
```bash
#!/bin/bash

# Installation of basic build dependencies
echo 'Prepare to install dependencies...'
sudo apt-get install --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake

# Installation of Libsodium
echo 'Prepare to install libsodium...'
export LIBSODIUM_VER=1.0.13
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
sudo make install
popd
sudo ldconfig

# Installation of MbedTLS
echo 'Prepare to install MbedTLS...'
export MBEDTLS_VER=2.6.0
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
popd
sudo ldconfig

# Install Shadowsocks
echo 'Prepare to install ShadowSocks...'
git clone https://github.com/shadowsocks/shadowsocks-libev.git
pushd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh && ./configure && make
sudo make install
popd

# Install simple-obfs
echo 'Prepare to install simple-obfs'
sudo apt-get install --no-install-recommends build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake
git clone https://github.com/shadowsocks/simple-obfs.git
pushd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make
sudo make install
popd

# Post installation process
# TODO:
# 1. Copy config.json to /etc/shadowsocks-libev or create a new one
# 2. Accept user inputs and modify the content of config.json
# 3. Copy the systemd service definition to /etc/systemd/system
# 4. Modify the service definition
# 5. Start the service
```