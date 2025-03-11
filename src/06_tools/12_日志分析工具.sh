#!/bin/bash
# 文件名: log_analyzer.sh
# 功能：日志分析工具

# 配置
LOG_DIR="/var/log"
REPORT_DIR="/var/reports"
PATTERN_FILE="patterns.conf"
EMAIL_REPORT="admin@example.com"

# 加载分析模式
declare -A PATTERNS
load_patterns() {
    while IFS=':' read -r name pattern; do
        PATTERNS["$name"]="$pattern"
    done < "$PATTERN_FILE"
}

# 分析日志
analyze_log() {
    local log_file=$1
    local report_file="$REPORT_DIR/$(basename "$log_file")_report.txt"

    echo "=== 日志分析报告 ===" > "$report_file"
    echo "日志文件: $log_file" >> "$report_file"
    echo "分析时间: $(date)" >> "$report_file"
    echo "===================" >> "$report_file"

    # 分析各种模式
    for name in "${!PATTERNS[@]}"; do
        echo -e "\n=== $name 分析 ===" >> "$report_file"
        grep -E "${PATTERNS[$name]}" "$log_file" | \
        awk '{count[$0]++} END {for (l in count) print count[l] "\t" l}' | \
        sort -rn >> "$report_file"
    done

    # 统计总体情况
    echo -e "\n=== 总体统计 ===" >> "$report_file"
    echo "总行数: $(wc -l < "$log_file")" >> "$report_file"
    echo "错误数: $(grep -c "ERROR" "$log_file")" >> "$report_file"
    echo "警告数: $(grep -c "WARN" "$log_file")" >> "$report_file"

    return "$report_file"
}

# 生成图表
generate_charts() {
    local report_file=$1

    # 使用 gnuplot 生成图表
    gnuplot << EOF
    set terminal png
    set output "$REPORT_DIR/errors_over_time.png"
    set title "错误趋势"
    set xlabel "时间"
    set ylabel "错误数"
    plot "$report_file" using 1:2 with lines
EOF
}

# 发送报告
send_report() {
    local report_file=$1

    # 转换为HTML格式
    local html_report="${report_file%.txt}.html"

    cat << EOF > "$html_report"
<html>
<head><title>日志分析报告</title></head>
<body>
<pre>
$(cat "$report_file")
</pre>
<img src="errors_over_time.png" alt="错误趋势"/>
</body>
</html>
EOF

    # 发送邮件
    mail -s "日志分析报告 $(date +%Y-%m-%d)" \
         -a "$REPORT_DIR/errors_over_time.png" \
         "$EMAIL_REPORT" < "$html_report"
}

# 主函数
main() {
    load_patterns

    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            analyze_log "$log_file"
            generate_charts "$?"
            send_report "$?"
        fi
    done
}

# 执行分析
main
