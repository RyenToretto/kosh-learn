# post_deploy.sh

# 部署后处理
post_deploy() {
    local version=$1

    # 清理旧备份
    cleanup_old_backups

    # 更新文档
    update_documentation "$version"

    # 发送部署通知
    send_deployment_notification "$version"
}

# 清理旧备份
cleanup_old_backups() {
    local max_backups=5
    local backup_count=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)

    if [ "$backup_count" -gt "$max_backups" ]; then
        ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +$((max_backups + 1)) | xargs rm -f
        log "INFO" "已清理旧备份"
    fi
}

# 发送部署通知
send_deployment_notification() {
    local version=$1
    local message="版本 $version 已成功部署到 $ENVIRONMENT 环境"

    # 发送邮件通知
    echo "$message" | mail -s "部署通知" "$NOTIFY_EMAIL"

    # 发送到企业微信
    curl -X POST "$WEBHOOK_URL" \
         -H 'Content-Type: application/json' \
         -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$message\"}}"
}
