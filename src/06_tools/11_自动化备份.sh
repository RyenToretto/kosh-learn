#!/bin/bash
# 文件名: backup_system.sh
# 功能：自动化备份系统

# 配置
BACKUP_DIR="/backup"
MYSQL_USER="root"
MYSQL_PASS="your_password"
BACKUP_RETENTION_DAYS=7
SOURCE_DIRS=("/etc" "/var/www" "/home")
DATABASES=("db1" "db2" "db3")

# 初始化
init_backup() {
    # 创建备份目录
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        chmod 700 "$BACKUP_DIR"
    fi

    # 创建日期子目录
    BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_DATE"
    mkdir -p "$BACKUP_PATH"
}

# 备份文件系统
backup_files() {
    echo "开始备份文件系统..."

    for dir in "${SOURCE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            dir_name=$(basename "$dir")
            tar czf "$BACKUP_PATH/${dir_name}.tar.gz" "$dir" 2>/dev/null

            if [ $? -eq 0 ]; then
                echo "成功备份 $dir"
            else
                echo "备份 $dir 失败"
            fi
        fi
    done
}

# 备份数据库
backup_databases() {
    echo "开始备份数据库..."

    for db in "${DATABASES[@]}"; do
        mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASS" "$db" > \
            "$BACKUP_PATH/${db}.sql" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "成功备份数据库 $db"
            # 压缩备份
            gzip "$BACKUP_PATH/${db}.sql"
        else
            echo "备份数据库 $db 失败"
        fi
    done
}

# 清理旧备份
cleanup_old_backups() {
    echo "清理旧备份..."

    find "$BACKUP_DIR" -type d -mtime +$BACKUP_RETENTION_DAYS -exec rm -rf {} \;
}

# 验证备份
verify_backup() {
    echo "验证备份..."

    local error_count=0

    # 检查文件备份
    for dir in "${SOURCE_DIRS[@]}"; do
        dir_name=$(basename "$dir")
        if [ ! -f "$BACKUP_PATH/${dir_name}.tar.gz" ]; then
            echo "错误: ${dir_name} 备份文件不存在"
            ((error_count++))
        fi
    done

    # 检查数据库备份
    for db in "${DATABASES[@]}"; do
        if [ ! -f "$BACKUP_PATH/${db}.sql.gz" ]; then
            echo "错误: ${db} 数据库备份不存在"
            ((error_count++))
        fi
    done

    return $error_count
}

# 主函数
main() {
    echo "开始备份过程..."

    init_backup
    backup_files
    backup_databases
    verify_backup

    if [ $? -eq 0 ]; then
        echo "备份完成，开始清理旧备份"
        cleanup_old_backups
        echo "备份过程成功完成"
    else
        echo "备份过程中发生错误"
    fi
}

# 执行备份
main > "$BACKUP_DIR/backup_$(date +%Y%m%d).log" 2>&1
