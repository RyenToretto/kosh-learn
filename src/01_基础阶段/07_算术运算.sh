#!/bin/bash

# 基本算术运算
a=10
b=20
sum=$((a + b))
echo $sum      # 30

# 其他运算方式
let "c = a + b"
d=`expr $a + $b`

# 支持的运算符
echo $((a + b))  # 加法
echo $((a - b))  # 减法
echo $((a * b))  # 乘法
echo $((a / b))  # 除法
echo $((a % b))  # 取余
