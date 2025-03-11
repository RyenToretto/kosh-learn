#!/bin/bash

# 监控特定进程
monitor_process() {
    if ! pgrep -x "$1" >/dev/null; then
        echo "进程 $1 未运行，正在重启..."
        $1 &
    fi
}

# 使用示例
while true; do
    monitor_process "nginx"
    sleep 60
done

# 系统资源监控脚本
monitor_system() {
    echo "===== 系统监控报告 ====="
    date

    # CPU使用率
    echo "CPU使用情况:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}'

    # 内存使用
    echo -e "\n内存使用情况:"
    free -m | grep Mem | awk '{print "使用率: " ($3/$2)*100 "%"}'

    # 磁盘使用
    echo -e "\n磁盘使用情况:"
    df -h | grep '^/dev'
}

# 定期执行并记录
while true; do
    monitor_system | tee -a system_monitor.log
    sleep 300
done
