#!/bin/bash
# @file		createfile.sh
# @author	chenguanren
# @version	V1.3.0
# @date		2018-10-27
# @brief	自动生成一个Doxygen风格的.c和.
# @date		2019-03-22
# @brief    添加第三个参数，生产文件的目录
# @date		2019-04-13
# @brief    是否只创建头文件
# @date		2019-09-29
# @brief    修改传参方式，支持覆盖之前存在的文件
###################################################


help()
{
    cat <<EOF
    Usage: $0 [options]

    available options:

      --help                    帮助信息
      --name                    文件名
      --comment                 文件简要注释
      --path                    文件路径
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
#地址 可以手动修改，也可以传参
addr="HOME 深圳龙华"
OnlyHead=no
cover=no

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
        --OnlyHead*)
            OnlyHead=yes
            ;;
        --cover*)
            cover=yes
            ;;
        --addr=*)
            addr="$optarg"
            ;;
        *)
            echo "Unknown option $opt, ignored"
            ;;
    esac
done

echo "file_name ${file_name}"
echo "file_comment ${file_comment}"
echo "file_path ${file_path}"
echo "addr ${addr}"
echo "OnlyHead ${OnlyHead}"
echo "cover ${cover}"

if [ "$file_name" == "null" ]; then
    echo "Option name can not be null"
    help
    exit 1
fi

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

if [ x"$OnlyHead" == x"yes" ];then
    cfile_creat=0
    echo "Only head file"
fi

cfile=0
#1.2 创建文件
if [ ! -e ${file_name}.c ] && [ "$cfile_creat" != "0" ];then
    touch ${file_name}.c
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

#写c文件
if [ $cfile -eq 1 ];
then
echo "/**
    ******************************************************************************
    * @file    ${file_name}.c
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


/** @defgroup ${file_name}_Exported_Functions ${file_name} Exported Functions
    * @{
    */

/** @defgroup ${file_name}_Exported_Functions_Group1 Initialization and deinitialization functions
    *  @brief    Initialization and Configuration functions
    *
@verbatim    
    ===============================================================================
                ##### Initialization and deinitialization functions #####
    ===============================================================================
    [..]
        This section provides functions allowing to initialize and de-initialize the ${file_name}
        to be ready for use.
 
@endverbatim
    * @{
    */ 

/**
    * @brief  创建${file_name}对象
    * @param  
    * @retval 
    */ 
    int8_t ${file_name}_creat(void)
    {
        return 0;
    }

/**
    * @brief  销毁${file_name}对象
    * @param  
    * @retval 
    */ 
    int8_t ${file_name}_destroy(void)
    {
        return 0;
    }
    
/**
    * @}
    */

/** @defgroup ${file_name}_Exported_Functions_Group2 operation functions 
    *  @brief   operation functions
    *
@verbatim   
    ===============================================================================
                        ##### operation functions #####
    ===============================================================================
    [..]
        This subsection provides a set of functions allowing to manage the ${file_name}.

@endverbatim
    * @{
    */

        /* 操作函数写在这里 */

    /**
    * @}
    */


/**
    * @}
    */

/**
    * @}
    */

/**
    * @}
    */

/************************ (C) $year $addr *****END OF FILE****/
" >> ${file_name}.c

echo "`date '+%Y-%m-%d %H:%M:%S'` create ${file_name}.c finish"
else 
    if [ "$cfile_creat" == "0" ];then
        echo "No need to create ${file_name}.c file"
    else
        echo "${file_name}.c file existed"
    fi
fi

#写h文件
if [ $hfile -eq 1 ];
then
echo "/**
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
/** @defgroup 
    * @{
    */ 



/**
    * @}
    */


/* Exported constants --------------------------------------------------------*/

/* Exported macro ------------------------------------------------------------*/

/* Exported functions --------------------------------------------------------*/ 
/* Initialization and de-initialization functions *******************************/
/** @addtogroup ${file_name}_Exported_Functions
    * @{
    */

/** @addtogroup ${file_name}_Exported_Functions_Group1
    * @{
    */
    int8_t ${file_name}_creat(void);
    int8_t ${file_name}_destroy(void);

/**
    * @}
    */

/* operation functions *******************************************************/
/** @addtogroup ${file_name}_Exported_Functions_Group2
    * @{
    */



/**
    * @}
    */

/**
    * @}
    */ 

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
" >> ${file_name}.h

echo "`date '+%Y-%m-%d %H:%M:%S'` create ${file_name}.h finish"
else
echo "${file_name}.h file existed"
fi
