#!/bin/bash

# 后台运行
command &
nohup command &   # 忽略挂起信号

# 作业控制
jobs              # 查看后台作业
fg %1             # 将作业1调至前台
bg %1             # 将作业1放到后台运行

# 进程管理命令
ps aux            # 查看所有进程
top               # 动态显示进程信息
kill -9 PID       # 强制终止进程

# 守护进程管理
start_daemon() {
    local pid_file="/var/run/${1}.pid"

    # 检查是否已运行
    if [ -f "$pid_file" ]; then
        if kill -0 $(cat "$pid_file") 2>/dev/null; then
            echo "进程已在运行"
            return 1
        fi
    fi

    # 启动程序
    nohup "$@" >/dev/null 2>&1 &
    echo $! > "$pid_file"
}

# 资源限制
limit_process() {
    local pid=$1
    local cpu_limit=$2
    local mem_limit=$3

    # 设置CPU限制
    cpulimit -p "$pid" -l "$cpu_limit" &

    # 设置内存限制
    ulimit -v "$mem_limit"
}
