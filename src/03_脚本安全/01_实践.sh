#!/bin/bash
# 安全性增强的脚本模板

# 设置严格的执行模式
set -euo pipefail
IFS=$'\n\t'

# 限制文件权限
umask 077

# 安全的临时文件创建
readonly TEMP_FILE=$(mktemp -t tmp.XXXXXXXXXX)
trap 'rm -f "$TEMP_FILE"' EXIT

# 设置安全选项
set -euo pipefail
IFS=$'\n\t'

# 安全的临时文件创建
readonly TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

# 安全的变量使用
var=${1:-}                    # 安全地获取参数
readonly PASSWORD_FILE        # 防止重要变量被修改
declare -r API_KEY="xxx"      # 只读变量

# 安全的命令执行
safe_execute() {
    if ! "$@"; then
        echo "错误: 命令 '$*' 执行失败" >&2
        exit 1
    fi
}
