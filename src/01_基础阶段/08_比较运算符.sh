#!/bin/bash

a=1
b=2
str1="aa"
str2="bb"

# 数值比较
if [ $a -eq $b ]; then
  echo "${a}等于${b}"
elif [ $a -ne $b ]; then
  echo "${a}不等于${b}"
fi
echo [ $a -ne $b ]  # 不等于
echo [ $a -gt $b ]  # 大于
echo [ $a -lt $b ]  # 小于
echo [ $a -ge $b ]  # 大于等于
echo [ $a -le $b ]  # 小于等于

# 字符串比较
echo [ "$str1" = "$str2" ]   # 相等
echo [ "$str1" != "$str2" ]  # 不相等
echo [ -z "$str1" ]          # 判断是否为空字符串
echo [ -n "$str1" ]          # 判断是否非空字符串
