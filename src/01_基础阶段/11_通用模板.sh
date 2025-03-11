#!/bin/bash
#
# 脚本名称: script_template.sh
# 描述: 这是一个基础的脚本模板
# 作者: Your Name
# 创建日期: $(date +%F)
# 版本: 1.0

# 严格模式设置
set -euo pipefail
IFS=$'\n\t'

# 全局变量
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.*}.log"

# 配置
CONFIG_FILE="${SCRIPT_DIR}/config.ini"
DEBUG=false

# 日志函数
log() {
    local level=$1
    shift
    local message=$*
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# 用法说明
usage() {
    cat << EOF
用法: $SCRIPT_NAME [选项] <参数>

选项:
    -h, --help      显示此帮助信息
    -c, --config    指定配置文件
    -d, --debug     启用调试模式
    -v, --verbose   显示详细输出

示例:
    $SCRIPT_NAME --config /path/to/config.ini
EOF
    exit 1
}

# 参数解析
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--debug)
                DEBUG=true
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                log "ERROR" "未知参数: $1"
                usage
                ;;
        esac
    done
}

# 初始化
init() {
    # 检查必要条件
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "ERROR" "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi

    # 创建日志目录
    mkdir -p "$(dirname "$LOG_FILE")"

    # 加载配置
    source "$CONFIG_FILE"
}

# 清理函数
cleanup() {
    local exit_code=$?
    log "INFO" "脚本执行完成，退出代码: $exit_code"
    # 在这里添加清理代码
}

# 主函数
main() {
    log "INFO" "开始执行脚本"

    # 在这里添加主要逻辑

    log "INFO" "脚本执行结束"
}

# 错误处理
trap cleanup EXIT
trap 'log "ERROR" "第 ${LINENO} 行发生错误"' ERR

# 解析参数并执行
parse_args "$@"
init
main
