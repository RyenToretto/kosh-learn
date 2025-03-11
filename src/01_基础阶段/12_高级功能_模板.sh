# advanced_template.sh

# 并发控制
readonly MAX_PARALLEL=4

# 进度条
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))

    printf "\r进度: [%s%s] %d%%" \
           "$(printf '#%.0s' $(seq 1 $filled))" \
           "$(printf ' %.0s' $(seq 1 $empty))" \
           "$percentage"
}

# 并行执行
parallel_execute() {
    local -a pids=()

    for cmd in "$@"; do
        # 检查运行中的进程数
        while [[ ${#pids[@]} -ge $MAX_PARALLEL ]]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 ${pids[i]} 2>/dev/null; then
                    unset 'pids[i]'
                fi
            done
            sleep 1
        done

        # 执行命令
        eval "$cmd" &
        pids+=($!)
    done

    # 等待所有进程完成
    wait
}

# 配置管理
declare -A CONFIG
load_config() {
    local config_file=$1
    while IFS='=' read -r key value; do
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        CONFIG["${key// /}"]="${value// /}"
    done < "$config_file"
}

# 锁机制
LOCK_FILE="/var/run/${SCRIPT_NAME}.lock"

acquire_lock() {
    exec 200>"$LOCK_FILE"
    if ! flock -n 200; then
        log "ERROR" "另一个实例正在运行"
        exit 1
    fi
}

release_lock() {
    flock -u 200
    rm -f "$LOCK_FILE"
}
