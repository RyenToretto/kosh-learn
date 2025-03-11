#!/bin/bash
:<<!
# 常用元字符
^ # 行首
$ # 行尾
. # 任意单个字符
* # 前面的字符重复0次或多次
[] # 字符集合
[^] # 取反字符集
!

# grep命令使用正则表达式
grep '^root' /etc/passwd  # 查找以root开头的行
grep '[0-9]$' file.txt    # 查找以数字结尾的行

# 使用grep的扩展正则（-E选项）
grep -E 'pattern1|pattern2' file.txt  # 匹配多个模式
grep -E '(word){2,3}' file.txt       # 重复次数限定
