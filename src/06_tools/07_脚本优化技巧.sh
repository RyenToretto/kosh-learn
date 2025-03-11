#!/bin/bash
# 性能优化示例

# 使用内存而不是磁盘
temp_dir="/dev/shm/temp_$$"
mkdir -p "$temp_dir"

# 减少外部命令调用
count=0
for i in {1..1000}; do
    ((count++))  # 使用内置命令而不是 expr
done

# 使用并行处理
process_data() {
    local file=$1
    # 处理逻辑
}

# 并行处理多个文件
for file in data_*.txt; do
    process_data "$file" &
done
wait  # 等待所有后台任务完成
