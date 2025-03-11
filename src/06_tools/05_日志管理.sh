#!/bin/bash
# 高级日志管理

# 日志级别
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
LOG_LEVEL="INFO"

# 日志轮转
rotate_logs() {
    local log_file=$1
    local max_size=$((10*1024*1024))  # 10MB

    if [ -f "$log_file" ]; then
        local size=$(stat -f %z "$log_file")
        if [ $size -ge $max_size ]; then
            mv "$log_file" "$log_file.$(date +%Y%m%d-%H%M%S)"
            gzip "$log_file".* &
        fi
    fi
}

# 高级日志函数
log() {
    local level=$1
    shift
    local message=$@

    if [ ${LOG_LEVELS[$level]} -ge ${LOG_LEVELS[$LOG_LEVEL]} ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> app.log
        rotate_logs app.log
    fi
}
