# environment.sh

# 环境配置管理
ENVIRONMENTS=("dev" "staging" "prod")
CONFIG_DIR="configs"

# 生成环境配置
generate_config() {
    local env=$1
    local template="$CONFIG_DIR/template.conf"
    local output="$CONFIG_DIR/$env.conf"

    log "INFO" "生成 $env 环境配置"

    # 基于模板生成配置
    envsubst < "$template" > "$output"

    # 加密敏感信息
    if [ "$env" = "prod" ]; then
        encrypt_sensitive_data "$output"
    fi
}

# 应用配置
apply_config() {
    local env=$1
    local config_file="$CONFIG_DIR/$env.conf"

    if [ ! -f "$config_file" ]; then
        log "ERROR" "配置文件不存在: $config_file"
        return 1
    fi

    # 替换配置文件
    cp "$config_file" "$APP_DIR/config.conf"

    # 重新加载配置
    systemctl reload app-service
}
