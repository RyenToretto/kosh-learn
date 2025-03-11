#!/bin/bash
# 文件名: security_audit.sh
# 功能：系统安全审计工具

# 配置
AUDIT_LOG="/var/log/security_audit.log"
REPORT_DIR="/var/reports/security"
ALERT_EMAIL="security@example.com"

# 初始化
init_audit() {
    mkdir -p "$REPORT_DIR"
    echo "=== 安全审计报告 $(date) ===" > "$AUDIT_LOG"
}

# 检查用户和权限
audit_users() {
    echo "正在检查用户和权限..."

    # 检查root权限账户
    echo "=== Root权限用户 ===" >> "$AUDIT_LOG"
    awk -F: '$3 == 0 {print $1}' /etc/passwd >> "$AUDIT_LOG"

    # 检查空密码账户
    echo "=== 空密码账户 ===" >> "$AUDIT_LOG"
    awk -F: '($2 == "" || $2 == " ") {print $1}' /etc/shadow >> "$AUDIT_LOG"

    # 检查最近登录记录
    echo "=== 最近登录记录 ===" >> "$AUDIT_LOG"
    last | head -n 10 >> "$AUDIT_LOG"
}

# 检查系统服务
audit_services() {
    echo "正在检查系统服务..."

    echo "=== 运行中的服务 ===" >> "$AUDIT_LOG"
    systemctl list-units --type=service --state=running >> "$AUDIT_LOG"

    echo "=== 开放的端口 ===" >> "$AUDIT_LOG"
    netstat -tuln >> "$AUDIT_LOG"
}

# 检查文件权限
audit_files() {
    echo "正在检查文件权限..."

    echo "=== SUID文件 ===" >> "$AUDIT_LOG"
    find / -type f -perm -4000 2>/dev/null >> "$AUDIT_LOG"

    echo "=== 全局可写文件 ===" >> "$AUDIT_LOG"
    find / -type f -perm -0002 2>/dev/null >> "$AUDIT_LOG"
}

# 检查系统日志
audit_logs() {
    echo "正在分析系统日志..."

    echo "=== 失败的登录尝试 ===" >> "$AUDIT_LOG"
    grep "Failed password" /var/log/auth.log >> "$AUDIT_LOG"

    echo "=== 可疑的sudo使用 ===" >> "$AUDIT_LOG"
    grep "sudo:" /var/log/auth.log >> "$AUDIT_LOG"
}

# 漏洞扫描
scan_vulnerabilities() {
    echo "正在执行漏洞扫描..."

    # 检查系统更新
    echo "=== 可用更新 ===" >> "$AUDIT_LOG"
    apt list --upgradable 2>/dev/null >> "$AUDIT_LOG"

    # 检查常见漏洞
    echo "=== 常见漏洞检查 ===" >> "$AUDIT_LOG"
    for vuln in shellshock heartbleed; do
        if check_vulnerability "$vuln"; then
            echo "发现漏洞: $vuln" >> "$AUDIT_LOG"
        fi
    done
}

# 生成报告
generate_report() {
    local report_file="$REPORT_DIR/audit_report_$(date +%Y%m%d).html"

    cat << EOF > "$report_file"
<!DOCTYPE html>
<html>
<head>
    <title>安全审计报告</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .warning { color: red; }
        .info { color: blue; }
    </style>
</head>
<body>
    <h1>安全审计报告</h1>
    <h2>生成时间: $(date)</h2>
    <pre>
$(cat "$AUDIT_LOG")
    </pre>
</body>
</html>
EOF

    # 发送报告
    mail -s "安全审计报告 $(date +%Y-%m-%d)" \
         -a "$report_file" "$ALERT_EMAIL" < /dev/null
}

# 主函数
main() {
    init_audit
    audit_users
    audit_services
    audit_files
    audit_logs
    scan_vulnerabilities
    generate_report

    echo "安全审计完成，报告已发送至 $ALERT_EMAIL"
}

# 执行审计
main
