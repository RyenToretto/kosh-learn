#!/bin/bash
# system_diagnostics.sh

# 系统信息收集
collect_system_info() {
    local output_dir="diagnostics_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$output_dir"

    {
        echo "=== 系统基本信息 ==="
        uname -a
        echo "CPU信息:"
        lscpu
        echo "内存信息:"
        free -h
        echo "磁盘信息:"
        df -h

        echo "=== 系统负载 ==="
        uptime
        echo "进程统计:"
        ps aux | wc -l
        echo "CPU使用Top10:"
        ps aux --sort=-%cpu | head -n 11

        echo "=== 网络状态 ==="
        netstat -tuln
        echo "网络连接数:"
        netstat -an | wc -l

        echo "=== 系统日志摘要 ==="
        tail -n 100 /var/log/syslog
    } > "$output_dir/system_info.txt"

    # 收集关键日志文件
    cp /var/log/{syslog,dmesg,auth.log} "$output_dir/"

    # 打包诊断文件
    tar czf "${output_dir}.tar.gz" "$output_dir"
    rm -rf "$output_dir"

    echo "诊断信息已保存到 ${output_dir}.tar.gz"
}
