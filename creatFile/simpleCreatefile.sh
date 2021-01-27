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
###################################################


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

file_name=null
file_comment=""
file_path=null
file_type=null
#地址 可以手动修改，也可以传参
addr="HOME 深圳龙华"
OnlyHead=no
cover=no
history_list_txt=".history_list_txt"
history_list_count_txt=".history_list_count_txt"

history_list()
{
    if [ ! -e ${history_list_txt} ];then
        echo "历史列表为空"
    else
        echo | cat ${history_list_txt}
    fi

    exit 0
}

save_history_list()
{
    cmd=$*
    if [ ! -e ${history_list_count_txt} ];then
        cmd_count=0
        echo $cmd_count > ${history_list_count_txt}
    else
        cmd_count=`cat ${history_list_count_txt}`
    fi
    echo "cmd_count $cmd_count $cmd"

    if [ ! -e ${history_list_txt} ];then
        echo $cmd > ${history_list_txt}
        let cmd_count++
    elif [ $cmd_count -lt 10 ];then
        sed -i "1i${cmd}" ${history_list_txt}
        let cmd_count++
    else
        let cmd_count=10
        sed -i '$d' ${history_list_txt}
        sed -i "1i${cmd}" ${history_list_txt}
    fi

    echo $cmd_count > ${history_list_count_txt}
}

# 匹配变量
for opt do
    optarg="${opt#*=}"
    echo "opt ${opt} $optarg"
    case "$opt" in
        --name=*)
            file_name="$optarg"
            ;;
        --comment=*)
            file_comment="$optarg"
            ;;
        --path=*)
            file_path="$optarg"
            ;;
        --type=*)
            file_type="$optarg"
            ;;
        --OnlyHead*)
            OnlyHead=yes
            ;;
        --cover*)
            cover=yes
            ;;
        --addr=*)
            addr="$optarg"
            ;;
        --history*)
            history_list
            ;;
        *)
            echo "Unknown option $opt, ignored"
            ;;
    esac
done

echo "file_name ${file_name}"
echo "file_comment ${file_comment}"
echo "file_path ${file_path}"
echo "file_type ${file_type}"
echo "addr ${addr}"
echo "OnlyHead ${OnlyHead}"
echo "cover ${cover}"

if [ "$file_name" == "null" ]; then
    echo "Option name can not be null"
    help
    exit 1
fi

# 保存历史列表
save_history_list $0 $*

# 创建文件夹
if [ x"$file_path" != x"null" ];then
    if [ ! -d $file_path ];then
        mkdir -p $file_path
        cd $file_path
        echo `pwd`
    else
        cd $file_path
        echo `pwd`
    fi
fi

if [ x"$cover" == x"yes" ];then
    if [ x"`ls ./${file_name}.*`" != x"" ];then
        rm ./${file_name}.*
    fi
fi

file_suffix=null
if [ x"$file_type" == x"c" ];then
    file_suffix=c
elif [ x"$file_type" == x"c++" ] || [ x"$file_type" == x"cpp" ];then
    file_suffix=cpp
else
    file_suffix=c
fi 

if [ x"$OnlyHead" == x"yes" ];then
    cfile_creat=0
    echo "Only head file"
fi


cfile=0
#1.2 创建文件
if [ ! -e ${file_name}.${file_suffix} ] && [ "$cfile_creat" != "0" ];then
    touch ${file_name}.${file_suffix}
    cfile=1
fi

hfile=0
if [ ! -e ${file_name}.h ];then
    touch ${file_name}.h
    hfile=1
fi

#获取当前系统时间
ls_date=`date +%Y-%m-%d`
year=`date +%Y`
# echo $ls_date

name=`hostname`
# echo $name

UPPERCASE=$(echo ${file_name} | tr '[a-z]' '[A-Z]') 
# echo $UPPERCASE
H=_H

# 首字母大写
class_name=`echo ${file_name} | sed -e "s/\b\(.\)/\u\1/g"`
echo "----------- ${class_name}"

#################################
########   下面为模板文件 ########
#################################

C_SRC_FILE="/**
    ******************************************************************************
    * @file    ${file_name}.${file_suffix}
    * @author  $name
    * @version V1.0.0
    * @date    $ls_date
    * @brief   ${file_comment}
    ******************************************************************************
    * @attention
    *
    *
    ******************************************************************************
    */ 

/* Includes ------------------------------------------------------------------*/
#include \"${file_name}.h\"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${file_name}
    * @{
    */

/* Private typedef -----------------------------------------------------------*/

/* Private define ------------------------------------------------------------*/

/* Private macro -------------------------------------------------------------*/

/* Private variables ---------------------------------------------------------*/

/* Private function prototypes -----------------------------------------------*/

/* Private functions ---------------------------------------------------------*/


/**
    * @}
    */

/**
    * @}
    */

/************************ (C) $year $addr *****END OF FILE****/
"

CPP_SRC_FILE="/**
    ******************************************************************************
    * @file    ${file_name}.${file_suffix}
    * @author  $name
    * @version V1.0.0
    * @date    $ls_date
    * @brief   ${file_comment}
    ******************************************************************************
    * @attention
    *
    *
    ******************************************************************************
    */ 

/* Includes ------------------------------------------------------------------*/
#include \"${file_name}.h\"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${file_name}
    * @{
    */

/* Private typedef -----------------------------------------------------------*/

/* Private define ------------------------------------------------------------*/

/* Private macro -------------------------------------------------------------*/

/* Private variables ---------------------------------------------------------*/

/* Private function prototypes -----------------------------------------------*/

/* Private functions ---------------------------------------------------------*/


/**
    * @brief  ${file_name}构造函数
    * @param  
    * @retval 
    */ 
${file_name}::${file_name}()
{

}    

/**
    * @brief  ${file_name}析构函数
    * @param  
    * @retval 
    */ 
${file_name}::~${file_name}()
{

}

/**
    * @}
    */

/**
    * @}
    */

/************************ (C) $year $addr *****END OF FILE****/
"


C_HEAD_FILE="/**
    ******************************************************************************
    * @file    ${file_name}.h
    * @author  $name
    * @version V1.0.0
    * @date    $ls_date
    * @brief   ${file_comment}
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


/** @addtogroup DataStruct_Driver
    * @{
    */

/** @addtogroup ${file_name}
    * @{
    */

/* Exported types ------------------------------------------------------------*/

/* Exported constants --------------------------------------------------------*/

/* Exported macro ------------------------------------------------------------*/

/* Exported functions --------------------------------------------------------*/ 


/**
    * @}
    */

/**
    * @}
    */


#ifdef __cplusplus
}
#endif

#endif /* __$UPPERCASE$H */

/******************* (C) $year $addr *****END OF FILE****/
"

CPP_HEAD_FILE="/**
    ******************************************************************************
    * @file    ${file_name}.h
    * @author  $name
    * @version V1.0.0
    * @date    $ls_date
    * @brief   ${file_comment}
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


/* Exported types ------------------------------------------------------------*/

/* Exported constants --------------------------------------------------------*/

/* Exported macro ------------------------------------------------------------*/

/* Exported functions --------------------------------------------------------*/ 


/**
    * @}
    */

#ifdef __cplusplus
}
#endif

#endif /* __$UPPERCASE$H */

/******************* (C) $year $addr *****END OF FILE****/
"


#################################
########  写文件  ################
#################################
if [ $cfile -eq 1 ];
then

    if [ x"${file_suffix}" == x"c" ];then
        echo "${C_SRC_FILE}" >> ${file_name}.c
        echo "aa"
    elif [ x"${file_suffix}" == x"cpp" ];then
        echo "${CPP_SRC_FILE}" >> ${file_name}.cpp
        echo "gg"
    fi

echo "`date '+%Y-%m-%d %H:%M:%S'` create ${file_name}.${file_suffix} finish"
else 
    if [ "$cfile_creat" == "0" ];then
        echo "No need to create ${file_name}.${file_suffix} file"
    else
        echo "${file_name}.${file_suffix} file existed"
    fi
fi

#写h文件
if [ $hfile -eq 1 ];
then
    if [ x"${file_suffix}" == x"c" ];then
        echo "${C_HEAD_FILE}" >> ${file_name}.h
    elif [ x"${file_suffix}" == x"cpp" ];then
        echo "${CPP_HEAD_FILE}" >> ${file_name}.h
    fi

echo "`date '+%Y-%m-%d %H:%M:%S'` create ${file_name}.h finish"
else
echo "${file_name}.h file existed"
fi
