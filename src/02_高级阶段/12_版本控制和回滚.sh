# version_control.sh

# 版本管理
VERSION_FILE=".version"

get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

increment_version() {
    local current_version=$(get_current_version)
    local major=$(echo "$current_version" | cut -d. -f1)
    local minor=$(echo "$current_version" | cut -d. -f2)
    local patch=$(echo "$current_version" | cut -d. -f3)

    case "$1" in
        major) echo "$((major + 1)).0.0" ;;
        minor) echo "$major.$((minor + 1)).0" ;;
        patch) echo "$major.$minor.$((patch + 1))" ;;
        *) echo "$current_version" ;;
    esac
}

# 回滚功能
rollback_deployment() {
    log "WARN" "开始回滚部署"

    # 获取最新备份
    local latest_backup=$(ls -t "$BACKUP_DIR"/*.tar.gz | head -1)

    if [ -n "$latest_backup" ]; then
        # 停止服务
        systemctl stop app-service

        # 恢复备份
        rm -rf "$APP_DIR"/*
        tar xzf "$latest_backup" -C "$(dirname "$APP_DIR")"

        # 重启服务
        systemctl start app-service

        log "INFO" "回滚完成"
    else
        log "ERROR" "没有可用的备份"
        return 1
    fi
}
