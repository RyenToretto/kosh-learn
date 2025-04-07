# 性能监控系统
performance_monitor() {
    local pid=$1
    local output_file=$2

    # 记录性能数据
    while true; do
        {
            echo "=== $(date) ==="
            echo "CPU使用率:"
            ps -p "$pid" -o %cpu=

            echo "内存使用:"
            ps -p "$pid" -o rss=

            echo "磁盘IO:"
            iotop -b -n 1 -p "$pid" | tail -n 1

            echo "打开文件数:"
            lsof -p "$pid" | wc -l

            echo "------------------------"
        } >> "$output_file"

        sleep 5
    done
}

# 性能报告生成器
generate_performance_report() {
    local data_file=$1
    local report_file=$2

    {
        echo "性能分析报告"
        echo "生成时间: $(date)"
        echo

        echo "== CPU使用统计 =="
        awk '/CPU使用率:/{print $0}' "$data_file" | \
            sort -n | \
            awk '{sum+=$1} END {print "平均: "sum/NR"%"}'

        echo "== 内存使用统计 =="
        awk '/内存使用:/{print $1}' "$data_file" | \
            sort -n | \
            awk '{sum+=$1} END {print "平均: "sum/NR"KB"}'

        echo "== IO操作统计 =="
        grep "磁盘IO:" -A 1 "$data_file" | \
            awk 'NR%2==0{print $0}'

    } > "$report_file"
}

performance_monitor 1 2
