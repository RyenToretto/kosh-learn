# 安全的密码处理
read_password() {
    local prompt=$1
    local password

    # 禁用回显
    stty -echo
    read -p "$prompt" password
    stty echo
    echo

    # 验证密码强度
    if ! check_password_strength "$password"; then
        return 1
    }

    echo "$password"
}

# 加密存储
encrypt_data() {
    local data=$1
    local key_file=$2

    # 使用 GPG 加密
    gpg --encrypt \
        --recipient-file "$key_file" \
        --output "${data}.gpg" \
        "$data"
}

# 安全的配置文件处理
read_config() {
    local config_file=$1

    # 检查文件权限
    if [ "$(stat -c %a "$config_file")" != "600" ]; then
        chmod 600 "$config_file"
    }

    # 读取配置
    source "$config_file"
}
