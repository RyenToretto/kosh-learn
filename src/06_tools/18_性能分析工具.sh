#!/bin/bash
# performance_profiler.sh

# 时间性能分析
time_profiler() {
    local func_name=$1
    shift

    local start_time=$(date +%s%N)
    "$func_name" "$@"
    local end_time=$(date +%s%N)

    local duration=$(( (end_time - start_time) / 1000000 ))
    echo "函数 $func_name 执行时间: ${duration}ms"
}

# 内存使用分析
memory_profiler() {
    local pid=$1
    local interval=${2:-1}  # 默认1秒

    while true; do
        local mem_usage=$(ps -o rss= -p "$pid")
        echo "[$(date '+%H:%M:%S')] 内存使用: ${mem_usage}KB"
        sleep "$interval"
    done
}

# CPU分析
cpu_profiler() {
    local pid=$1
    local duration=${2:-60}  # 默认60秒

    # 使用perf记录CPU使用情况
    perf record -F 99 -p "$pid" -g -- sleep "$duration"
    perf report
}


# 性能测试工具
benchmark_function() {
    local func_name=$1
    local iterations=${2:-100}
    local total_time=0
    local max_time=0
    local min_time=999999

    echo "开始性能测试: $func_name"
    echo "迭代次数: $iterations"

    for ((i=1; i<=$iterations; i++)); do
        local start_time=$(date +%s.%N)
        $func_name
        local end_time=$(date +%s.%N)

        local duration=$(echo "$end_time - $start_time" | bc)
        total_time=$(echo "$total_time + $duration" | bc)

        # 更新最大和最小时间
        if (( $(echo "$duration > $max_time" | bc -l) )); then
            max_time=$duration
        fi
        if (( $(echo "$duration < $min_time" | bc -l) )); then
            min_time=$duration
        fi
    done

    local avg_time=$(echo "scale=3; $total_time / $iterations" | bc)

    echo "测试结果:"
    echo "平均执行时间: ${avg_time}s"
    echo "最大执行时间: ${max_time}s"
    echo "最小执行时间: ${min_time}s"
}


