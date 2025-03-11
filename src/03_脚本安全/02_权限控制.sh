#!/bin/bash
# 权限检查函数

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "错误: 此脚本需要root权限" >&2
        exit 1
    fi
}

check_permissions() {
    local file=$1
    local required_perms=$2

    if [ ! -e "$file" ]; then
        echo "错误: 文件 $file 不存在" >&2
        return 1
    fi

    local actual_perms=$(stat -f "%Lp" "$file")
    if [ "$actual_perms" != "$required_perms" ]; then
        echo "错误: $file 权限不正确" >&2
        return 1
    fi
}
