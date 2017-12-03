---
title: Ubuntu中安装ShadowSocks及混淆插件的脚本
date: 2017-11-29 17:10:09
tags:
- ShadowSocks
- Simple Obfs
categories: 其他
---
以下脚本目的在于便利自己安装该工具，并不是一个成熟的版本，如要使用，本人不承担任何可能带来的后果。
该脚本目前仅能用于Ubuntu Linux。在Ubuntu Server 17.04下测试通过。
另外您可以在[我的Gist](https://gist.github.com/boris1993/0031187d7f0df73f049d3adaa56bb279)中下载该脚本
<!--more-->
```bash
#!/bin/bash

if [[ `id -u` -ne 0 ]]; then
    echo "This script can only be run as root"
    exit 1
fi

# Installation of basic build dependencies
echo 'Prepare to install dependencies...'
apt-get install --no-install-recommends --assume-yes gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake

# Installation of Libsodium
echo 'Prepare to install libsodium...'
export LIBSODIUM_VER=1.0.13
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
make install
popd
ldconfig

# Installation of MbedTLS
echo 'Prepare to install MbedTLS...'
export MBEDTLS_VER=2.6.0
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
make DESTDIR=/usr install
popd
ldconfig

# Install Shadowsocks
echo 'Prepare to install ShadowSocks...'
git clone https://github.com/shadowsocks/shadowsocks-libev.git
pushd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh && ./configure --prefix=/usr && make
make install

pushd debian
cp shadowsocks-libev-server@.service /etc/systemd/system
popd

# Install simple-obfs
echo 'Prepare to install simple-obfs'
apt-get install --no-install-recommends --assume-yes build-essential autoconf libtool libssl-dev libpcre3-dev libev-dev asciidoc xmlto automake
git clone https://github.com/shadowsocks/simple-obfs.git
pushd simple-obfs
git submodule update --init --recursive
./autogen.sh
./configure && make
make install
popd

# Install Apache2 for acting as a fallback server
echo "Installing Apache2"
apt-get install --assume-yes apache2

# Post installation process

## Generate config.json
echo "Generating config.json"

if [ ! -d /etc/shadowsocks-libev ]; then
    mkdir /etc/shadowsocks-libev
fi

pushd /etc/shadowsocks-libev

read -p "Server address [0.0.0.0]: " SERVER_ADDRESS
SERVER_ADDRESS=${SERVER_ADDRESS:-0.0.0.0}

read -p "Server port [8388]: " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-8388}

read -p "Local port [1080]: " LOCAL_PORT
LOCAL_PORT=${LOCAL_PORT:-1080}

read -p "Password [password]: " PASSWORD
PASSWORD=${PASSWORD:-password}

echo "{" > config.json
echo -e "\t\"server\":\""$SERVER_ADDRESS"\"," >> config.json
echo -e "\t\"server_port\":"$SERVER_PORT"," >> config.json
echo -e "\t\"local_port\":"$LOCAL_PORT"," >> config.json
echo -e "\t\"password\":\""$PASSWORD"\"," >> config.json
echo -e "\t\"timeout\":60," >> config.json
echo -e "\t\"method\":\"chacha20-ietf-poly1305\"," >> config.json
echo -e "\t\"plugin\":\"obfs-server\"," >> config.json
echo -e "\t\"plugin_opts\":\"obfs=http;failover=127.0.0.1:80\"" >> config.json
echo "}" >> config.json

popd

## Enable systemd service
echo "Enabling and starting service"
systemctl enable shadowsocks-libev-server@config

## Start service
systemctl start shadowsocks-libev-server@config

echo "Finished"
```