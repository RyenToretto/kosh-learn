# secure_communication.sh

# SSH安全配置
configure_ssh_security() {
    local ssh_config="/etc/ssh/sshd_config"

    # 备份原配置
    cp "$ssh_config" "${ssh_config}.bak"

    # 设置安全参数
    {
        echo "PermitRootLogin no"
        echo "PasswordAuthentication no"
        echo "PubkeyAuthentication yes"
        echo "Protocol 2"
        echo "X11Forwarding no"
        echo "MaxAuthTries 3"
    } >> "$ssh_config"

    # 重启SSH服务
    systemctl restart sshd
}

# 安全的文件传输
secure_file_transfer() {
    local source_file=$1
    local dest_host=$2
    local dest_path=$3
    local ssh_key=$4

    # 使用rsync通过SSH传输
    rsync -avz -e "ssh -i $ssh_key" \
        "$source_file" \
        "${dest_host}:${dest_path}"
}
