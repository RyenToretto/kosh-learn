# auto_repair.sh

# 服务修复
repair_service() {
    local service_name=$1

    echo "尝试修复服务: $service_name"

    # 检查服务状态
    if ! systemctl is-active "$service_name" >/dev/null; then
        echo "服务未运行，尝试重启..."
        systemctl restart "$service_name"

        # 等待服务启动
        sleep 5

        if systemctl is-active "$service_name" >/dev/null; then
            echo "服务已成功重启"
        else
            echo "服务重启失败，尝试修复..."
            systemctl reset-failed "$service_name"
            systemctl restart "$service_name"
        fi
    fi
}

# 磁盘空间修复
repair_disk_space() {
    local threshold=90
    local path=$1

    echo "检查磁盘空间..."

    # 获取使用率
    local usage=$(df -h "$path" | awk 'NR==2 {print $5}' | cut -d'%' -f1)

    if [ "$usage" -gt "$threshold" ]; then
        echo "磁盘使用率过高: $usage%"

        # 清理日志
        echo "清理旧日志文件..."
        find /var/log -type f -name "*.gz" -mtime +30 -delete

        # 清理临时文件
        echo "清理临时文件..."
        find /tmp -type f -atime +7 -delete

        # 清理软件包缓存
        echo "清理软件包缓存..."
        apt-get clean

        echo "空间清理完成"
    fi
}
