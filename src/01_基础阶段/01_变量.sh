#!/bin/bash

# 知识点1. 只读变量
kjf="koujianfeng"
readonly kjf

# 知识点2. 打印
echo $kjf
echo "普通输出"
echo -e "支持转义符\n换行"
printf "格式化输出:\n %s\n" "文本"

# 知识点3. 特殊变量
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
