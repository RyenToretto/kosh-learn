#!/bin/bash

# 基本使用
awk '{print $1}' file.txt     # 打印第一列
awk -F: '{print $1,$3}' /etc/passwd  # 指定分隔符

# 条件处理
awk '$3 > 100 {print $1}' file.txt   # 打印第三列大于100的行
awk 'NR==1,NR==5' file.txt          # 打印1-5行

# 内置变量
# NR: 当前行号
# NF: 当前行的字段数
# $0: 整行内容
# $1,$2: 第1、2个字段
