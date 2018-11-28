#!/bin/bash
# Centos7.4 自动部署cobbler server
# 2018 11 28
# jason
# v1.0

# 添加阿里源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 安装所需软件
yum -y install cobbler cobbler-web dhcp tftp-server pykickstart httpd python-django

#设置相关软件开机自启动
systemctl enable cobblerd httpd tftp.socket rsyncd
systemctl start httpd tftp.socket rsyncd cobblerd


# 修改cobbler相关文件
subnet=172.16.1 # dhcp网段

cobbler_ip=$(/usr/sbin/ip addr show eth1 |awk -F "[ /]*" 'NR==3{print $3}') # cobbler server 用于tftp server及http server的网卡ip

sed -i '14s#yes#no#' /etc/xinetd.d/tftp# 修改tftp相关配置

sed -i "s#pxe_just_once: 0#pxe_just_once: 1#" /etc/cobbler/settings # 防止误重装

sed -i "s#manage_dhcp: 0#manage_dhcp: 1#" /etc/cobbler/settings # 配置Cobbler统一管理DHCP

sed -i.ori "s#192.168.1#$subnet#g;22d;23d" /etc/cobbler/dhcp.template # 配置DHCP Cobbler模版

sed -i "s#server: 127.0.0.1#server: $cobbler_ip#;s#next_server: 127.0.0.1#next_server: $cobbler_ip#" /etc/cobbler/settings # 修改server和next-server地址

sed -i 's#$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.#$1$gAR8NnAS$7B21qYq0J2oQt06wdlT5T.#' /etc/cobbler/settings # 修改系统的密码为123456 可以根据需求使用openssl passwd -1 生成新的加密密码

# 重启cobbler 
systemctl restart cobblerd
sleep 2

# 同步cobbler配置
/usr/bin/cobbler sync

# 下载boot-loaders
/usr/bin/cobbler get-loaders

# 再次重启cobbler
systemctl restart cobblerd
sleep 2
/usr/bin/cobbler sync

# 访问信息
echo ""
ext_ip=$(/usr/sbin/ip addr show eth0 |awk -F "[ /]*" 'NR==3{print $3}')
echo -e "######## Cobbler installed successfully ########\nplease visit https://$ext_ip/cobbler_web\nuser=cobbler password=cobbler"


