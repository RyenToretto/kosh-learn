# 并行任务处理器
parallel_processor() {
    local max_jobs=${1:-4}  # 默认4个并行任务
    local job_queue=()

    # 任务处理函数
    process_job() {
        local job=$1
        time_profiler "process_task" "$job"
    }

    # 并行执行任务
    for job in "${jobs[@]}"; do
        # 等待有可用的处理槽
        while [ ${#job_queue[@]} -ge $max_jobs ]; do
            for i in "${!job_queue[@]}"; do
                if ! kill -0 ${job_queue[i]} 2>/dev/null; then
                    unset 'job_queue[i]'
                fi
            done
            sleep 0.1
        done

        # 启动新任务
        process_job "$job" &
        job_queue+=($!)
    done

    # 等待所有任务完成
    wait
}

# 并行文件处理
parallel_file_processor() {
    local input_dir=$1
    local output_dir=$2

    find "$input_dir" -type f -print0 | \
        xargs -0 -P $(nproc) -I{} \
        bash -c "process_file '{}' '$output_dir'"
}
