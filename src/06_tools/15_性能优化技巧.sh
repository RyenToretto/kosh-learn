# 并行处理
parallel_process() {
    local max_jobs=4
    local job_count=0

    for item in "$@"; do
        (
            process_item "$item"
        ) &

        ((job_count++))

        if [ $job_count -ge $max_jobs ]; then
            wait
            job_count=0
        fi
    done
    wait  # 等待所有任务完成
}

# 内存使用优化
optimize_memory() {
    # 使用流处理代替加载整个文件
    while IFS= read -r line; do
        process_line "$line"
    done < large_file.txt

    # 定期清理内存
    sync && echo 3 > /proc/sys/vm/drop_caches
}
