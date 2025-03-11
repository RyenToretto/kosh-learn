#!/bin/bash
# 配置管理模块

# 加载配置
load_config() {
    local config_file=$1
    if [ ! -f "$config_file" ]; then
        echo "错误: 配置文件不存在" >&2
        exit 1
    fi

    # 源码导入配置
    source "$config_file"

    # 验证必需的配置项
    validate_config
}

# 验证配置
validate_config() {
    local required_vars=("DB_HOST" "DB_USER" "DB_PASS")

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "错误: 配置项 $var 未设置" >&2
            exit 1
        fi
    done
}
