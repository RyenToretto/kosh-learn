# security_check.sh

# 安全检查
security_check() {
    local report_file="security_report_$(date +%Y%m%d).txt"

    {
        echo "=== 安全检查报告 ==="
        echo "检查时间: $(date)"
        echo

        # 检查系统更新
        echo "== 系统更新状态 =="
        apt list --upgradable

        # 检查开放端口
        echo "== 开放端口 =="
        netstat -tuln

        # 检查登录失败
        echo "== 登录失败记录 =="
        grep "Failed password" /var/log/auth.log | tail -n 10

        # 检查可疑进程
        echo "== 可疑进程 =="
        ps aux | grep -i "suspicious"

        # 文件权限检查
        echo "== 危险的文件权限 =="
        find / -type f -perm -4000 2>/dev/null

    } > "$report_file"

    echo "安全检查报告已生成: $report_file"
}

# 防火墙配置
configure_firewall() {
    # 清除所有规则
    iptables -F

    # 设置默认策略
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # 允许已建立的连接
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # 允许本地回环
    iptables -A INPUT -i lo -j ACCEPT

    # 允许SSH
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    # 允许HTTP/HTTPS
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    # 保存规则
    iptables-save > /etc/iptables/rules.v4
}
