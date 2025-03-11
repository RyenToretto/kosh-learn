#!/bin/bash
# 高级错误处理

# 错误处理函数
error_handler() {
    local line_no=$1
    local error_code=$2
    local error_msg=$3

    echo "错误发生在第 $line_no 行"
    echo "错误代码: $error_code"
    echo "错误信息: $error_msg"

    # 发送错误通知
    notify_admin "脚本错误: $error_msg"

    exit $error_code
}

# 设置错误处理器
trap 'error_handler ${LINENO} $? "$BASH_COMMAND"' ERR

# 清理函数
cleanup() {
    # 清理临时文件
    rm -f /tmp/temp_*
    # 结束所有子进程
    jobs -p | xargs -r kill
}

# 设置清理陷阱
trap cleanup EXIT
