#!/bin/bash
# 网络连接监控

# 检查端口
check_port() {
    local host=$1
    local port=$2
    nc -zv $host $port &>/dev/null
    if [ $? -eq 0 ]; then
        echo "$host:$port 端口开放"
    else
        echo "$host:$port 端口关闭"
    fi
}

# 监控网络连接
monitor_network() {
    echo "活动的网络连接:"
    netstat -ant | awk 'NR>2{print $5,$6}'

    echo "网络接口状态:"
    ip addr show
}
