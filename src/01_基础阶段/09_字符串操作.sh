#!/bin/bash

str="Hello World"

# 获取字符串长度
echo ${#str}      # 11

# 提取子字符串
echo ${str:0:5}   # Hello
echo ${str:6}     # World

# 字符串拼接
str1="Hello"
str2="World"
str3="$str1 $str2"

text="hello hello world"

# 替换第一次出现
echo ${text/hello/hi}      # hi hello world

# 替换所有出现
echo ${text//hello/hi}     # hi hi world

# 删除匹配的内容
echo ${text#hello}         # 删除开头匹配
echo ${text%world}         # 删除结尾匹配
