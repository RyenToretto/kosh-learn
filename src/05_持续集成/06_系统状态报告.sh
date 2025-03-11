# report_generator.sh

# 生成系统状态报告
generate_status_report() {
    local report_file="status_report_$(date +%Y%m%d).html"

    # 创建HTML报告
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>系统状态报告 - $(date)</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .warning { color: orange; }
        .critical { color: red; }
        .normal { color: green; }
    </style>
</head>
<body>
    <h1>系统状态报告</h1>
    <p>生成时间: $(date)</p>

    <h2>系统概况</h2>
    <pre>
$(uptime)
    </pre>

    <h2>资源使用情况</h2>
    <pre>
CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
内存: $(free -h | grep Mem | awk '{print $3 "/" $2}')
磁盘: $(df -h / | awk 'NR==2 {print $5}')
    </pre>

    <h2>服务状态</h2>
    <pre>
$(systemctl list-units --type=service --state=running)
    </pre>

    <h2>最近的系统日志</h2>
    <pre>
$(tail -n 50 /var/log/syslog)
    </pre>
</body>
</html>
EOF

    echo "状态报告已生成: $report_file"
}
