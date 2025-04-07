#!/bin/bash

# 定义数组
fruits=("苹果" "香蕉" "橙子")

# 访问数组元素
echo "${fruits[0]}"     # 苹果
echo "${fruits[1]}"     # 香蕉

# 获取所有元素
echo "${fruits[@]}"     # 苹果 香蕉 橙子
echo "${fruits[*]}"     # 苹果 香蕉 橙子

# 获取数组长度
echo ${#fruits[@]}    # 3

# 添加元素
fruits+=("梨")
echo "${fruits[@]}"

# 修改元素
fruits[0]="草莓"
echo "${fruits[@]}"

# 删除元素
unset 'fruits[1]'
echo "${fruits[@]}"

# 切片操作
echo "${fruits[@]:1:2}"    # 从索引1开始，取2个元素

# 数组操作优化
optimize_array() {
    local size=1000000
    declare -a arr

    # 安全地填充数组
    mapfile -t arr < <(seq 1 "$size")

    local len=${#arr[@]}

    for ((i=0; i<len; i+=100)); do
        process_batch "${arr[@]:i:100}"
    done
}
optimize_array;
