# 文件读写优化
optimize_io() {
    local input=$1

    # 使用缓冲读取
    while IFS= read -r -n 8192 block; do
        process_block "$block"
    done < "$input"
}

# 简单的网络监控
monitor_network() {
    local interface=$1
    local interval=$2

    while true; do
        rx_before=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        tx_before=$(cat /sys/class/net/$interface/statistics/tx_bytes)
        sleep $interval
        rx_after=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        tx_after=$(cat /sys/class/net/$interface/statistics/tx_bytes)

        rx_rate=$((($rx_after - $rx_before) / $interval))
        tx_rate=$((($tx_after - $tx_before) / $interval))

        echo "接收速率: $(($rx_rate/1024)) KB/s"
        echo "发送速率: $(($tx_rate/1024)) KB/s"
    done
}

# TCP端口扫描
scan_ports() {
    local host=$1
    local start_port=$2
    local end_port=$3

    for port in $(seq $start_port $end_port); do
        (echo >/dev/tcp/$host/$port) >/dev/null 2>&1 && \
            echo "端口 $port 开放"
    done
}
