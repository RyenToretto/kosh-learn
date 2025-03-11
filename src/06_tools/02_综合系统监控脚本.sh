#!/bin/bash


# 配置
ALERT_EMAIL="admin@example.com"
LOG_FILE="/var/log/system_monitor.log"
THRESHOLD_CPU=80
THRESHOLD_MEM=90
THRESHOLD_DISK=85

# 日志函数
log() {
    local level=$1
    shift
    local message=$@
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

# CPU监控
monitor_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if [ "$cpu_usage" -gt "$THRESHOLD_CPU" ]; then
        log "WARNING" "CPU使用率过高: ${cpu_usage}%"
        send_alert "CPU告警" "CPU使用率: ${cpu_usage}%"
    fi
    return "$cpu_usage"
}

# 内存监控
monitor_memory() {
    local mem_usage=$(free | grep Mem | awk '{print ($3/$2) * 100}' | cut -d. -f1)
    if [ "$mem_usage" -gt "$THRESHOLD_MEM" ]; then
        log "WARNING" "内存使用率过高: ${mem_usage}%"
        send_alert "内存告警" "内存使用率: ${mem_usage}%"
    fi
    return "$mem_usage"
}

# 磁盘监控
monitor_disk() {
    local disk_usage=$(df -h | grep /$ | awk '{print $5}' | cut -d% -f1)
    if [ "$disk_usage" -gt "$THRESHOLD_DISK" ]; then
        log "WARNING" "磁盘使用率过高: ${disk_usage}%"
        send_alert "磁盘告警" "磁盘使用率: ${disk_usage}%"
    fi
    return "$disk_usage"
}

# 发送告警
send_alert() {
    local subject=$1
    local message=$2
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
}

# 生成报告
generate_report() {
    cat << EOF > report.html
<html>
<head><title>系统监控报告</title></head>
<body>
<h1>系统监控报告 - $(date)</h1>
<h2>系统资源使用情况</h2>
<ul>
    <li>CPU使用率: ${cpu_usage}%</li>
    <li>内存使用率: ${mem_usage}%</li>
    <li>磁盘使用率: ${disk_usage}%</li>
</ul>
</body>
</html>
EOF
}

# 主循环
main() {
    while true; do
        monitor_cpu
        cpu_usage=$?

        monitor_memory
        mem_usage=$?

        monitor_disk
        disk_usage=$?

        generate_report

        log "INFO" "监控检查完成"
        sleep 300  # 每5分钟检查一次
    done
}

# 启动监控
main &

