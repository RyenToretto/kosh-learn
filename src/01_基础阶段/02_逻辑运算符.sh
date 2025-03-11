#!/bin/bash

# 与运算 &&
if [ $age -gt 18 ] && [ $age -lt 60 ]; then
    echo "工作年龄"
fi

# 或运算 ||
if [ $age -lt 18 ] || [ $age -gt 60 ]; then
    echo "未到工作年龄或退休年龄"
fi

# 非运算 !
if [ ! -f "file.txt" ]; then
    echo "文件不存在"
fi
