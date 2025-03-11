#!/bin/bash
# deploy.sh

# 部署配置
CONFIG_FILE="deploy.conf"
LOG_FILE="deploy.log"
BACKUP_DIR="backups"
APP_DIR="/var/www/app"

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "错误: 配置文件不存在" >&2
        exit 1
    fi
}

# 记录日志
log() {
    local level=$1
    shift
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo "$message" | tee -a "$LOG_FILE"
}

# 备份当前版本
backup_current_version() {
    local backup_name="backup_$(date '+%Y%m%d_%H%M%S')"
    log "INFO" "开始备份当前版本: $backup_name"

    mkdir -p "$BACKUP_DIR"
    if tar czf "$BACKUP_DIR/$backup_name.tar.gz" -C "$(dirname "$APP_DIR")" "$(basename "$APP_DIR")"; then
        log "INFO" "备份完成: $backup_name"
    else
        log "ERROR" "备份失败"
        return 1
    fi
}

# 部署新版本
deploy_new_version() {
    local version=$1
    log "INFO" "开始部署版本: $version"

    # 停止服务
    systemctl stop app-service

    # 部署新代码
    rsync -av --delete "releases/$version/" "$APP_DIR/"

    # 更新配置
    apply_config "$version"

    # 设置权限
    chown -R www-data:www-data "$APP_DIR"

    # 启动服务
    systemctl start app-service

    # 检查服务状态
    if systemctl is-active app-service >/dev/null; then
        log "INFO" "部署成功"
    else
        log "ERROR" "部署失败"
        rollback_deployment
        return 1
    fi
}
