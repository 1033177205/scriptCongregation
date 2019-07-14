#!/bin/bash
# @file		installUbuntuSoftware.sh
# @author	cgr
# @version	V1.1.0
# @date		2019-07-14
# @brief	一个自动安装Ubuntu软件的脚本
###################################################

#1.拷贝制作好的脚本到虚拟机
#拷贝这个脚本到虚拟机，然后执行

#2.开启root权限
#默认是没有root权限的，所以要自己开启，目前不会做自动化，需要手动

#3.更新软件源
#3.1 备份sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

#3.2 插入软件源的路径
sed -i -e '3 a\deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse\n' /etc/apt/sources.list

sed -i -e '$ a\deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse\n' /etc/apt/sources.list

#3.3 更新软件源
echo 'yes' | sudo apt-get update
echo 'yes' | sudo apt-get upgrade

#4.更新vi 
echo 'yes' | sudo apt-get install vim

#5.安装ssh
#5.1 安装ssh包
echo 'yes' | sudo apt-get install openssh-server openssh-client

#5.2 开启root权限，不过这个已经支持了，就不写了


#6.安装Samba
#6.1 安装Samba软件包
echo 'yes' | sudo apt-get install samba samba-common

#6.2 添加Samba用户和密码，这个做不了自动
echo '123456' | sudo smbpasswd -a root

#6.3 开启共享目录
sed -i -e '$ a\[share]\ncomment = share folder\nbrowseable = yes\npath = \/\ncreate mask = 0700\ndirectory mask = 0700\npublic = yes \navailable = yes \nwritable = yes\n' /etc/samba/smb.conf

#6.4 重启Samba服务器
sudo service smbd restart


#7.安装tftp服务器
#7.1 安装tftp软件包
echo 'yes' | sudo apt-get install tftp-hpa tftpd-hpa xinetd

#7.2 配置/etc/xinetd.conf
#不过默认已经配好了，不要再配

#7.3 配置/etc/default/tftpd-hpa
sed -i 's/TFTP_DIRECTORY="\/var\/lib\/tftpboot"/TFTP_DIRECTORY="\/root\/tftpboot"/g' /etc/default/tftpd-hpa
sed -i 's/TFTP_OPTIONS="--secure"/TFTP_OPTIONS="-l -c -s"/g' /etc/default/tftpd-hpa

#7.4 配置/etc/xinetd.d/tftp
echo "service tftp
{
socket_type = dgram
wait = yes
disable = no
user = root
protocol = udp
server = /usr/sbin/in.tftpd
server_args = -s /root/tftpboot
#log_on_success += PID HOST DURATION
#log_on_failure += HOST
per_source = 11
cps =100 2
flags =IPv4
}" > /etc/xinetd.d/tftp

#7.5 修改权限
sudo mkdir /root/tftpboot
sudo chmod 777 /root/tftpboot

#7.6 重启服务
sudo service tftpd-hpa restart
sudo /etc/init.d/xinetd reload
sudo /etc/init.d/xinetd restart


#8.安装nfs
#8.1 安装nfs软件包
echo 'yes' | sudo apt-get install nfs-kernel-server nfs-common

#8.2 配置/etc/exports
sed -i -e '$ a\/root *(rw,sync,no_root_squash,no_subtree_check)' /etc/exports
sudo showmount -e
sudo exportfs -r
sudo showmount localhost -e

#启动nfs
sudo /etc/init.d/nfs-kernel-server restart

#9.修改静态ip
#9.1 备份/etc/netplan/01-network-manager-all.yaml
mv /etc/netplan/01-network-manager-all.yaml /etc/netplan/01-network-manager-all.yaml.bak

#9.2 修改成静态地址
#9.2.1 获取网卡名称
net='eth0'
net=$(ifconfig | awk -F'[ :]+' '!NF{if(eth!=""&&ip=="")print eth;eth=ip4=""}/^[^ ]/{eth=$1}/inet addr:/{ip=$4}')
net1=$(echo $net | cut -d " " -f 1)
echo $net1
#9.2.2 获取ip地址，并修改成一个固定的ip（目前写死的188）
ipaddr='172.0.0.1'
ipaddr=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
ipaddr1=${ipaddr%\.*}
ipaddr=$ipaddr1.188
echo $ipaddr
#9.2.3 获取网关ip(目前先这样用)
gateway=$(route -n | awk '/UG/{print $2}')
echo $gateway
#9.2.4 输入到/etc/netplan/01-network-manager-all.yaml文件中
echo "network:
  ethernets:
   $net1:
    addresses: [$ipaddr/24, ]
    dhcp4: no
    dhcp6: no
    gateway4:  $gateway
    nameservers:
     addresses: [8.8.8.8, 9.9.9.9]" > /etc/netplan/01-network-manager-all.yaml

#9.2.5 重启网络
netplan apply

#10.安装其他软件
#10.1 安装gcc
echo 'yes' | sudo apt-get install gcc

#10.2 安装make
echo 'yes' | sudo apt-get install make

#10.3 安装git
echo 'yes' | sudo apt-get install git

#11.重启
# reboot
