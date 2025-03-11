# debug_tools.sh

# 调试模式设置
enable_debug() {
    set -x  # 启用命令追踪
    set -v  # 显示输入行

    # 设置调试输出
    exec 5> debug.log
    BASH_XTRACEFD="5"
}

# 函数调用追踪
trace_function() {
    local func_name=$1
    shift

    echo "=== 函数调用追踪 ===" >> debug.log
    echo "函数名: $func_name" >> debug.log
    echo "参数: $@" >> debug.log
    echo "调用时间: $(date)" >> debug.log

    # 执行函数并捕获输出
    local output
    output=$("$func_name" "$@" 2>&1)
    local status=$?

    echo "返回值: $status" >> debug.log
    echo "输出:" >> debug.log
    echo "$output" >> debug.log
    echo "====================" >> debug.log

    return $status
}
