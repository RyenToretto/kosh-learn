#!/bin/bash

# 基本for循环
for i in 1 2 3 4 5; do
    echo $i
done

# 使用序列
for i in {1..5}; do
    echo $i
done

# 类C风格for循环
for ((i=0; i<5; i++)); do
    echo $i
done

# 遍历数组
fruits=("苹果" "香蕉" "橙子")
for fruit in "${fruits[@]}"; do
    echo $fruit
done

# 优化循环处理
optimize_loop() {
    local input_file=$1
    local output_file=$2

    # 使用管道而不是循环
    # 低效方式:
    # while read -r line; do
    #     process_line "$line" >> "$output_file"
    # done < "$input_file"

    # 优化方式:
    cat "$input_file" | parallel --pipe process_line > "$output_file"
}
