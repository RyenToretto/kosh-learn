#!/bin/bash
# 文件名: performance_test.sh
# 功能：系统性能测试工具

# 配置
TEST_DURATION=300  # 测试持续时间（秒）
REPORT_DIR="/var/reports/performance"
SAMPLES_INTERVAL=5 # 采样间隔（秒）

# 初始化测试
init_test() {
    mkdir -p "$REPORT_DIR"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    TEST_LOG="$REPORT_DIR/test_$timestamp.log"

    echo "开始性能测试..." > "$TEST_LOG"
    echo "测试时间: $(date)" >> "$TEST_LOG"
}

# CPU性能测试
test_cpu() {
    echo "执行CPU性能测试..."

    echo "=== CPU 测试 ===" >> "$TEST_LOG"
    local start_time=$(date +%s)
    local samples=()

    while [ $(date +%s) -lt $((start_time + TEST_DURATION)) ]; do
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
        samples+=("$cpu_usage")
        sleep "$SAMPLES_INTERVAL"
    done

    # 计算统计数据
    local total=0
    local max=0
    for sample in "${samples[@]}"; do
        total=$(echo "$total + $sample" | bc)
        if (( $(echo "$sample > $max" | bc -l) )); then
            max=$sample
        fi
    done

    local avg=$(echo "scale=2; $total / ${#samples[@]}" | bc)

    echo "平均CPU使用率: $avg%" >> "$TEST_LOG"
    echo "最大CPU使用率: $max%" >> "$TEST_LOG"
}

# 内存性能测试
test_memory() {
    echo "执行内存性能测试..."

    echo "=== 内存测试 ===" >> "$TEST_LOG"
    local start_time=$(date +%s)

    while [ $(date +%s) -lt $((start_time + TEST_DURATION)) ]; do
        free -m | grep Mem >> "$TEST_LOG"
        sleep "$SAMPLES_INTERVAL"
    done
}

# 磁盘性能测试
test_disk() {
    echo "执行磁盘性能测试..."

    echo "=== 磁盘性能测试 ===" >> "$TEST_LOG"

    # 写入测试
    dd if=/dev/zero of=/tmp/test_file bs=1M count=1024 2>> "$TEST_LOG"

    # 读取测试
    dd if=/tmp/test_file of=/dev/null bs=1M 2>> "$TEST_LOG"

    # 清理
    rm -f /tmp/test_file
}

# 网络性能测试
test_network() {
    echo "执行网络性能测试..."

    echo "=== 网络性能测试 ===" >> "$TEST_LOG"

    # 测试网络延迟
    ping -c 10 8.8.8.8 >> "$TEST_LOG"

    # 测试下载速度
    wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip 2>> "$TEST_LOG"
}

# 生成报告
generate_report() {
    local report_file="$REPORT_DIR/report_$(date +%Y%m%d_%H%M%S).html"

    # 创建图表
    gnuplot << EOF
    set terminal png
    set output "$REPORT_DIR/cpu_usage.png"
    plot "$TEST_LOG" using 1:2 with lines title "CPU Usage"
EOF

    # 生成HTML报告
    cat << EOF > "$report_file"
<!DOCTYPE html>
<html>
<head>
    <title>性能测试报告</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .chart { width: 800px; }
    </style>
</head>
<body>
    <h1>性能测试报告</h1>
    <h2>测试时间: $(date)</h2>
    <div class="chart">
        <img src="cpu_usage.png" alt="CPU Usage Chart">
    </div>
    <pre>
$(cat "$TEST_LOG")
    </pre>
</body>
</html>
EOF
}

# 主函数
main() {
    init_test
    test_cpu
    test_memory
    test_disk
    test_network
    generate_report

    echo "性能测试完成，报告已生成在 $REPORT_DIR"
}

# 执行测试
main
