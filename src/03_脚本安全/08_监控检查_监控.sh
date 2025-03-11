# monitoring.sh

# 健康检查
health_check() {
    local url=$1
    local timeout=${2:-5}

    # HTTP 检查
    if curl -s --max-time "$timeout" "$url" >/dev/null; then
        return 0
    fi
    return 1
}

# 服务监控
monitor_service() {
    while true; do
        if ! health_check "$APP_URL"; then
            log "ERROR" "服务不可用"
            send_alert "服务不可用: $APP_URL"

            # 尝试自动恢复
            systemctl restart app-service
        fi
        sleep 60
    done
}

# 资源监控
monitor_resources() {
    # 检查磁盘空间
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    if [ "$disk_usage" -gt 90 ]; then
        log "WARN" "磁盘空间不足: $disk_usage%"
        send_alert "磁盘空间警告: $disk_usage%"
    fi

    # 检查内存使用
    local memory_usage=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
    if [ "$memory_usage" -gt 90 ]; then
        log "WARN" "内存使用过高: $memory_usage%"
        send_alert "内存使用警告: $memory_usage%"
    fi
}
