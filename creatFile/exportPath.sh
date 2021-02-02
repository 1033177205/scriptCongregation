#!/bin/bash
# @file		exportPath.sh
# @author	chenguanren
# @version	V1.0.0
# @date		2021-02-02
# @brief	把当前路径添加到path中
###################################################

# 为了windows和linux系统通过，统一修改/etc/profile文件，windows系统可以通过git调用sh

path=`pwd`
echo "path ${path}"
if [ -e /etc/profile_exportPath.bak ];then
    echo "已经插入了一次了，请先删除原来记录，不要移动该文件夹"
    exit 1
fi

cp /etc/profile /etc/profile_exportPath.bak -f

sed -i "\$aexport PATH=\"\${PATH}:${path}\"" /etc/profile   #这是在最后一行行后添加字符串

source /etc/profile 
