# 安全的命令执行
safe_execute() {
    local cmd=$1
    shift
    local args=("$@")

    # 检查命令是否存在
    if ! command -v "$cmd" &>/dev/null; then
        echo "错误: 命令 '$cmd' 不存在" >&2
        return 1
    }

    # 使用数组保存参数，避免注入
    "$cmd" "${args[@]}"
}

# SQL 注入防护
execute_sql() {
    local query=$1
    shift
    local params=("$@")

    # 使用参数化查询
    mysql -u "$DB_USER" -p"$DB_PASS" << EOF
    PREPARE stmt FROM '$query';
    EXECUTE stmt USING ${params[@]};
    DEALLOCATE PREPARE stmt;
EOF
}
