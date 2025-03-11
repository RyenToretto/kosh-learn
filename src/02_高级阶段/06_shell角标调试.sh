#!/bin/bash

# 打开调试模式
set -x            # 显示执行的命令
set -e            # 发生错误时立即退出
set -u            # 使用未定义变量时报错

# 调试整个脚本
bash -x script.sh

# 调试部分代码
set -x
# 需要调试的代码
set +x

# 输出调试信息
debug() {
    [ "$DEBUG" = "true" ] && echo "DEBUG: $*"
}

# 使用陷阱捕获错误
trap 'echo "错误发生在第 $LINENO 行"' ERR

# 记录日志
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> script.log
}
