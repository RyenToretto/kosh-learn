# coverage.sh

# 代码覆盖率分析器
analyze_coverage() {
    local script_file=$1
    local temp_file=$(mktemp)

    # 插入跟踪代码
    awk '
        BEGIN {line_count=0}
        {
            print "echo \"执行行 " NR "\" >> coverage.log"
            print $0
            line_count++
        }
        END {print "# 总行数: " line_count}
    ' "$script_file" > "$temp_file"

    # 执行带跟踪的脚本
    bash "$temp_file"

    # 分析覆盖率
    local total_lines=$(grep -c . "$script_file")
    local covered_lines=$(sort -u coverage.log | wc -l)
    local coverage=$((covered_lines * 100 / total_lines))

    echo "代码覆盖率分析:"
    echo "总行数: $total_lines"
    echo "已覆盖行数: $covered_lines"
    echo "覆盖率: ${coverage}%"

    # 清理临时文件
    rm -f "$temp_file" coverage.log
}
