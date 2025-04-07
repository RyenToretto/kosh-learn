#!/bin/bash

:<<!
块儿注释
!

# 只读变量
kjf="koujianfeng"
readonly kjf

# 打印
echo $kjf
echo ${#kjf} # 获取字符串的长度
echo ${kjf:3:4} # 输出 jian
echo `expr index ${kjf} j`
echo "普通输出"
echo "\b" # 退格键
echo -n "不换行"
echo -e "支持转义符\n换行"
echo -e "\a" # 输出一个警告音
echo -e "\a" # 输出一个警告音
echo -e "\e[1;31m abc \e[0m" # 设置输出的颜色
printf "格式化输出:\n %s\n" "文本"

# 环境变量
echo $PATH    # 命令搜索路径
echo $HOME    # 用户主目录
echo $USER    # 当前用户名
echo $SHELL   # 当前 shell 类型
env           # 查看所有环境变量

# 特殊变量
echo $0    # 脚本名称
echo $1    # 第一个参数
echo $2    # 第二个参数
echo $#    # 参数个数
echo $*    # 所有参数
echo $?    # 上一个命令的退出状态
echo $$    # 当前 Shell 进程 ID

# 输入命令
read -p "请输入你的名字：" name
echo "你好，$name"
