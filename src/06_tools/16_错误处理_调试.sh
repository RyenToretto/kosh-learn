# 高级错误处理
set -euo pipefail

trap 'error_handler $? $LINENO' ERR

error_handler() {
    local exit_code=$1
    local line_number=$2
    local script_name=$(basename "$0")
    
    echo "错误: $script_name 第 $line_number 行"
    echo "错误代码: $exit_code"
    echo "堆栈跟踪:"
    local frame=0
    while caller $frame; do
        ((frame++))
    done
    
    exit $exit_code
}

# 调试函数
debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo "[DEBUG] $*" >&2
    fi
}

# 性能分析
profile_function() {
    local start_time=$(date +%s%N)
    "$@"
    local end_time=$(date +%s%N)
    local duration=$((($end_time - $start_time)/1000000))
    echo "函数 $1 执行时间: ${duration}ms"
}