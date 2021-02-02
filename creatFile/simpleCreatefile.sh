#!/bin/bash
# @file		createfile.sh
# @author	chenguanren
# @version	V1.4.0
# @date		2018-10-27
# @brief	自动生成一个Doxygen风格的.c和.
# @date		2019-03-22
# @brief    添加第三个参数，生产文件的目录
# @date		2019-04-13
# @brief    是否只创建头文件
# @date		2019-09-29
# @brief    修改传参方式，支持覆盖之前存在的文件
# @date		2020-01-21
# @brief    添加支持文件类型参数，目前支持c/c++
# @date		2021-01-27
# @brief    简化代码模板，并支持保存10条历史命令
# @date		2021-02-02
# @brief    对整体代码进行优化，并支持c/c++/go文件创建
###################################################


#################################
########   0:帮助信息 ############
#################################
help()
{
    cat <<EOF
    Usage: $0 [options]

    available options:

      --help                    帮助信息
      --history                 历史列表，支持20个
      --name                    文件名
      --comment                 文件简要注释
      --path                    文件路径
      --type                    文件类型，c/c++
      --OnlyHead                有这个就只有头文件
      --cover                   有这个就覆盖之前的文件
      --addr                    修改地址值，也可以直接修改脚本
EOF
}

if [ "-h" == "$1" ] || [ "--help" == "$1" ];then
    help
    exit 1
fi


#################################
########   1:配置文件 ############
#################################
cfg_history_list="/tmp/.history_list_txt"
cfg_history_list_count="/tmp/.history_list_count_txt"


#################################
########   2:函数定义区 ##########
#################################
history_list()
{
    if [ ! -e ${cfg_history_list} ];then
        echo "历史列表为空"
    else
        echo | cat ${cfg_history_list}
    fi

    exit 0
}

save_history_list()
{
    cmd=$*
    if [ ! -e ${cfg_history_list_count} ];then
        cmd_count=0
        echo $cmd_count > ${cfg_history_list_count}
    else
        cmd_count=`cat ${cfg_history_list_count}`
    fi
    # echo "cmd_count $cmd_count $cmd"

    if [ ! -e ${cfg_history_list} ];then
        echo $cmd > ${cfg_history_list}
        let cmd_count++
    elif [ $cmd_count -lt 10 ];then
        sed -i "1i${cmd}" ${cfg_history_list}
        let cmd_count++
    else
        let cmd_count=10
        sed -i '$d' ${cfg_history_list}
        sed -i "1i${cmd}" ${cfg_history_list}
    fi

    echo $cmd_count > ${cfg_history_list_count}
}


#################################
########   3:参数处理 ############
#################################
# 3.0 参数定义
opt_file_name=null
opt_file_comment=""
opt_file_path=null
opt_file_type=null
opt_OnlyHead=no
opt_cover=no
opt_addr="HOME 深圳龙华"        #地址 可以手动修改，也可以传参
opt_history=""

# 3.1 获取参数变量
for opt do
    optarg="${opt#*=}"
    # echo "opt ${opt} $optarg"
    case "$opt" in
        --name=*)
            opt_file_name="$optarg"
            ;;
        --comment=*)
            opt_file_comment="$optarg"
            ;;
        --path=*)
            opt_file_path="$optarg"
            ;;
        --type=*)
            opt_file_type="$optarg"
            ;;
        --OnlyHead*)
            opt_OnlyHead=yes
            ;;
        --cover*)
            opt_cover=yes
            ;;
        --addr=*)
            opt_addr="$optarg"
            ;;
        --history*)
            history_list
            ;;
        *)
            echo "Unknown option $opt, ignored"
            ;;
    esac
done

# 3.3 参数打印
echo "file_name ${opt_file_name}"
echo "file_comment ${opt_file_comment}"
echo "file_path ${opt_file_path}"
echo "file_type ${opt_file_type}"
echo "OnlyHead ${opt_OnlyHead}"
echo "cover ${opt_cover}"
echo "addr ${opt_addr}"

# 3.4 判断参数是否正确
if [ "$opt_file_name" == "null" ]; then
    echo "[options] name can not be null"
    help
    exit 1
fi


#################################
########   4:处理逻辑 ###########
#################################
# 4.1 保存历史列表
save_history_list $0 $*

# 4.2 基本变量保存
# 4.2.1 获取当前系统时间
ls_date=`date +%Y-%m-%d`
year=`date +%Y`
# echo $ls_date

# 4.2.2 获取主机名
name=`hostname`
# echo $name

# 4.2.3 转为大写字母
UPPERCASE=$(echo ${opt_file_name} | tr '[a-z]' '[A-Z]') 
# echo $UPPERCASE

# 4.2.4 这是为了加宏的后缀
H=_H

# 4.2.5 类名首字母大写
class_name=`echo ${opt_file_name} | sed -e "s/\b\(.\)/\u\1/g"`
# echo "class_name ${class_name}"


# 4.3 判断文件和文件夹
# echo "opt_file_name ${opt_opt_file_name}"
# echo "opt_file_comment ${opt_opt_file_comment}"
# echo "file_path ${opt_file_path}"
# echo "file_type ${opt_file_type}"
# echo "OnlyHead ${opt_OnlyHead}"
# echo "cover ${opt_cover}"
# echo "addr ${opt_addr}"

# 4.3.1 处理文件类型
src_file_suffix=null
h_file_suffix=null
if [ x"$opt_file_type" == x"c" ];then
    src_file_suffix=c
    h_file_suffix=h
elif [ x"$opt_file_type" == x"c++" ] || [ x"$opt_file_type" == x"cpp" ];then
    src_file_suffix=cpp
    h_file_suffix=h
elif [ x"$opt_file_type" == x"go" ];then
    src_file_suffix=go
elif [ x"$opt_file_type" == x"js" ];then
    src_file_suffix=js
elif [ x"$opt_file_type" == x"html" ];then
    src_file_suffix=html
elif [ x"$opt_file_type" == x"css" ];then
    src_file_suffix=css
else
    src_file_suffix=c
    echo "文件类型不存在，使用默认的c"
fi 

# 4.3.2 处理头文件
if [ x"$opt_OnlyHead" == x"yes" ];then
    h_file_suffix=null
    echo "Only head file"
fi

# 4.3.3 创建文件夹
if [ x"$opt_file_path" != x"null" ];then
    if [ ! -d $opt_file_path ];then
        mkdir -p $opt_file_path
        cd $opt_file_path
    fi
    cd $opt_file_path
    echo "当前路径 `pwd`"
fi

# 4.3.4 如果需要覆盖就删除
if [ -e ${opt_file_name}.${src_file_suffix} ];then
    if [ x"$opt_cover" == x"yes" ];then
        rm ${opt_file_name}.${src_file_suffix}
    else 
        echo "${opt_file_name}.${src_file_suffix} file existed"
        exit
    fi
fi

if [ x"${h_file_suffix}" != x"null" ] && [ -e ${opt_file_name}.${h_file_suffix} ];then
    if [ x"$opt_cover" == x"yes" ];then
        rm ${opt_file_name}.${h_file_suffix}
    else 
        echo "${opt_file_name}.${h_file_suffix} file existed"
        exit
    fi
fi


# 4.3.5 创建文件
if [ ! -e ${opt_file_name}.${src_file_suffix} ];then
    touch ${opt_file_name}.${src_file_suffix}
fi

if [ x"${h_file_suffix}" != x"null" ] && [ ! -e ${opt_file_name}.${h_file_suffix} ];then
    touch ${opt_file_name}.${h_file_suffix}
fi

# 4.3.6 把后缀类型转为大写字母，然后匹配src类型
src_file_prefix=$(echo ${src_file_suffix} | tr '[a-z]' '[A-Z]') 
echo "src_file_prefix ${src_file_prefix}"


#################################
########   5:配置模板区 ##########
#################################

############## 5.0: 公共文件模板  ###################
COMM_SRC_FILE_HEAD="/**
    ******************************************************************************
    * @file    ${opt_file_name}.${src_file_suffix}
    * @author  $name
    * @version V1.0.0
    * @date    $ls_date
    * @brief   ${opt_file_comment}
    ******************************************************************************
    * @attention
    *
    *
    ******************************************************************************
    */ 
"

COMM_SRC_FILE_DEFINE="
/* Private typedef -----------------------------------------------------------*/

/* Private define ------------------------------------------------------------*/

/* Private macro -------------------------------------------------------------*/

/* Private variables ---------------------------------------------------------*/

/* Private function prototypes -----------------------------------------------*/

/* Private functions ---------------------------------------------------------*/
"

COMM_SRC_FILE_TAIL="


/************************ (C) $year $opt_addr *****END OF FILE****/
"


COMM_HEAD_FILE_HEAD="/**
    ******************************************************************************
    * @file    ${opt_file_name}.${h_file_suffix}
    * @author  $name
    * @version V1.0.0
    * @date    $ls_date
    * @brief   ${opt_file_comment}
    ******************************************************************************
    * @attention
    *
    *
    ******************************************************************************
    */ 

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __$UPPERCASE$H
#define __$UPPERCASE$H

#ifdef __cplusplus
    extern \"C\" {
#endif

/* Includes ------------------------------------------------------------------*/
"


COMM_HEAD_FILE_DEFINE="
/* Exported types ------------------------------------------------------------*/

/* Exported constants --------------------------------------------------------*/

/* Exported macro ------------------------------------------------------------*/

/* Exported functions --------------------------------------------------------*/ 
"

COMM_HEAD_FILE_TAIL="


#ifdef __cplusplus
}
#endif

#endif /* __$UPPERCASE$H */

/******************* (C) $year $opt_addr *****END OF FILE****/
"

############## 5.1: c文件模板  ###################
C_SRC_FILE="${COMM_SRC_FILE_HEAD}

/* Includes ------------------------------------------------------------------*/
#include \"${opt_file_name}.h\"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${opt_file_name}
    * @{
    */

${COMM_SRC_FILE_DEFINE}

/**
    * @}
    */

/**
    * @}
    */

${COMM_SRC_FILE_TAIL}
"

C_HEAD_FILE="${COMM_HEAD_FILE_HEAD}

/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${opt_file_name}
    * @{
    */

${COMM_HEAD_FILE_DEFINE}

/**
    * @}
    */

/**
    * @}
    */

${COMM_HEAD_FILE_TAIL}
"

############## 5.2: c++文件模板  ###################
CPP_SRC_FILE="${COMM_SRC_FILE_HEAD}

/* Includes ------------------------------------------------------------------*/
#include \"${opt_file_name}.h\"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${opt_file_name}
    * @{
    */

${COMM_SRC_FILE_DEFINE}


/**
    * @brief  ${opt_file_name}构造函数
    * @param  
    * @retval 
    */ 
${opt_file_name}::${opt_file_name}()
{

}    

/**
    * @brief  ${opt_file_name}析构函数
    * @param  
    * @retval 
    */ 
${opt_file_name}::~${opt_file_name}()
{

}


/**
    * @}
    */

/**
    * @}
    */

${COMM_SRC_FILE_TAIL}
"

CPP_HEAD_FILE="${COMM_HEAD_FILE_HEAD}


/** @addtogroup ${class_name}
    * @{
    */
class ${class_name}
{
    public:
        ${class_name}();
        ~${class_name}();

    private:

    protected:

};

${COMM_HEAD_FILE_DEFINE}


/**
    * @}
    */

${COMM_HEAD_FILE_TAIL}
"

############## 5.3: go文件模板  ###################
GO_SRC_FILE="${COMM_SRC_FILE_HEAD}

/* package ------------------------------------------------------------------*/
package main

import (
	\"fmt\"
	\"net\"
)

/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${opt_file_name}
    * @{
    */

${COMM_SRC_FILE_DEFINE}


/**
    * @}
    */

/**
    * @}
    */

${COMM_SRC_FILE_TAIL}
"


#################################
########   6:写入文件 ############
#################################
# 6.1.1 写入资源文件
if [ x"$src_file_suffix" == x"c" ];then
    echo "${C_SRC_FILE}" >> ${opt_file_name}.${src_file_suffix}
elif [ x"$src_file_suffix" == x"cpp" ];then
    echo "${CPP_SRC_FILE}" >> ${opt_file_name}.${src_file_suffix}
elif [ x"$src_file_suffix" == x"go" ];then
    echo "${GO_SRC_FILE}" >> ${opt_file_name}.${src_file_suffix}
elif [ x"$src_file_suffix" == x"js" ];then
    echo "${JS_SRC_FILE}" >> ${opt_file_name}.${src_file_suffix}
elif [ x"$src_file_suffix" == x"html" ];then
    echo "${HTML_SRC_FILE}" >> ${opt_file_name}.${src_file_suffix}
elif [ x"$src_file_suffix" == x"css" ];then
    echo "${CSS_SRC_FILE}" >> ${opt_file_name}.${src_file_suffix}
fi 
echo "`date '+%Y-%m-%d %H:%M:%S'` create ${opt_file_name}.${src_file_suffix} finish"


# 6.1.2  写入头文件
if [ x"$h_file_suffix" == x"null" ];then
    echo "不用创建头文件"
    exit 0
elif [ x"$src_file_suffix" == x"cpp" ];then
    echo "${CPP_HEAD_FILE}" >> ${opt_file_name}.${h_file_suffix}
elif [ x"$src_file_suffix" == x"c" ];then
    echo "${C_HEAD_FILE}" >> ${opt_file_name}.${h_file_suffix}
fi 
echo "`date '+%Y-%m-%d %H:%M:%S'` create ${opt_file_name}.${h_file_suffix} finish"
