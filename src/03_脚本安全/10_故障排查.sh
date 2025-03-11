# troubleshoot.sh

# 性能问题排查
diagnose_performance() {
    local pid=$1

    echo "=== 开始性能诊断 ==="

    # CPU分析
    echo "执行CPU分析..."
    perf record -F 99 -p "$pid" -g -- sleep 30
    perf report --stdio

    # 内存分析
    echo "执行内存分析..."
    pmap -x "$pid"

    # IO分析
    echo "执行IO分析..."
    iotop -b -n 10 -p "$pid"

    # 系统调用分析
    echo "执行系统调用分析..."
    strace -c -p "$pid"
}

# 网络问题排查
diagnose_network() {
    local host=$1
    local port=$2

    echo "=== 开始网络诊断 ==="

    # 连通性测试
    echo "检查连通性..."
    ping -c 4 "$host"

    # 路由追踪
    echo "路由追踪..."
    traceroute "$host"

    # 端口检查
    echo "检查端口..."
    nc -zv "$host" "$port"

    # TCP连接状态
    echo "TCP连接状态..."
    netstat -nat | grep "$port"
}

# 日志分析
analyze_logs() {
    local log_file=$1
    local pattern=$2

    echo "=== 开始日志分析 ==="

    # 错误统计
    echo "错误出现频率:"
    grep -i "error" "$log_file" | sort | uniq -c | sort -nr

    # 特定模式匹配
    echo "匹配特定模式:"
    grep -i "$pattern" "$log_file" | tail -n 50

    # 时间分布分析
    echo "时间分布:"
    awk '{print $1,$2}' "$log_file" | sort | uniq -c
}
