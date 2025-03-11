# monitoring_alerts.sh

# 监控配置
ALERT_EMAIL="admin@example.com"
ALERT_WEBHOOK="https://webhook.example.com/alert"
THRESHOLD_CPU=80
THRESHOLD_MEMORY=90
THRESHOLD_DISK=85

# 发送告警
send_alert() {
    local level=$1
    local message=$2

    # 记录告警
    logger -t "ALERT" "[$level] $message"

    # 发送邮件
    echo "$message" | mail -s "[$level] 系统告警" "$ALERT_EMAIL"

    # 发送webhook
    curl -X POST "$ALERT_WEBHOOK" \
         -H "Content-Type: application/json" \
         -d "{\"level\":\"$level\",\"message\":\"$message\"}"
}

# 系统监控
monitor_system() {
    while true; do
        # CPU监控
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
        if [ "$cpu_usage" -gt "$THRESHOLD_CPU" ]; then
            send_alert "WARNING" "CPU使用率过高: ${cpu_usage}%"
        fi

        # 内存监控
        local mem_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
        if [ "$mem_usage" -gt "$THRESHOLD_MEMORY" ]; then
            send_alert "WARNING" "内存使用率过高: ${mem_usage}%"
        fi

        # 磁盘监控
        local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
        if [ "$disk_usage" -gt "$THRESHOLD_DISK" ]; then
            send_alert "WARNING" "磁盘使用率过高: ${disk_usage}%"
        fi

        sleep 300  # 5分钟检查一次
    done
}
