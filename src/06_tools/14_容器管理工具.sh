#!/bin/bash
# 文件名: container_manager.sh
# 功能：Docker容器管理工具

# 配置
CONFIG_FILE="container_config.json"
LOG_FILE="/var/log/container_manager.log"
DOCKER_REGISTRY="registry.example.com"
BACKUP_DIR="/var/backups/containers"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 读取配置
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "错误: 配置文件不存在"
        exit 1
    fi

    # 使用jq解析JSON配置
    CONTAINERS=($(jq -r '.containers[].name' "$CONFIG_FILE"))
    IMAGES=($(jq -r '.containers[].image' "$CONFIG_FILE"))
    PORTS=($(jq -r '.containers[].port' "$CONFIG_FILE"))
}

# 检查Docker服务
check_docker() {
    if ! systemctl is-active --quiet docker; then
        log "Docker服务未运行，正在启动..."
        systemctl start docker
        sleep 5
    fi
}

# 部署容器
deploy_container() {
    local name=$1
    local image=$2
    local port=$3

    log "开始部署容器: $name"

    # 检查是否存在旧容器
    if docker ps -a | grep -q "$name"; then
        log "停止并删除旧容器..."
        docker stop "$name"
        docker rm "$name"
    fi

    # 拉取最新镜像
    log "拉取镜像: $image"
    docker pull "$DOCKER_REGISTRY/$image"

    # 启动新容器
    log "启动容器: $name"
    docker run -d \
        --name "$name" \
        -p "$port:$port" \
        --restart always \
        "$DOCKER_REGISTRY/$image"

    # 检查容器状态
    if docker ps | grep -q "$name"; then
        log "容器 $name 部署成功"
    else
        log "错误: 容器 $name 部署失败"
        return 1
    fi
}

# 备份容器
backup_container() {
    local name=$1
    local backup_path="$BACKUP_DIR/$name-$(date +%Y%m%d)"

    log "开始备份容器: $name"

    # 创建备份目录
    mkdir -p "$backup_path"

    # 导出容器配置
    docker inspect "$name" > "$backup_path/config.json"

    # 导出容器数据
    docker commit "$name" "$name-backup"
    docker save "$name-backup" > "$backup_path/image.tar"

    # 压缩备份
    tar czf "$backup_path.tar.gz" -C "$BACKUP_DIR" "$(basename "$backup_path")"
    rm -rf "$backup_path"

    log "容器 $name 备份完成"
}

# 监控容器状态
monitor_containers() {
    log "开始监控容器状态..."

    for container in "${CONTAINERS[@]}"; do
        local status=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)
        local uptime=$(docker inspect -f '{{.State.StartedAt}}' "$container" 2>/dev/null)

        echo "=== $container 状态 ===" >> "$LOG_FILE"
        echo "状态: $status" >> "$LOG_FILE"
        echo "运行时间: $uptime" >> "$LOG_FILE"

        # 检查资源使用
        docker stats "$container" --no-stream --format \
            "CPU: {{.CPUPerc}}, 内存: {{.MemPerc}}" >> "$LOG_FILE"
    done
}

# 清理旧容器和镜像
cleanup() {
    log "开始清理..."

    # 停止并删除未使用的容器
    docker ps -aq | xargs -r docker stop
    docker ps -aq | xargs -r docker rm

    # 删除未使用的镜像
    docker images -q | xargs -r docker rmi

    # 清理系统
    docker system prune -f

    log "清理完成"
}

# 容器健康检查
health_check() {
    local name=$1
    local port=$2

    log "检查容器 $name 健康状态..."

    # 检查容器运行状态
    if ! docker ps | grep -q "$name"; then
        log "错误: 容器 $name 未运行"
        return 1
    fi

    # 检查端口可访问性
    if ! curl -s "http://localhost:$port/health" > /dev/null; then
        log "错误: 容器 $name 健康检查失败"
        return 1
    fi

    log "容器 $name 运行正常"
    return 0
}

# 主函数
main() {
    log "容器管理工具启动..."

    load_config
    check_docker

    # 部署所有容器
    for i in "${!CONTAINERS[@]}"; do
        deploy_container "${CONTAINERS[$i]}" "${IMAGES[$i]}" "${PORTS[$i]}"
        backup_container "${CONTAINERS[$i]}"
    done

    # 监控容器
    monitor_containers

    # 执行健康检查
    for i in "${!CONTAINERS[@]}"; do
        if ! health_check "${CONTAINERS[$i]}" "${PORTS[$i]}"; then
            log "重启容器 ${CONTAINERS[$i]}"
            docker restart "${CONTAINERS[$i]}"
        fi
    done

    # 定期清理
    if [ "$(date +%u)" = "7" ]; then  # 每周日执行清理
        cleanup
    fi
}

# 解析命令行参数
case "$1" in
    start)
        main
        ;;
    backup)
        for container in "${CONTAINERS[@]}"; do
            backup_container "$container"
        done
        ;;
    monitor)
        monitor_containers
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "用法: $0 {start|backup|monitor|cleanup}"
        exit 1
        ;;
esac
