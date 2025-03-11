#!/bin/bash
# 用户管理工具

# 添加用户
add_user() {
    if [ $# -ne 2 ]; then
        echo "用法: add_user 用户名 密码"
        return 1
    fi

    useradd -m "$1"
    echo "$1:$2" | chpasswd
    echo "用户 $1 创建成功"
}

# 删除用户
delete_user() {
    if id "$1" &>/dev/null; then
        userdel -r "$1"
        echo "用户 $1 已删除"
    else
        echo "用户 $1 不存在"
    fi
}
