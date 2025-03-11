#!/bin/bash

# 定义数组
fruits=("苹果" "香蕉" "橙子")

# 访问数组元素
echo ${fruits[0]}     # 苹果
echo ${fruits[1]}     # 香蕉

# 获取所有元素
echo ${fruits[@]}     # 苹果 香蕉 橙子
echo ${fruits[*]}     # 苹果 香蕉 橙子

# 获取数组长度
echo ${#fruits[@]}    # 3

# 添加元素
fruits+=("梨")

# 修改元素
fruits[0]="草莓"

# 删除元素
unset fruits[1]

# 切片操作
echo ${fruits[@]:1:2}    # 从索引1开始，取2个元素

# 数组操作优化
optimize_array() {
    # 预分配数组大小
    declare -a arr
    local size=1000000

    # 一次性分配空间
    arr=( $(seq 1 $size) )

    # 使用局部变量存储数组长度
    local len=${#arr[@]}

    # 批量处理
    for ((i=0; i<len; i+=100)); do
        process_batch "${arr[@]:i:100}"
    done
}
