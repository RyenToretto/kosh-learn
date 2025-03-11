#!/bin/bash
# 文件名: auto_deploy.sh
# 功能：自动化部署系统

# 配置
APP_NAME="myapp"
DEPLOY_DIR="/var/www/$APP_NAME"
BACKUP_DIR="/var/www/backups"
REPO_URL="git@github.com:user/$APP_NAME.git"
LOG_FILE="/var/log/deploy.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理
handle_error() {
    log "错误: $1"
    # 发送告警
    send_alert "部署失败: $1"
    exit 1
}

# 检查环境
check_environment() {
    log "检查部署环境..."

    # 检查必需工具
    for tool in git npm node; do
        if ! command -v $tool &> /dev/null; then
            handle_error "未找到必需工具: $tool"
        fi
    done

    # 检查目录权限
    if [ ! -w "$DEPLOY_DIR" ]; then
        handle_error "没有部署目录的写入权限"
    fi
}

# 备份当前版本
backup_current() {
    log "备份当前版本..."

    local backup_name="$APP_NAME-$(date +%Y%m%d_%H%M%S)"
    if [ -d "$DEPLOY_DIR" ]; then
        tar czf "$BACKUP_DIR/$backup_name.tar.gz" -C "$DEPLOY_DIR" .
        if [ $? -ne 0 ]; then
            handle_error "备份失败"
        fi
    fi
}

# 部署新版本
deploy_new_version() {
    log "开始部署新版本..."

    # 克隆/更新代码
    if [ -d "$DEPLOY_DIR/.git" ]; then
        cd "$DEPLOY_DIR" && git pull
    else
        git clone "$REPO_URL" "$DEPLOY_DIR"
    fi

    # 安装依赖
    cd "$DEPLOY_DIR" || handle_error "无法进入部署目录"
    npm install || handle_error "依赖安装失败"

    # 构建应用
    npm run build || handle_error "构建失败"

    # 更新配置
    update_config

    # 重启服务
    restart_service
}

# 更新配置
update_config() {
    log "更新配置文件..."

    # 根据环境替换配置
    if [ "$ENV" = "production" ]; then
        cp config/prod.json config/current.json
    else
        cp config/dev.json config/current.json
    fi
}

# 重启服务
restart_service() {
    log "重启服务..."

    systemctl restart "$APP_NAME" || handle_error "服务重启失败"
}

# 健康检查
health_check() {
    log "执行健康检查..."

    local retries=5
    local wait_time=10
    local count=0

    while [ $count -lt $retries ]; do
        if curl -s "http://localhost:3000/health" | grep -q "ok"; then
            log "健康检查通过"
            return 0
        fi

        ((count++))
        log "健康检查失败，等待重试... ($count/$retries)"
        sleep $wait_time
    done

    handle_error "健康检查失败"
}

# 回滚函数
rollback() {
    log "开始回滚..."

    local latest_backup=$(ls -t "$BACKUP_DIR"/*.tar.gz | head -1)
    if [ -n "$latest_backup" ]; then
        rm -rf "$DEPLOY_DIR"/*
        tar xzf "$latest_backup" -C "$DEPLOY_DIR"
        restart_service
        log "回滚完成"
    else
        handle_error "没有可用的备份进行回滚"
    fi
}

# 主函数
main() {
    log "开始部署流程..."

    check_environment
    backup_current

    if deploy_new_version; then
        if health_check; then
            log "部署成功完成!"
        else
            log "部署后健康检查失败，开始回滚..."
            rollback
        fi
    else
        log "部署失败，开始回滚..."
        rollback
    fi
}

# 命令行参数处理
while getopts "e:" opt; do
    case $opt in
        e) ENV="$OPTARG" ;;
        *) echo "用法: $0 [-e environment]" >&2
           exit 1 ;;
    esac
done

# 执行部署
main
