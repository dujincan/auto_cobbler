#!/bin/bash

# 添加阿里源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 安装所需软件
yum -y install cobbler cobbler-web dhcp tftp-server pykickstart httpd python-django

#设置相关软件开机自启动并启动
systemctl enable cobblerd httpd tftp.socket rsyncd
systemctl start cobblerd httpd tftp.socket rsyncd

# 修改cobbler配置文件

# 防止误重装
sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings 
# 配置Cobbler统一管理DHCP
sed -i 's/manage_dhcp: 0/manage_dhcp: 1/' /etc/cobbler/settings
# 配置DHCP Cobbler模版
sed -i.ori 's#192.168.1#172.16.1#g;22d;23d' /etc/cobbler/dhcp.template
# 修改server和next-server地址
sed -i 's#server: 127.0.0.1#server: 172.16.1.202#;s#next_server: 127.0.0.1#next_server: 172.16.1.202#' /etc/cobbler/settings

# 重启cobbler
/usr/bin/cobbler sync
systemctl restart cobblerd


