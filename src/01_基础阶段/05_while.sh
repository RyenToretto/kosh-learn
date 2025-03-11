#!/bin/bash

# 基本while循环
count=1
while [ $count -le 5 ]; do
    echo $count
    count=$((count + 1))
done

# 读取文件
while read line; do
    echo $line
done < file.txt
