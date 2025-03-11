# 审计日志配置
setup_audit_logging() {
    # 配置审计规则
    auditctl -w /etc/passwd -p wa -k identity
    auditctl -w /etc/group -p wa -k identity
    auditctl -w /etc/shadow -p wa -k identity

    # 记录所有执行的命令
    auditctl -a exit,always -F arch=b64 -S execve -k commands
}

# 安全日志记录
secure_logging() {
    local log_file=$1
    local message=$2
    local level=${3:-INFO}

    # 添加时间戳和其他元数据
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local hostname=$(hostname)
    local pid=$$

    # 记录日志
    printf '[%s] [%s] [%s] [%d] %s\n' \
           "$timestamp" "$level" "$hostname" "$pid" "$message" \
           >> "$log_file"

    # 设置日志文件权限
    chmod 640 "$log_file"
}

# 安全日志记录
log_security_event() {
    local event=$1
    local severity=$2
    local details=$3

    # 使用 logger 写入系统日志
    logger -p "auth.$severity" \
           -t "[Security]" \
           "Event: $event, Details: $details"

    # 同时写入安全日志文件
    printf "[%s] %s: %s - %s\n" \
           "$(date '+%Y-%m-%d %H:%M:%S')" \
           "$severity" \
           "$event" \
           "$details" >> "/var/log/security.log"
}

# 审计跟踪
audit_command() {
    local cmd=$1
    shift
    local args=("$@")

    # 记录命令执行
    log_security_event \
        "Command Execution" \
        "info" \
        "Command: $cmd ${args[*]}, User: $USER, PWD: $PWD"

    # 执行命令并记录结果
    local output
    if ! output=$("$cmd" "${args[@]}" 2>&1); then
        log_security_event \
            "Command Failed" \
            "err" \
            "Exit Code: $?, Output: $output"
        return 1
    fi
}
